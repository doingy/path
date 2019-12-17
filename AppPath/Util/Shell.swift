//
//  Shell.swift
//  AppPath
//
//  Created by 杨冬青 on 2017/12/8.
//  Copyright © 2017年 杨冬青. All rights reserved.
//

import Foundation

struct Shell {
  let launchPath: String
  let arguments: [String]
  
  func run() -> (Int32, String) {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    task.launch()
    task.waitUntilExit()
    
    let fh = pipe.fileHandleForReading
    let data = fh.readDataToEndOfFile()
    fh.closeFile()
    let string = String(data: data, encoding: .utf8)
    return (task.terminationStatus, string ?? "")
  }
}

extension Shell {
  /// 模拟器列表
  static func listDevices() -> [Simulator] {
    let shell = Shell(launchPath: "/usr/bin/xcrun", arguments: ["simctl", "list", "devices"])
    let (status, result) = shell.run()
    APLog.debug("status:[\(status)]\n\(result)")
    let list = result.components(separatedBy: "\n")
    var simulators: [Simulator] = []
    var os = ""
    for meta in list {
      // [== Devices ==]
      if meta.prefix(2) == "==" {
        continue
      }
      
      // [-- iOS 8.1 --]
      if meta.prefix(2) == "--" {
        os = meta.replacingOccurrences(of: "--", with: "").trimmingCharacters(in: .whitespaces)
        continue
      }
      
        // TODO: 正则处理
      // [     iPad Pro 9.7 - iOS 10 (3BDC7D9C-7DBF-40D9-8C48-9044B2B1A138) (Shutdown) ]
      if os != "", meta.prefix(2) == "  " {
        let deviceMeta = meta.components(separatedBy: "(")
        if deviceMeta.count == 3, let status = Simulator.Status(rawValue: deviceMeta[2].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ")", with: "")) {
          let uuid = deviceMeta[1].replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespaces)
          let name = deviceMeta[0].trimmingCharacters(in: .whitespaces)
          let simulator = Simulator(os: os, uuid: uuid, name: name, status: status)
          simulators.append(simulator)
        } else if deviceMeta.count == 4 {
            // "    iPad Pro (9.7-inch) (6F0BD1D9-24AD-403C-8628-69A07C99EE77) (Shutdown) "
        } else {
          APLog.warning("异常数据:\(deviceMeta)")
        }
      }
    }
    
    return simulators
  }
  
  /// 根据App Bundle Id获取应用的数据存储地址
  static func path(for appBundleId: String, in device: String = "booted") -> String {
    let shell = Shell(launchPath: "/usr/bin/xcrun", arguments: ["simctl", "get_app_container", device, appBundleId, "data"])
    let (status, result) = shell.run()
    APLog.info("status:[\(status)]\n\(result)")
    if let path = result.components(separatedBy: "\n").first {
      return path
    }
    return ""
  }
}
