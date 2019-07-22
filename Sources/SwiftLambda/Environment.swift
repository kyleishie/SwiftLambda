//
//  Environment.swift
//  Swift 5.0
//  Created by Kyle Ishie, Kyle Ishie Development.
//


import Foundation


public struct Environment {
    
    public let runtimeAPI : String
    public let handler : String?
    public let region : String?
    public let executionEnv : String?
    public let functionName : String?
    public let memorySize : String?
    public let version : String?
    public let logGroupName : String?
    public let logStreamName : String?
    public let accessKeyId : String?
    public let secretAccessKey : String?
    public let sessionToken : String?
    public let lang : String?
    public let timezone : String?
    public let taskRoot : String?
    public let runtimeDir : String?
    public let path : String?
    public let libraryPath : String?
    
    public var traceId : String? {
        didSet {
            if let traceId = traceId {
                setenv(CodingKeys.traceId.rawValue, traceId, 0)
            } else {
                unsetenv(CodingKeys.traceId.rawValue)
            }
        }
    }
    
}

extension Environment : Codable {
    
    enum CodingKeys : String, CodingKey {
        case handler = "_HANDLER"
        case region = "AWS_REGION"
        case executionEnv = "AWS_EXECUTION_ENV"
        case functionName = "AWS_LAMBDA_FUNCTION_NAME"
        case memorySize = "AWS_LAMBDA_FUNCTION_MEMORY_SIZE"
        case version = "AWS_LAMBDA_FUNCTION_VERSION"
        case logGroupName = "AWS_LAMBDA_LOG_GROUP_NAME"
        case logStreamName = "AWS_LAMBDA_LOG_STREAM_NAME"
        case accessKeyId = "AWS_ACCESS_KEY_ID"
        case secretAccessKey = "AWS_SECRET_ACCESS_KEY"
        case sessionToken = "AWS_SESSION_TOKEN"
        case lang = "LANG"
        case timezone = "TZ"
        case taskRoot = "LAMBDA_TASK_ROOT"
        case runtimeDir = "LAMBDA_RUNTIME_DIR"
        case path = "PATH"
        case libraryPath = "LD_LIBRARY_PATH"
        case runtimeAPI = "AWS_LAMBDA_RUNTIME_API"
        case traceId = "_X_AMZN_TRACE_ID"
    }
    
}

extension Environment {
    
    /**
     Decodes an Environment type from the current Process's environment dictionary.
     
     - Returns: An instance of Environment.
     - Throws: JSONEncodingError, JSONDecodingError
     */
    public static func processEnvironment() throws -> Environment {
        let processEnv = ProcessInfo.processInfo.environment
        /// This is completely unneccessary but it'll do for now.
        //TODO: Replace this with a more manual parsing method that throws more specific errors.
        let data = try JSONEncoder().encode(processEnv)
        return try JSONDecoder().decode(Environment.self, from: data)
    }
    
}
