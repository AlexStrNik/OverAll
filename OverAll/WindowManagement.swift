//
//  WindowManagement.swift
//  OverAll
//
//  Created by Aleksandr Strizhnev on 28.03.2025.
//

import Foundation
import CoreGraphics
import AppKit

class WindowManagement {
    private var connectionId: UInt32 = 0
    private var superSpaceId: UInt64 = 0
    private var pinnedWindows: [UInt32: SLSWindow] = [:]
    
    public struct SLSWindow {
        let wid: UInt32
        let title: String
        let frame: CGRect
        let level: Int32
        let subLevel: Int32
        let spaceId: UInt64
        let preview: NSImage?
        var isPinned: Bool
    }
    
    public struct SLSApplication {
        let pid: Int32
        let psn: ProcessSerialNumber
        let connectionId: UInt32
    }
    
    private init() {
        self.connectionId = SLSMainConnectionID()
        self.gainUniversalOwner()
        self.superSpaceId = createSuperSpace()
        self.registerForNotifications()
    }
    
    typealias ConnectionCallback = @convention(c) (
        UInt32, UnsafeMutableRawPointer?, UInt32, UnsafeMutableRawPointer?
    ) -> Void

    
    private func registerForNotifications() {
        let connectionHandler: ConnectionCallback = { (type, data, data_length, context) in
            WindowManagement.default.repinWindows()
        }
        
        SLSRegisterNotifyProc(connectionHandler, 817, nil)
    }

    private func repinWindows() {
        for window in self.pinnedWindows.values {
            self.pin(window: window)
        }
    }
    
    private func gainUniversalOwner() {
        var connection: UInt32 = 0
        SLSNewConnection(0, &connection)
        
        let dock = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock")[0]
        kill(dock.processIdentifier, SIGKILL)
        
        SLSSetUniversalOwner(connection)
        SLSSetOtherUniversalConnection(connection, self.connectionId)
        SLSReleaseConnection(connection)
    }
    
    private func createSuperSpace() -> UInt64 {
        let space = SLSSpaceCreate(self.connectionId, 1, nil)
        
        SLSSpaceSetAbsoluteLevel(self.connectionId, space, 0)
        
        let spaceNumber = NSNumber(value: space)
        let spaceList = [spaceNumber] as CFArray
        
        SLSShowSpaces(self.connectionId, spaceList)
        
        return spaceNumber.uint64Value
    }
    
    private func spaceIdentifiers() -> [uint64] {
        let displaySpacesInfo = SLSCopyManagedDisplaySpaces(self.connectionId).takeRetainedValue() as NSArray
        var spaces: [uint64] = []
        
        for item in displaySpacesInfo {
            guard let info = item as? [String: AnyObject] else {
                continue
            }
            
            guard let spacesInfo = info["Spaces"] as? [[String: AnyObject]] else {
                continue
            }
            
            for spaceInfo in spacesInfo {
                guard let id = spaceInfo["ManagedSpaceID"] as? uint64 else {
                    continue
                }
                
                spaces.append(id)
            }
        }
        
        return spaces
    }
    
    private func applications() -> [SLSApplication] {
        var applications: [SLSApplication] = []
        
        for application in NSWorkspace.shared.runningApplications {
            var psn = application.psn
            
            var connection: Int32 = 0
            SLSGetConnectionIDForPSN(self.connectionId, &psn, &connection)
            if connection != 0 {
                applications.append(
                    SLSApplication(
                        pid: application.processIdentifier,
                        psn: psn,
                        connectionId: UInt32(connection)
                    )
                )
            }
        }
        
        return applications
    }
    
