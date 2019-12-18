//
//  AppDelegate.swift
//  AppPath
//
//  Created by 杨冬青 on 2017/12/7.
//  Copyright © 2017年 杨冬青. All rights reserved.
//

import Cocoa
import XCGLogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  var timer: Timer?
  var update = false
  
  let homeURL = URL(string: "https://github.com/doingy/path")!
  let helpURL = URL(string: "https://github.com/doingy/path/issues")!
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    statusItem.title = "Path"
    statusItem.action = #selector(show)
    
    // 每5分钟刷新一次
    timer = Timer.scheduledTimer(timeInterval: 60*5, target: self, selector: #selector(show), userInfo: nil, repeats: true)
    perform(#selector(show), with: nil, afterDelay: 0.5)
    
    // 检查新版本
    checkUpdate()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    timer?.invalidate()
    timer = nil
  }
}

// MARK: -
extension AppDelegate {
  
  /// 构造目录，显示目录
  @objc func show() {
    APLog.debug()
    let menu = NSMenu()
    statusItem.menu = menu
    
    // 关于
    let about = NSMenuItem(title: "About App Path", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
    menu.addItem(about)
    
    if update {
      let update = NSMenuItem(title: "有更新", action: #selector(handle(item:)), keyEquivalent: "u")
      update.representedObject = homeURL
      menu.addItem(update)
    }
    
    menu.addItem(.separator())
    
    // 设置应用
    setupApps(menu)
    
    // 帮助
    let help = NSMenuItem(title: "Help & Issue", action: #selector(handle(item:)), keyEquivalent: "h")
    help.representedObject = helpURL
    menu.addItem(help)
    // 退出
    let quit = NSMenuItem(title: "Quit App Path", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    menu.addItem(quit)
  }
  
  /// 设置模拟器应用
  func setupApps(_ menu: NSMenu) {
    
    // 模拟器-应用
    var noAppflag = false
    for simulator in SimulatorManager.shared.simulators() {
      if simulator.applications.count == 0 {
        continue
      }
      
      let osItem = NSMenuItem(title: "\(simulator.os) - \(simulator.name)", action: nil, keyEquivalent: "")
      menu.addItem(osItem)
      for application in simulator.applications {
        let applicationItem = NSMenuItem(title: "\(application.name)", action: #selector(handle(item:)), keyEquivalent: "")
        applicationItem.representedObject = application
        menu.addItem(applicationItem)
        noAppflag = true
      }
      menu.addItem(.separator())
    }
    // 如果没有活动的模拟器
    if !noAppflag {
      let tip = NSMenuItem(title: "All simulators are shutdown", action: nil, keyEquivalent: "")
      menu.addItem(tip)
    }
    
    //
    menu.addItem(.separator())
  }
  
  /// 打开应用的App的数据路径
  @objc func handle(item: NSMenuItem) {
    if let application = item.representedObject as? Application {
      let result = NSWorkspace.shared.open(application.dataLocation)
      APLog.debug(result)
    } else if let url = item.representedObject as? URL {
      let result = NSWorkspace.shared.open(url)
      APLog.debug(result)
    }
  }
  
  /// 检查新版本
  func checkUpdate() {
    // TODO: 暂时不可用
    let request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/doingy/path/master/version.json")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
    let task = URLSession.shared.dataTask(with: request) { (data, resp, error) in
      guard let status = (resp as? HTTPURLResponse)?.statusCode, status == 200, data != nil, let version = try? JSONDecoder().decode(Version.self, from: data!) else {
        if error != nil {
          APLog.warning("\(error!)")
        } else if resp != nil {
          APLog.warning("\(resp!)")
        }
        return
      }
      
      if !version.sign() {
        APLog.debug("版本信息校验不通过:\(version)")
        return
      }
      
      let ver = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
      let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
      
      
      if version.version.compare(ver) == .orderedDescending || version.build.compare(build) == .orderedDescending {
        APLog.debug("有更新")
        DispatchQueue.main.sync {
          self.update = true
        }
      } else {
        APLog.debug("没有更新")
      }
    }
    task.resume()
  }
}
