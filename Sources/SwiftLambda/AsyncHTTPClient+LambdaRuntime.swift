//
//  File.swift
//  Swift 5.0
//  Created by Kyle Ishie, Kyle Ishie Development.
//

import Foundation
import AsyncHTTPClient
import NIO

/// Simple convenience wrappers for the Lambda Runtime API
internal extension HTTPClient {
    
    func lambdaGETNextInvocation(runtimeAPI : String) -> EventLoopFuture<HTTPClient.Response> {
        return get(url: "http://\(runtimeAPI)/2018-06-01/runtime/invocation/next")
    }
    
    func lambdaPOSTInvocationResponse(runtimeAPI : String, for requestId: String, responseData: Data) -> EventLoopFuture<HTTPClient.Response> {
        return post(url: "http://\(runtimeAPI)/2018-06-01/runtime/invocation/\(requestId)/response", body: .data(responseData))
    }
    
    func lambdaPOSTInvocationError(runtimeAPI : String, for requestId: String, error: InvocationError) throws -> EventLoopFuture<HTTPClient.Response> {
        let body = try JSONEncoder().encode(error)
        return post(url: "http://\(runtimeAPI)/2018-06-01/runtime/invocation/\(requestId)/response", body: .data(body))
    }
    
}
