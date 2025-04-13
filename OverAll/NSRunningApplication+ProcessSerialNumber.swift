//
//  NSRunningApplication+ProcessSerialNumber.swift
//  OverAll
//
//  Created by Aleksandr Strizhnev on 04.04.2025.
//

import AppKit

extension NSRunningApplication {
    var psn: ProcessSerialNumber {
        let ivar = class_getInstanceVariable(NSRunningApplication.self, "_asn")
        if let ivar = ivar {
            let lasnRef = object_getIvar(self, ivar) as CFTypeRef
            
            var psn = _LSASNToUInt64(lasnRef)
            psn.lowLongOfPSN = psn.highLongOfPSN
            psn.highLongOfPSN = 0
            
            return psn
        } else {
            fatalError()
        }
    }
}
