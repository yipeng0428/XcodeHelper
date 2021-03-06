//
//  AutoUpdateDVTPluginCompatibilityUUID.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/21.
//  Copyright © 2016年 XH. All rights reserved.
//

import AppKit


class AutoUpdateDVTPlugInCompatibilityUUID: NSObject {

    static var shared = AutoUpdateDVTPlugInCompatibilityUUID()

    // MARK: - Public 

    func startChecking() {
        let fm = FileManager.default
        var isDir: ObjCBool = true
        let aPath = self.pluginPath()
        if fm.fileExists(atPath: aPath, isDirectory: &isDir) {
            if let files = try? fm.contentsOfDirectory(atPath: aPath) {
                var fielsToDeal = [String]()
                for item in files {
                    if item.hasSuffix(".xcplugin") {
                        fielsToDeal.append(item)
                    }
                }

                self.updateDVTPlugInCompatibilityUUIDFor(items: fielsToDeal)
            }
            
        }
    }

    func updateDVTPlugInCompatibilityUUIDFor(items:[String]) {
        let aPath = self.pluginPath()
        let currentVersionInfofile = NSMutableDictionary(contentsOfFile: "/Applications/Xcode.app/Contents/Info.plist")
        for item in items {
            let infoFile = aPath.stringByAppendPathComponent(item+infoPlist)
            if let dict = NSMutableDictionary(contentsOfFile: infoFile),
                let ids = dict["DVTPlugInCompatibilityUUIDs"] as? [String],
                let currentKey  = currentVersionInfofile?["DVTPlugInCompatibilityUUID"] as? String {

                let pluginIdentifier = dict["CFBundleIdentifier"] as! String

                print("plugin: \(pluginIdentifier) currentKey:\(currentKey)")
                var modifyOne = ids

                var needUpdate = true
                for item in modifyOne {
                    if item == currentKey {
                        needUpdate = false
                        break
                    }
                }

                if needUpdate {
                    modifyOne.append(currentKey)
                    let toSaveDict = dict
                    toSaveDict["DVTPlugInCompatibilityUUIDs"] = modifyOne
                    (toSaveDict as NSDictionary).write(toFile: infoFile, atomically: true)
                    print("plugin: \(pluginIdentifier) update for :\(currentKey)")
                }
            }
        }
    }

    // MARK: - Private

    private let pluginDir = "/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
    private let infoPlist = "/Contents/info.plist"

    private func pluginPath() -> String {
        let pluginsHome = NSHomeDirectory().stringByAppendPathComponent(self.pluginDir)
        return pluginsHome
    }
}
