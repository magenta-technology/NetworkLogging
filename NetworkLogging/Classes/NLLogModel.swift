//
//  NLLogModel.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 11.02.2020.
//

import Foundation

class NLLogModel {
    func persistRequest(_ request: URLRequest,
                        requestBodySize: Int) {
        var size = requestBodySize
        if let headers = request.allHTTPHeaderFields {
            headers.forEach { key, value in
                size += "\(key): \(value)".data(using: .utf8)?.count ?? 0
            }
        }
        NLCoreDataStorage.container?.performBackgroundTask { context in
            let entity = NLTrafficEntity(context: context)
            entity.size = Int64(size)
            entity.direction = Int16(NLTrafficDirection.outcoming.rawValue)
            entity.type = Int16(NLTrafficType.url.rawValue)
            entity.timestamp = Date()
            try? context.save()
        }
    }

    func persistResponse(_ response: URLResponse?,
                         responseBodySize: Int,
                         data: Data, error: Error? = nil) {
        var size = responseBodySize
        if let httpResponse = response as? HTTPURLResponse,
            let headers = httpResponse.allHeaderFields as? [String: String] {
            headers.forEach { key, value in
                size += "\(key): \(value)".data(using: .utf8)?.count ?? 0
            }
        }
        NLCoreDataStorage.container?.performBackgroundTask { context in
            let entity = NLTrafficEntity(context: context)
            entity.size = Int64(size)
            entity.direction = Int16(NLTrafficDirection.incoming.rawValue)
            entity.type = Int16(NLTrafficType.url.rawValue)
            entity.timestamp = Date()
            try? context.save()
        }
    }
}
