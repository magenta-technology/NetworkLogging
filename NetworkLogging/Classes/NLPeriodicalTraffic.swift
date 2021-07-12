//
//  NLPeriodicalTraffic.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 12.02.2020.
//

import Foundation

class NLPeriodicalTraffic {
    func start(delay: TimeInterval, handler: (()->Void)?) {
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now() + delay, repeating: delay)
        timer?.setEventHandler(handler: handler)
        timer?.resume()
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    deinit {
        stop()
    }

    private var timer: DispatchSourceTimer?
}
