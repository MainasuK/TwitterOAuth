//
//  Utils.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 1/28/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import Foundation

func rotateLeft(_ v:UInt16, n:UInt16) -> UInt16 {
    return ((v << n) & 0xFFFF) | (v >> (16 - n))
}

func rotateLeft(_ v:UInt32, n:UInt32) -> UInt32 {
    return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
}

func rotateLeft(_ x:UInt64, n:UInt64) -> UInt64 {
    return (x << n) | (x >> (64 - n))
}

func rotateRight(_ x:UInt16, n:UInt16) -> UInt16 {
    return (x >> n) | (x << (16 - n))
}

func rotateRight(_ x:UInt32, n:UInt32) -> UInt32 {
    return (x >> n) | (x << (32 - n))
}

func rotateRight(_ x:UInt64, n:UInt64) -> UInt64 {
    return ((x >> n) | (x << (64 - n)))
}

func reverseBytes(_ value: UInt32) -> UInt32 {
    let tmp1 = ((value & 0x000000FF) << 24) | ((value & 0x0000FF00) << 8)
    let tmp2 = ((value & 0x00FF0000) >> 8)  | ((value & 0xFF000000) >> 24)
    return tmp1 | tmp2
}

extension String {
    
    internal func indexOf(_ sub: String) -> Int? {
        guard let range = self.range(of: sub), !range.isEmpty else {
            return nil
        }
        return self.distance(from: self.startIndex, to: range.lowerBound)
    }
    
    internal subscript (r: Range<Int>) -> Substring {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return self[startIndex..<endIndex]
        }
    }
    
    
    func urlEncodedString(_ encodeAll: Bool = false) -> String {
        var allowedCharacterSet: CharacterSet = .urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        if !encodeAll {
            allowedCharacterSet.insert(charactersIn: "[]")
        }
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    }
    
}

extension Dictionary {
    
    func filter(_ predicate: (Element) -> Bool) -> Dictionary {
        var filteredDictionary = Dictionary()
        for element in self where predicate(element) {
            filteredDictionary[element.key] = element.value
        }
        return filteredDictionary
    }
    
    var queryString: String {
        var parts = [String]()
        
        for (key, value) in self {
            let query: String = "\(key)=\(value)"
            parts.append(query)
        }
        
        return parts.joined(separator: "&")
    }
    
    func urlEncodedQueryString(using encoding: String.Encoding) -> String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString = "\(key)".urlEncodedString()
            let valueString = "\(value)".urlEncodedString(keyString == "status")
            let query: String = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        
        return parts.joined(separator: "&")
    }
    
    func stringifiedDictionary() -> Dictionary<String, String> {
        var dict = [String: String]()
        for (key, value) in self {
            dict[String(describing: key)] = String(describing: value)
        }
        return dict
    }
    
}

infix operator +|

func +| <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V> {
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}

