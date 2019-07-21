import Foundation
import AsyncHTTPClient
import NIO
import NIOHTTP1

public final class SwiftLambda {
    
    private let eventLoopGroup : MultiThreadedEventLoopGroup
    private let httpClient : HTTPClient
    private var environment : Environment
    
    public init(environment: Environment) {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        self.environment = environment
        self.eventLoopGroup = eventLoopGroup
    }
    
    deinit {
        try? httpClient.syncShutdown()
    }
    
}

public extension SwiftLambda {
    
    typealias SyncHandler<I : Decodable, O : Encodable> = (I, InvocationContext) throws -> O
    typealias AsyncHandler<I : Decodable, O : Encodable> = (I, InvocationContext) throws -> EventLoopFuture<O>
    
    func sync<Input : Codable, Output : Codable>(_ handler: @escaping SyncHandler<Input, Output>) throws {
        try async { [eventLoopGroup] (input: Input, context: InvocationContext) -> EventLoopFuture<Output> in
            let output = try handler(input, context)
            return eventLoopGroup.next().makeSucceededFuture(output)
        }
    }
    
    func async<Input : Decodable, Output : Encodable>(_ handler: @escaping AsyncHandler<Input, Output>) throws {
        var invocationCount = 0
        repeat {
            invocationCount += 1
            
            do {
                /// Get Next Invocation request
                _ = try httpClient.lambdaGETNextInvocation(runtimeAPI: environment.runtimeAPI)
                    
                    /// Parse Response
                    .flatMapThrowing({ response -> (Data, InvocationContext) in
                        guard var body = response.body else {
                            throw InvocationError.missingInputData(response.headers)
                        }
                        guard let inputBytes = body.readBytes(length: body.readableBytes) else {
                            throw InvocationError.unreadableInputData(response.headers)
                        }
                        return (Data(inputBytes), response.headers)
                    })
                    
                    /// Decode Event Data to Input
                    .flatMapThrowing({ inputData, context -> (Input, InvocationContext) in
                        let input = try JSONDecoder().decode(Input.self, from: inputData)
                        return (input, context)
                    })
                    
                    /// Call Handler
                    .flatMapThrowing({ (input, context) -> (Output, InvocationContext) in
                        let output = try handler(input, context).wait()
                        return (output, context)
                    })
                    
                    /// Encode Handler Output to Data
                    .flatMapThrowing({ (output, context) -> (Data, InvocationContext) in
                        let outputData = try JSONEncoder().encode(output)
                        return (outputData, context)
                    })
                    
                    /// Post Invocation Response
                    .flatMap({ [environment, httpClient] (outputData, context) -> EventLoopFuture<HTTPClient.Response> in
                        httpClient.lambdaPOSTInvocationResponse(runtimeAPI: environment.runtimeAPI, for: context.awsRequestId, responseData: outputData)
                    })
                    
                    /// Wait for the chain to finish before starting the next invocation.
                    .wait()
                
            } catch let error as InvocationError {
                /// Post Invocation Error
                _ = try httpClient
                    .lambdaPOSTInvocationError(runtimeAPI: environment.runtimeAPI, for: error.context.awsRequestId, error: error)
                    .wait()
            }
            
        } while true
    }
    
}



