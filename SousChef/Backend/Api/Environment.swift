//
//  Environment.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/10/24.
//

import Foundation

class AppEnvironment {
    static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
              let value = plist[key] as? String else {
            fatalError("Missing \(key) in config.plist")
        }
        return value
    }
}
