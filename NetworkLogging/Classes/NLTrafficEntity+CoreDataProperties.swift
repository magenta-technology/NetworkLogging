//
//  NLTrafficEntity+CoreDataProperties.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 12.02.2020.
//
//

import Foundation
import CoreData


extension NLTrafficEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NLTrafficEntity> {
        return NSFetchRequest<NLTrafficEntity>(entityName: "NLTrafficEntity")
    }

    @NSManaged public var size: Int64
    @NSManaged public var type: Int16
    @NSManaged public var direction: Int16
    @NSManaged public var timestamp: Date?

}
