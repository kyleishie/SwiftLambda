import Foundation
import AsyncHTTPClient
import NIO
import NIOHTTP1

public final class SwiftLambda {
    
    private let httpClient : HTTPClient
    private var environment : Environment
    
    public init(environment: Environment) {
        self.httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        self.environment = environment
    }
    
    deinit {
        try? httpClient.syncShutdown()
    }

}

public extension SwiftLambda {
    
    typealias SyncHandler<Input : Codable, Output : Codable> = (Input, InvocationContext) throws -> Output
    typealias AsyncHandler<Input : Codable, Output : Codable> = (Input, InvocationContext, (Output) throws -> Void) throws -> Void
    
    func async<Input : Codable, Output : Codable>(_ handler: AsyncHandler<Input, Output>) throws {
        var invocationCount = 0
        while true {
            let (headers, data) = try nextInvocation()
            invocationCount += 1
            log("Invocation Count: \(invocationCount)")
            
            guard let requestId = headers.awsRequestId else {
                throw Error.missingAWSRequestId
            }
            environment.traceId = headers.traceId
            
            let input = try JSONDecoder().decode(Input.self, from: data)
            do {
                try handler(input, headers, { [weak self] output in
                    let data = try JSONEncoder().encode(output)
                    try self?.postInvocationResponse(for: requestId, responseData: data)
                })
            } catch {
                try postInvocationError(for: requestId, error: error)
            }
        }
        
    }
    
    func sync<Input : Codable, Output : Codable>(_ handler: SyncHandler<Input, Output>) throws {
        try async { (input: Input, context: InvocationContext, respondWith: ((Output) throws -> Void)) in
            let output = try handler(input, context)
            try respondWith(output)
        }
    }
    
}

private extension SwiftLambda {
    
    func nextInvocation() throws -> (HTTPHeaders, Data) {
        let response = try httpClient.get(url: "http://\(environment.runtimeAPI)/2018-06-01/runtime/invocation/next").wait()
        
        guard var body = response.body else {
            throw Error.missingInvocationRequestData
        }
        guard let bodyBytes = body.readBytes(length: body.readableBytes) else {
            throw Error.invalidInvocationRequestData
        }
        
        let headers = response.headers
        
        return (headers, Data(bodyBytes))
    }
    
    func postInvocationResponse(for requestId: String, responseData: Data) throws {
        _ = try httpClient.post(url: "http://\(environment.runtimeAPI)/2018-06-01/runtime/invocation/\(requestId)/response", body: .data(responseData)).wait()
    }
    
    func postInvocationError(for requestId: String, error: Swift.Error) throws {
        let invocationError = InvocationError(error)
        let body = try JSONEncoder().encode(invocationError)
        _ = try httpClient.post(url: "http://\(environment.runtimeAPI)/2018-06-01/runtime/invocation/\(requestId)/response", body: .data(body)).wait()
    }
    
}


