//
//  Simulator.swift
//  Path
//
//  Created by 杨冬青 on 2017/12/8.
//  Copyright © 2017年 杨冬青. All rights reserved.
//

import Foundation

struct Simulator {
  static let devicesURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("Developer")
    .appendingPathComponent("CoreSimulator")
    .appendingPathComponent("Devices")
  
  enum Status: String {
    case booted = "Booted"
    case shutdown = "Shutdown"
    
    var isBooted: Bool {
      return self == .booted
    }
  }
  
  let os: String
  let uuid: String
  let name: String
  let status: Status
  var location: URL {
    return Simulator.devicesURL.appendingPathComponent(uuid)
  }
  
  var applicationLocation: URL {
    return location
      .appendingPathComponent("data")
      .appendingPathComponent("Containers")
      .appendingPathComponent("Bundle")
      .appendingPathComponent("Application")
  }
  
  var applications: [Application] {
    var appURLs: [URL] = []
    // 遍历模拟器下面所有的应用
    if let urls = try? FileManager.default.contentsOfDirectory(at: applicationLocation, includingPropertiesForKeys: [.nameKey, .contentModificationDateKey], options: .skipsHiddenFiles) {
      appURLs = urls
    }
    
    if appURLs.count == 0 {
      return []
    }
    
    // 根据修改日期排序
    let sorted = appURLs
      .map { url -> (URL, Date) in
        let resourceValues = try? url.resourceValues(forKeys: [.contentModificationDateKey])
        return (url, resourceValues!.contentModificationDate!)
      }
      .sorted(by: { $0.1 > $1.1 })
    
    var applications: [Application] = []
    for (url, date) in sorted {
      if let app = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).filter { $0.pathExtension == "app" })?.first {
        let info = app.appendingPathComponent("Info.plist")
        
        let data = FileManager.default.contents(atPath: info.path)
        var format = PropertyListSerialization.PropertyListFormat.xml
        do {
          if let data = try PropertyListSerialization.propertyList(from: data!, options: .mutableContainers, format: &format) as? [String: Any],
            let bundleIdentifier = data["CFBundleIdentifier"] as? String {
            let displayName = data["CFBundleDisplayName"] as? String
            let bundleName = data["CFBundleName"] as? String
            
            var name = bundleIdentifier
            if let d = displayName, d.count > 0 {
              name = d
            } else if let b = bundleName, b.count > 0 {
              name = b
            }
            
            let application = Application(bundleId: bundleIdentifier, simulator: self, name: name, lastModifiedDate: date)
            applications.append(application)
          }
        } catch let error {
          APLog.warning("\(url.lastPathComponent) 无法读取 Info.plist, error:\(error.localizedDescription)")
        }
      } else {
        APLog.warning("\(url.lastPathComponent) 不包含 *.app 文件")
      }
    }
    
    return applications
  }
}
