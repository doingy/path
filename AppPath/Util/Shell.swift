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
      
      if os != "", meta.prefix(2) == "  " {
        var metaTmp = meta
        var statusString = ""
        if let statusRe = try? NSRegularExpression(pattern: "(\\(Shutdown\\)|\\(Booted\\))", options: []),
          let result = statusRe.matches(in: meta, options: [], range: NSMakeRange(0, meta.count)).first {
          
          let startIndex = meta.index(meta.startIndex, offsetBy: result.range.location + 1)
          let endIndex = meta.index(meta.startIndex, offsetBy: result.range.location - 1 + result.range.length - 1)
          statusString = String(meta[startIndex...endIndex])
          
          metaTmp.removeSubrange(metaTmp.index(metaTmp.startIndex, offsetBy: result.range.location)...)
        }
        
        var uuidString = ""
        if let uuidRe = try? NSRegularExpression(pattern: "(\\(\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}\\))", options: []),
          let result = uuidRe.matches(in: meta, options: [], range: NSMakeRange(0, meta.count)).first {
          
          let startIndex = meta.index(meta.startIndex, offsetBy: result.range.location + 1)
          let endIndex = meta.index(meta.startIndex, offsetBy: result.range.location - 1 + result.range.length - 1)
          uuidString = String(meta[startIndex...endIndex])
          
          metaTmp.removeSubrange(metaTmp.index(metaTmp.startIndex, offsetBy: result.range.location)...)
        }
        
        let nameString = metaTmp.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if nameString.count != 0, uuidString.count != 0, statusString.count != 0, let status = Simulator.Status(rawValue: statusString) {
          let simulator = Simulator(os: os, uuid: uuidString, name: nameString, status: status)
          simulators.append(simulator)
        } else {
          APLog.warning("异常数据:\(meta)")
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
