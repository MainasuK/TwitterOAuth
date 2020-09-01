//
//  Utils.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 1/28/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import Foundation

extension String {
    
    var urlEncoded: String {
        let customAllowedSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
    }
    
}

extension Dictionary {
    
    var queryString: String {
        var parts = [String]()
        
        for (key, value) in self {
            let query: String = "\(key)=\(value)"
            parts.append(query)
        }
        
        return parts.joined(separator: "&")
    }
    
    var urlEncodedQuery: String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString = "\(key)".urlEncoded
            let valueString = "\(value)".urlEncoded
            let query = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        
        return parts.joined(separator: "&")
    }

}

