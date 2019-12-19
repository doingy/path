//
//  Version.swift
//  Path
//
//  Created by 杨冬青 on 2017/12/12.
//  Copyright © 2017年 杨冬青. All rights reserved.
//

import Foundation

struct Version: Codable {
  let version: String
  let build: String
  let token: String
}

extension Version {
  func sign() -> Bool {
    guard let sign = String(format: "crc,version:%@,build:%@,path", version, build).sha256() else {
      return false
    }
    
    return sign == token
  }
}
