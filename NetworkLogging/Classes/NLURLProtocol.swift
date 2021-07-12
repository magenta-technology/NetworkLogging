//
//  NLURLProtocol.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 11.02.2020.
//

import Foundation

class NLURLProtocol: URLProtocol {
    static let nlKey = "NetworLoggingKey"

    override class func canInit(with request: URLRequest) -> Bool {
        if URLProtocol.property(forKey: NLURLProtocol.nlKey, in: request) != nil {
            return false
        }
        return true
    }

    override func startLoading() {
        let newRequest = ((self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)!
        URLProtocol.setProperty(true, forKey: NLURLProtocol.nlKey, in: newRequest)
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session?.dataTask(with: newRequest as URLRequest).resume()
    }

    override func stopLoading() {
        session?.getTasksWithCompletionHandler { dataTasks, _, _ in
            dataTasks.forEach { $0.cancel() }
        }
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }

    private var session: URLSession?
    private var mutableData: Data?
    private let model = NLLogModel()
}

extension NLURLProtocol: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive data: Data) {
        mutableData?.append(data)
        client?.urlProtocol(self, didLoad: data)
    }
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.mutableData = Data()
        
        client?.urlProtocol(self,
                            didReceive: response,
                            cacheStoragePolicy: NetworkLogging.shared.cacheStoragePolicy)
        completionHandler(.allow)
    }
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        defer {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }
        
        guard let request = task.originalRequest else {
            return
        }
        model.persistRequest(request,
                             requestBodySize: Int(task.countOfBytesSent))
        model.persistResponse(task.response,
                              responseBodySize: Int(task.countOfBytesReceived),
                              data: mutableData ?? Data(), error: error)
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        let updatedRequest: URLRequest = {
            guard URLProtocol.property(forKey: NLURLProtocol.nlKey, in: request) != nil else {
                return request
            }
            let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            URLProtocol.removeProperty(forKey: NLURLProtocol.nlKey, in: mutableRequest)
            return mutableRequest as URLRequest
        }()
        client?.urlProtocol(self, wasRedirectedTo: updatedRequest,
                            redirectResponse: response)
        completionHandler(updatedRequest)
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}
