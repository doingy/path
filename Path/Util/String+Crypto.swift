//
//  String+Crypto.swift
//  Path
//
//  Created by 杨冬青 on 2017/12/12.
//  Copyright © 2017年 杨冬青. All rights reserved.
//

import Foundation

extension String {
  func sha256() -> String? {
    guard let data = data(using: .utf8) else {
      return nil
    }
    
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
        _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash).map { String(format: "%02hhx", $0) }.joined()
  }
}
