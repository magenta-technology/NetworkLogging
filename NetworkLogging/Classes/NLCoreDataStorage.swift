//
//  NLCoreDataStorage.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 12.02.2020.
//

import CoreData
import Foundation

enum NLCoreDataError: Error {
    case modelUrl
    case model
    case documentsUrl
}

class NLCoreDataStorage {
    private(set) static var container: NSPersistentContainer?

    static func setup(completionHandler: ((Error?) -> Void)? = nil) {
        guard let modelUrl = Bundle(for: NetworkLogging.self)
            .url(forResource: "networklogging", withExtension: "momd") else {
                completionHandler?(NLCoreDataError.modelUrl)
                return
        }
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            completionHandler?(NLCoreDataError.model)
            return
        }
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completionHandler?(NLCoreDataError.documentsUrl)
            return
        }
        let descriptionUrl = documentsUrl.appendingPathComponent("networklogging.sqlite")
        let description = NSPersistentStoreDescription(url: descriptionUrl)
        description.type = NSSQLiteStoreType
        let container = NSPersistentContainer(name: "networklogging", managedObjectModel: model)
        container.persistentStoreDescriptions = [ description ]

        container.loadPersistentStores { _, err in
            if let error = err {
                NLCoreDataStorage.container = nil
                completionHandler?(error)
            } else {
                NLCoreDataStorage.container = container
                completionHandler?(nil)
            }
        }
    }
}
