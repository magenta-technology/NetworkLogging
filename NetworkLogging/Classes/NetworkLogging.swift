//
//  NetworkLogging.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 11.02.2020.
//

import CoreData
import Foundation

@objc
open class NetworkLogging: NSObject {
    @objc public static let shared: NetworkLogging = NetworkLogging()

    @objc open var isEnable: Bool {
        return enable
    }
    @objc open var cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed
    @objc open var periodDelay: TimeInterval = 10

    @objc open func setup(completionHandler: (()-> Void)? = nil) {
        queue.async {
            if NLCoreDataStorage.container == nil {
                NLCoreDataStorage.setup { _ in
                   completionHandler?()
                }
            }
        }
    }

    @objc open func start() {
        if enable {
            return
        }
        self.enable = true
        queue.async {
            if NLCoreDataStorage.container != nil {
                self.register()
                self.startPeriodicalTraffic()
            } else {
                NLCoreDataStorage.setup { error in
                    if error != nil {
                        self.stop()
                    } else {
                        if self.enable {
                            self.register()
                            self.startPeriodicalTraffic()
                        }
                    }
                }
            }
        }
    }

    @objc open func stop() {
        if !enable {
            return
        }
        enable = false
        unregister()
        self.stopPeriodicalTraffic()
    }

    @objc open func addSavePeriodicTraffic(isIncrementedTraffic: Bool = false,
                                           incommingClosure: @escaping (()->Int),
                                           outcommingClosure: @escaping (()->Int)) {
        traficModels.append(NLPeriodicalTrafficModel(isIncrementedTraffic:isIncrementedTraffic,
                                                     incomingClosure: incommingClosure,
                                                     outcommingClosure: outcommingClosure))
    }
    
    @objc open func removeAllSavePeriodicTraffic() {
        traficModels.removeAll()
    }

    private override init() {
        super.init()
    }

    private func register() {
        URLProtocol.registerClass(NLURLProtocol.self)
    }

    private func unregister() {
        URLProtocol.unregisterClass(NLURLProtocol.self)
    }

    private func startPeriodicalTraffic() {
        periodicalTraffic.start(delay: periodDelay) { [weak self] in
            self?.traficModels.forEach({ $0.persist()})
        }
    }

    private func stopPeriodicalTraffic() {
        periodicalTraffic.stop()
    }

    private var enable = false
    private let queue = DispatchQueue(label: "networkLogging")
    private var traficModels = [NLPeriodicalTrafficModel]()
    private let periodicalTraffic = NLPeriodicalTraffic()
}

@objc public extension NetworkLogging {
    @objc func clearAll() {
        let request: NSFetchRequest = NLTrafficEntity.fetchRequest()
        NLCoreDataStorage.container?.performBackgroundTask { context in
            let entities = try? context.fetch(request)
            entities?.forEach({ entity in
                context.delete(entity)
            })
            try? context.save()
        }
    }

    @objc func getTotalTraffic(completionHandler: @escaping ((Int) -> Void)) {
        let request: NSFetchRequest = NLTrafficEntity.fetchRequest()
        getTrafficByRequest(request, completionHandler: completionHandler)
    }

    @objc func getAllTraffic(type: NLTrafficType,
                             direction: NLTrafficDirection,
                             completionHandler:  @escaping ((Int) -> Void)) {
        let request: NSFetchRequest = NLTrafficEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@ AND %K = %@",
                                        argumentArray: [#keyPath(NLTrafficEntity.type),
                                                        type.rawValue,
                                                        #keyPath(NLTrafficEntity.direction),
                                                        direction.rawValue])
        getTrafficByRequest(request, completionHandler: completionHandler)
    }

    @objc func getTrafficInPeriod(type: NLTrafficType,
                                  direction: NLTrafficDirection,
                                  start: Date, end: Date,
                                  completionHandler: @escaping ((Int) -> Void)) {
        let request: NSFetchRequest = NLTrafficEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@ AND %K = %@ AND (%K >= %@) AND (%K <= %@)",
                                        argumentArray: [#keyPath(NLTrafficEntity.type),
                                                        type.rawValue,
                                                        #keyPath(NLTrafficEntity.direction),
                                                        direction.rawValue,
                                                        #keyPath(NLTrafficEntity.timestamp),
                                                        start, #keyPath(NLTrafficEntity.timestamp),
                                                        end])
        getTrafficByRequest(request, completionHandler: completionHandler)
    }

    private func getTrafficByRequest(_ request: NSFetchRequest<NLTrafficEntity>,
                                     completionHandler: @escaping ((Int) -> Void)) {
        NLCoreDataStorage.container?.performBackgroundTask { context in
            var result: Int = 0
            let entities = try? context.fetch(request)
            entities?.forEach({ entity in
                result += Int(entity.size)
            })
            completionHandler(result)
        }
    }
}
