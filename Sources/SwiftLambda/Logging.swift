//
//  File.swift
//  Swift 5.0
//  Created by Kyle Ishie, Kyle Ishie Development.
//


import Foundation

public func log(_ object: Any, flush: Bool = false) {
    fputs("\(object)\n", stderr)
    if flush {
        fflush(stderr)
    }
}
