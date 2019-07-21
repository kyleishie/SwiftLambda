//
//  Error.swift
//  Swift 5.0
//  Created by Kyle Ishie, Kyle Ishie Development.
//


import Foundation

enum Error: Swift.Error {
    case missingEnvironmentVariables
    case invalidHandlerName
    case endpointError(String)
    case missingInvocationRequestData
    case invalidInvocationRequestData
    case unknownLambdaHandler
    case missingAWSRequestId
}

internal struct InvocationError : Codable {
    
    let errorMessage : String
    
    
    init(_ error: Swift.Error) {
        self.errorMessage = String(describing: error)
    }
}
