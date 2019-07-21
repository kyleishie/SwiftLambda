//
//  InvocationError.swift
//  Swift 5.0
//  Created by Kyle Ishie, Kyle Ishie Development.
//


import Foundation

enum InvocationError : Swift.Error {
    case invalidHandlerName(InvocationContext)
    case missingInputData(InvocationContext)
    case unreadableInputData(InvocationContext)
//    case undecodableInputData(InvocationContext) /// Using EncodingError for now as it is more insightful.
}

extension InvocationError {
    
    var context : InvocationContext {
        switch self {
        case .invalidHandlerName(let context):
            return context
        case .missingInputData(let context):
            return context
        case .unreadableInputData(let context):
            return context
        }
    }
    
}

extension InvocationError {
    
    var errorMessage : String {
        switch self {
        case .invalidHandlerName(_):
            return "Invalid Handler name."
        case .missingInputData(_):
            return "Missing input event data."
        case .unreadableInputData(_):
            return "The input event data is unreadable.  Not attempting to decode to Input Type."
        }
    }
    
}

extension InvocationError : Encodable {
    
    enum CodingKeys : String, CodingKey {
        case errorMessage
        case errorType
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(errorMessage, forKey: .errorMessage)
        try container.encode(String(describing: self), forKey: .errorType)
    }
    
}
