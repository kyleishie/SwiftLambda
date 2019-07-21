//
//  InvocationContext.swift
//  Swift 5.0
//  Created by Kyle Ishie, Kyle Ishie Development.
//


import Foundation

public protocol InvocationContext {
    
    var awsRequestId : String? { get }
    
    var deadlineMs : String? { get }
    
    var invokedFunctionARN : String? { get }
    
    var traceId : String? { get }
    
    var clientContext : String? { get }
    
    var cognitoIdentity : String? { get }
    
}
