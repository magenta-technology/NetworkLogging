//
//  ViewController.swift
//  NetworkLogging
//
//  Created by Pavel Volhin on 02/11/2020.
//  Copyright (c) 2020 Pavel Volhin. All rights reserved.
//

import UIKit
import NetworkLogging

class ViewController: UIViewController {
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var allTraffic: UIButton!

    @IBAction private func tappedStart() {
        /*NetworkLogging.shared.addSavePeriodicTraffic(isIncrementedTraffic: true,
                                                     incommingClosure: { () -> Int in
                                                        return 5
        }) { () -> Int in
            return 6
        }
        NetworkLogging.shared.addSavePeriodicTraffic(incommingClosure: { () -> Int in
                                                        return 1
        }) { () -> Int in
            return 1
        }*/
        NetworkLogging.shared.start()
    }

    @IBAction private func tappedStop() {
        NetworkLogging.shared.stop()
    }

    @IBAction private func tappedSend() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = URLSession(configuration: .default).dataTask(with: request) { _, _, _ in
        }
        task.resume()
    }

    @IBAction private func tappetAllTraffic() {
        NetworkLogging.shared.getTotalTraffic { traffic in
            print("All traffic: \(traffic)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkLogging.shared.setup()
    }
}

