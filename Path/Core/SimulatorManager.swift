//
//  SimulatorManager.swift
//  Path
//
//  Created by 杨冬青 on 2017/12/8.
//  Copyright © 2017年 杨冬青. All rights reserved.
//

import Foundation
import RxSwift

final class SimulatorManager {
  static let shared = SimulatorManager()
  
  func simulators() -> [Simulator] {
    return Shell.listDevices().filter { $0.os.contains("iOS") && $0.status.isBooted }
  }
}
