//
//  Logging.swift
//  YuzPay
//
//  Created by applebro on 20/12/22.
//

import Foundation

final public class Logging {
    public static func l(tag: @autoclosure () -> String = "Log", _ message: @autoclosure () -> Any) {
        #if DEBUG
        print("\(tag()): \(message())")
        #endif
    }
}
