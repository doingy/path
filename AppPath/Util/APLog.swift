//
//  APLog.swift
//  AppPath
//
//  Created by 杨冬青 on 2017/12/7.
//  Copyright © 2017年 杨冬青. All rights reserved.
//

import Foundation
import XCGLogger

final class APLog {
  static let `default` = APLog()
  
  enum Level {
    case verbose
    case debug
    case info
    case warning
    case error
    case severe
    case none
  }
  
  var blankMessageClosure: () -> Any? = { return "" }
  
  private let logger: XCGLogger
  
  private init() {
    logger = XCGLogger(identifier: Bundle.main.bundleIdentifier!, includeDefaultDestinations: false)
    
    logger.logAppDetails()
    
    #if DEBUG
    let systemDestionation = AppleSystemLogDestination()
    systemDestionation.outputLevel = .debug
    systemDestionation.showLevel = true
    systemDestionation.showLogIdentifier = false
    systemDestionation.showThreadName = true
    systemDestionation.showFileName = true
    systemDestionation.showLineNumber = true
    systemDestionation.showFunctionName = true
    logger.add(destination: systemDestionation)
    #else
    let appName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
    let logDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
      .appendingPathComponent(appName, isDirectory: true)
      .appendingPathComponent("log", isDirectory: true)
    if !createDir(at: logDirectory) {
      return
    }
    
    let logPath = logDirectory.appendingPathComponent("aplog.txt")
    let fileDestination = AutoRotatingFileDestination(writeToFile: logPath, identifier: logger.identifier, shouldAppend: true, appendMarker: "============", attributes: nil, maxFileSize: 1024 * 1024, maxTimeInterval: 60 * 60)
    fileDestination.outputLevel = .warning
    fileDestination.showDate = true
    fileDestination.showLevel = true
    fileDestination.showLogIdentifier = false
    fileDestination.showThreadName = true
    fileDestination.showFileName = true
    fileDestination.showLineNumber = true
    fileDestination.showFunctionName = true
    fileDestination.targetMaxLogFiles = 10
    
    fileDestination.logQueue = XCGLogger.logQueue
    
    let logFormatter: ANSIColorLogFormatter = ANSIColorLogFormatter()
    logFormatter.colorize(level: .verbose, with: .colorIndex(number: 244), options: [.faint])
    logFormatter.colorize(level: .debug, with: .black)
    logFormatter.colorize(level: .info, with: .blue, options: [.underline])
    logFormatter.colorize(level: .warning, with: .red, options: [.faint])
    logFormatter.colorize(level: .error, with: .red, options: [.bold])
    logFormatter.colorize(level: .severe, with: .white, on: .red)
    fileDestination.formatters = [logFormatter]
    
    logger.add(destination: fileDestination)
    #endif
  }
  
  // MARK: - Log
  static func log(_ closure: @autoclosure () -> Any?, level: Level = .debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [ String: Any] = [:]) {
    self.default.log(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  static func log(_ level: Level = .debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:], closure: () -> Any?) {
    self.default.log(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func log(_ closure: @autoclosure () -> Any?, level: Level = .debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    log(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  // MARK: 基础方法，如果要改变日志实现，修改这个函数
  func log(_ level: Level = .debug, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:], closure: () -> Any?) {
    logger.logln(level.level, functionName: String(describing: functionName), fileName: String(describing: fileName), lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  // MARK: - 便利方法
  // MARK: -verbose
  static func verbose(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: self.default.blankMessageClosure)
  }
  
  static func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  static func verbose(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func verbose(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: blankMessageClosure)
  }
  
  func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func verbose(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  // MARK: -debug
  
  static func debug(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: self.default.blankMessageClosure)
  }
  
  static func debug(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  static func debug(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func debug(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: blankMessageClosure)
  }
  
  func debug(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func debug(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  // MARK: -info
  
  static func info(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: self.default.blankMessageClosure)
  }
  
  static func info(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  static func info(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func info(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: blankMessageClosure)
  }
  
  func info(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func info(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  // MARK: -warning
  
  static func warning(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: self.default.blankMessageClosure)
  }
  
  static func warning(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  static func warning(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func warning(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: blankMessageClosure)
  }
  
  func warning(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func warning(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  // MARK: -error
  
  static func error(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: self.default.blankMessageClosure)
  }
  
  static func error(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  static func error(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func error(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: blankMessageClosure)
  }
  
  func error(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func error(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  // MARK: -severe
  
  static func severe(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: self.default.blankMessageClosure)
  }
  
  static func severe(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  static func severe(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func severe(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: blankMessageClosure)
  }
  
  func severe(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:]) {
    log(.severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  func severe(_ functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String : Any] = [:], closure: () -> Any?) {
    log(.severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }
  
  // MARK: - 私有函数
  @discardableResult
  private func createDir(at url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    var fileExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    if fileExists {
      if isDirectory.boolValue {
        return true
      } else {
        return false
      }
    }
    
    do {
      try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      fileExists = true
    } catch {
      fileExists = false
    }
    
    return fileExists
  }
}

extension APLog.Level {
  var level: XCGLogger.Level {
    switch self {
    case .verbose: return .verbose
    case .debug: return .debug
    case .info: return .info
    case .warning: return .warning
    case .error: return .error
    case .severe: return .severe
    case .none: return .none
    }
  }
}
