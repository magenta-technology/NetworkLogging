//
//  URLSessionConfiguration+Utils.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 13.02.2020.
//

import Foundation

@objc private extension URLSessionConfiguration {
    private static var firstOccurrence = true
    
    static func implementNetworkLogging() {
        guard firstOccurrence else { return }
        firstOccurrence = false

        swizzleProtocolSetter()
        swizzleDefault()
    }
    
    private static func swizzleProtocolSetter() {
        let instance = URLSessionConfiguration.default
        let aClass: AnyClass = object_getClass(instance)!
        let origSelector = #selector(setter: URLSessionConfiguration.protocolClasses)
        let newSelector = #selector(setter: URLSessionConfiguration.protocolClasses_Swizzled)
        let origMethod = class_getInstanceMethod(aClass, origSelector)!
        let newMethod = class_getInstanceMethod(aClass, newSelector)!
        method_exchangeImplementations(origMethod, newMethod)
    }
    
    @objc private var protocolClasses_Swizzled: [AnyClass]? {
        get {
            return self.protocolClasses_Swizzled
        }
        set {
            guard let newTypes = newValue else { self.protocolClasses_Swizzled = nil; return }
            var types = [AnyClass]()
            for newType in newTypes {
                if !types.contains(where: { (existingType) -> Bool in
                    existingType == newType
                }) {
                    types.append(newType)
                }
            }
            self.protocolClasses_Swizzled = types
        }
    }
    
    private static func swizzleDefault() {
        let aClass: AnyClass = object_getClass(self)!
        let origSelector = #selector(getter: URLSessionConfiguration.default)
        let newSelector = #selector(getter: URLSessionConfiguration.default_swizzled)
        let origMethod = class_getClassMethod(aClass, origSelector)!
        let newMethod = class_getClassMethod(aClass, newSelector)!
        method_exchangeImplementations(origMethod, newMethod)
    }
    
    @objc private class var default_swizzled: URLSessionConfiguration {
        get {
            let config = URLSessionConfiguration.default_swizzled
            config.protocolClasses?.insert(NLURLProtocol.self, at: 0)
            return config
        }
    }
}
