//
//  Application.swift
//  AppPath
//
//  Created by 杨冬青 on 2017/12/8.
//  Copyright © 2017年 杨冬青. All rights reserved.
//

import Foundation

struct Application {
  let bundleId: String
  let simulator: Simulator
  let name: String
  let lastModifiedDate: Date
  
  var dataLocation: URL {
    return URL(fileURLWithPath: Shell.path(for: bundleId, in: simulator.uuid))
  }
}
