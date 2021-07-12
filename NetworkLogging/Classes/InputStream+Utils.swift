//
//  InputStream+Utils.swift
//  NetworkLogging
//
//  Created by Pavel Volkhin on 11.02.2020.
//

import Foundation

extension InputStream {
    func readfully() -> Data {
      var result = Data()
      var buffer = [UInt8](repeating: 0, count: 4096)

      open()

      var amount = 0
      repeat {
        amount = read(&buffer, maxLength: buffer.count)
        if amount > 0 {
          result.append(buffer, count: amount)
        }
      } while amount > 0

      close()

      return result
    }
}
