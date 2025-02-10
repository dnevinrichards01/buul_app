//
//  Utils.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/5/25.
//

import SwiftUI

class Utils {
    
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    static func nilOrEmptyString(_ str: String?) -> Bool {
        return str == nil || str == ""
    }
    
    static func compactMapKeys<T: Hashable>(dictionary: [String: String?], transform: (String) -> T?) -> [T: String?] {
        var newDict: [T: String?] = [:]
        for (key, value) in dictionary {
            if let newKey = transform(key) {
                newDict[newKey] = value
            }
        }
        return newDict
    }
}
