//
//  HTTPHeaders.swift
//  Swift 5.0
//  Created by Kyle Ishie, Kyle Ishie Development.
//


import Foundation
import NIOHTTP1

public extension HTTPHeaders {
    
    var awsRequestId : String! {
        return self["Lambda-Runtime-Aws-Request-Id"].first
    }
    
    var deadlineMs : String! {
        return self["Lambda-Runtime-Deadline-Ms"].first
    }
    
    var invokedFunctionARN : String! {
        return self["Lambda-Runtime-Invoked-Function-Arn"].first
    }
    
    var traceId : String? {
        return self["Lambda-Runtime-Trace-Id"].first
    }
    
    var clientContext : String? {
        return self["Lambda-Runtime-Client-Context"].first
    }
    
    var cognitoIdentity : String? {
        return self["Lambda-Runtime-Cognito-Identity"].first
    }
    
}

extension HTTPHeaders : InvocationContext {}
