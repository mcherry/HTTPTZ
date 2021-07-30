//
//  Structs.swift
//  HTTPTZ
//
//  Created by Michael Cherry on 4/21/21.
//  Copyright © 2021 Mike Cherry. All rights reserved.
//

import Foundation

struct File {
    var name: String
    var size: String
}

struct btns {
    static let FocusNeg   = 0
    static let Up         = 1
    static let FocusPos   = 2
    static let Left       = 3
    static let Right      = 4
    static let ZoomNeg    = 5
    static let Down       = 6
    static let ZoomPos    = 7
    static let Preset1    = 8
    static let Preset2    = 9
    static let Preset3    = 10
    static let Preset4    = 11
    static let Preset5    = 12
    static let Preset6    = 13
    static let Preset7    = 14
    static let Preset8    = 15
    static let Preset9    = 16
    static let Snapshot   = 17
    static let Multishot  = 18
    static let Multishots = 19
    static let Stop       = 20
}

struct Units {
  public let bytes: Int64
  
  public var kilobytes: Double {
    return Double(bytes) / 1_024
  }
  
  public var megabytes: Double {
    return kilobytes / 1_024
  }
  
  public var gigabytes: Double {
    return megabytes / 1_024
  }
  
  public init(bytes: Int64) {
    self.bytes = bytes
  }
  
  public func getReadableUnit() -> String {
    switch bytes {
        case 0..<1_024:
          return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
          return "\(String(format: "%.2f", kilobytes)) KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
          return "\(String(format: "%.2f", megabytes)) MB"
        case (1_024 * 1_024 * 1_024)...Int64.max:
          return "\(String(format: "%.2f", gigabytes)) GB"
        default:
          return "\(bytes) bytes"
    }
  }
}
