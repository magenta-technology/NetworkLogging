//
//  NLPeriodicTrafficModel.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 12.02.2020.
//

import Foundation

class NLPeriodicalTrafficModel {
    init(isIncrementedTraffic: Bool = false,
         incomingClosure: @escaping (() -> Int),
         outcommingClosure: @escaping (() -> Int)) {
        self.isIncrementedTraffic = isIncrementedTraffic
        self.incomingClosure = incomingClosure
        self.outcommingClosure = outcommingClosure
    }

    func persist() {
        persistSize(incomingClosure(), direction: .incoming)
        persistSize(outcommingClosure(), direction: .outcoming)
    }

    private func persistSize(_ traffic: Int, direction: NLTrafficDirection) {
        var size: Int64 = 0
        if isIncrementedTraffic {
            switch direction {
            case .incoming:
                size = Int64(traffic - self.incommingTraffic)
                self.incommingTraffic = traffic
            case .outcoming:
                size = Int64(traffic - self.outcommingTraffic)
                self.outcommingTraffic = traffic
            }
        } else {
            size = Int64(traffic)
        }
        NLCoreDataStorage.container?.performBackgroundTask { context in
            let entity = NLTrafficEntity(context: context)
            entity.size = size
            entity.direction = Int16(direction.rawValue)
            entity.type = Int16(NLTrafficType.other.rawValue)
            entity.timestamp = Date()
            try? context.save()
        }
    }

    private let incomingClosure: (() -> Int)
    private let outcommingClosure: (() -> Int)
    private let isIncrementedTraffic: Bool
    private var incommingTraffic: Int = 0
    private var outcommingTraffic: Int = 0
}
