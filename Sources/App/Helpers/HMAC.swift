//
//  HMAC.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 1/28/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import Foundation

open class HMAC {
    
    let key: [UInt8] = []
    
    class internal func sha1(key: Data, message: Data) -> Data? {
        let blockSize = 64
        var key = key.bytes
        let message = message.bytes
        
        if key.count > blockSize {
            key = SHA1(key).calculate()
        } else if key.count < blockSize { // padding
            key += [UInt8](repeating: 0, count: blockSize - key.count)
        }
        
        var ipad = [UInt8](repeating: 0x36, count: blockSize)
        for idx in key.indices {
            ipad[idx] = key[idx] ^ ipad[idx]
        }
        
        var opad = [UInt8](repeating: 0x5c, count: blockSize)
        for idx in key.indices {
            opad[idx] = key[idx] ^ opad[idx]
        }
        
        let ipadAndMessageHash = SHA1(ipad + message).calculate()
        let mac = SHA1(opad + ipadAndMessageHash).calculate()
        var hashedData: Data?
        mac.withUnsafeBufferPointer { pointer in
            guard let baseAddress = pointer.baseAddress else { return }
            hashedData = Data(bytes: baseAddress, count: mac.count)
        }
        return hashedData
    }
    
}

extension Data {
    
    internal init(data: Data) {
        self.init()
        self.append(data)
    }
    
    internal mutating func append(_ bytes: [UInt8]) {
        self.append(bytes, count: bytes.count)
    }
    internal mutating func append(_ byte: UInt8) {
        append([byte])
    }
    internal mutating func append(_ byte: UInt16) {
        append(UInt8(byte >> 0 & 0xFF))
        append(UInt8(byte >> 8 & 0xFF))
    }
    internal  mutating func append(_ byte: UInt32) {
        append(UInt16(byte >>  0 & 0xFFFF))
        append(UInt16(byte >> 16 & 0xFFFF))
    }
    internal mutating func append(_  byte: UInt64) {
        append(UInt32(byte >>  0 & 0xFFFFFFFF))
        append(UInt32(byte >> 32 & 0xFFFFFFFF))
    }
    
    var bytes: [UInt8] {
        return Array(self)
        /* let count = self.count / MemoryLayout<UInt8>.size
         var bytesArray = [UInt8](repeating: 0, count: count)
         self.copyBytes(to:&bytesArray, count: count * MemoryLayout<UInt8>.size)
         return bytesArray*/
    }
    
    internal mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