    private func windowsForApplication(_ application: SLSApplication, spaces: [UInt64]) -> [SLSWindow] {
        let options: UInt32 = 0x7
        var setTags: UInt64 = 0
        var clearTags: UInt64 = 0
        
        let windows = SLSCopyWindowsWithOptionsAndTags(
            self.connectionId,
            application.connectionId,
            spaces as CFArray,
            options,
            &setTags,
            &clearTags
        ).takeRetainedValue()
        
        let query = SLSWindowQueryWindows(
            self.connectionId,
            windows,
            Int32(CFArrayGetCount(windows))
        ).takeRetainedValue()
        let iterator = SLSWindowQueryResultCopyWindows(query).takeRetainedValue()
        
        var foundWindows = [UInt32]()
        
        while SLSWindowIteratorAdvance(iterator) {
            let attributes = SLSWindowIteratorGetAttributes(iterator)
            let tags = SLSWindowIteratorGetTags(iterator)
            let windowID = SLSWindowIteratorGetWindowID(iterator)
            
            if ((attributes & 0x2) != 0 || (tags & 0x400_0000_0000_0000) != 0)
                && (((tags & 0x1) != 0) || ((tags & 0x2) != 0 && (tags & 0x8000_0000) != 0))
            {
                foundWindows.append(windowID)
            } else if (attributes == 0x0 || attributes == 0x1)
                        && ((tags & 0x1000_0000_0000_0000) != 0 || (tags & 0x300_0000_0000_0000) != 0)
                        && (((tags & 0x1) != 0) || ((tags & 0x2) != 0 && (tags & 0x8000_0000) != 0))
            {
                foundWindows.append(windowID)
            }
        }
        
        return foundWindows.compactMap { windowID in
            var title: Unmanaged<CFTypeRef>?
            
            SLSCopyWindowProperty(
                self.connectionId,
                windowID,
                "kCGSWindowTitle" as CFString,
                &title
            );
            
            if let title {
                let titleUnwrapped = title.takeRetainedValue() as! CFString
                var frame: CGRect = CGRect.zero
                var level: Int32 = 0
                var subLevel: Int32 = 0
                
                SLSGetWindowBounds(self.connectionId, windowID, &frame)
                SLSGetWindowLevel(self.connectionId, windowID, &level)
                subLevel = SLSGetWindowSubLevel(self.connectionId, windowID)
                
                let spaces = SLSCopySpacesForWindows(
                    self.connectionId, 0x7, [windowID] as CFArray
                ).takeRetainedValue() as NSArray as! [UInt64]
                
                let isPinned = pinnedWindows.keys.contains(windowID)
                let pinnedWindow = self.pinnedWindows[windowID]
                
                return SLSWindow(
                    wid: windowID,
                    title: titleUnwrapped as String,
                    frame: frame,
                    level: level,
                    subLevel: subLevel,
                    spaceId: isPinned ? pinnedWindow!.spaceId : spaces[0],
                    preview: isPinned ? pinnedWindow!.preview : self.captureImage(for: windowID),
                    isPinned: isPinned
                )
            }
            
            return nil
        }
    }
    
    private func captureImage(for window: UInt32) -> NSImage? {
        var windowIds = [window]
        let arrayRef = windowIds.withUnsafeMutableBufferPointer { ptr in
            SLSHWCaptureWindowList(self.connectionId, ptr.baseAddress, 1, 0)
        }
        if arrayRef == nil {
            return nil
        }
        let array = arrayRef!.takeUnretainedValue() as NSArray
        defer { arrayRef?.release() }
        
        guard array.count == 1 else { return nil }

        let image = array[0] as! CGImage
        return NSImage(
            cgImage: image,
            size: NSSize(width: image.width, height: image.height)
        )
    }
}

extension WindowManagement {
    public static var `default` = WindowManagement.init()

    func allWindows() -> [SLSWindow] {
        var spaces = self.spaceIdentifiers()
        spaces.append(UInt64(self.superSpaceId))
        
        let applications = applications()
        
        var windows: [SLSWindow] = []
        
        for application in applications {
            windows.append(contentsOf: windowsForApplication(application, spaces: spaces))
        }
        
        return windows
    }
    
    func pin(window: SLSWindow) -> Void {
        SLSSpaceAddWindowsAndRemoveFromSpaces(
            self.connectionId,
            self.superSpaceId,
            [window.wid] as CFArray,
            0x7
        )
        
        SLSSetWindowLevel(
            self.connectionId, window.wid, Int32(NSWindow.Level.floating.rawValue)
        )
        SLSSetWindowSubLevel(
            self.connectionId, window.wid, Int32(NSWindow.Level.floating.rawValue)
        )

        SLSOrderWindow(self.connectionId, window.wid, 1, 0)
        
        pinnedWindows[window.wid] = window
    }
    
    func unpin(window: SLSWindow) -> Void {
        SLSRemoveWindowsFromSpaces(
            self.connectionId,
            [window.wid] as CFArray,
            [self.superSpaceId] as CFArray
        )
        SLSMoveWindowsToManagedSpace(
            self.connectionId,
            [window.wid] as CFArray,
            window.spaceId
        )
        
        SLSSetWindowLevel(
            self.connectionId, window.wid, window.level
        )
        SLSSetWindowSubLevel(
            self.connectionId, window.wid, window.subLevel
        )
        
        pinnedWindows.removeValue(forKey: window.wid)
    }
    
    func unpinAll() -> Void {
        for (_, window) in pinnedWindows {
            self.unpin(window: window)
        }
    }
}
