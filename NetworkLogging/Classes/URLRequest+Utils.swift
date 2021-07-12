//
//  URLRequest+Utils.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 11.02.2020.
//

import Foundation

extension URLRequest {
    func getBodyData() -> Data {
        return httpBodyStream?.readfully() ?? Data()
    }
}
