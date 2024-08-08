//
// WindowController.swift
//

import QuickLookUI
import Cocoa

class WindowController: NSWindowController {
	static var NextWindowTopLeft: NSPoint = NSZeroPoint
	static var WindowControllers: [WindowController] = []
	
	override func windowDidLoad() {
		super.windowDidLoad()
	}
	
	// MARK: - QLPreviewPanel
	
	override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
		return true
	}
	
	override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
		MainActor.assumeIsolated {
			
			panel.delegate = self.contentViewController as! ViewController
			panel.dataSource = self.contentViewController as! ViewController
			QLPreviewPanel.shared().reloadData()
		}
	}
	
	override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
		MainActor.assumeIsolated {
			
			panel.delegate = nil
			panel.dataSource = nil
		}
	}
	
	// MARK: -
}

extension WindowController: NSWindowDelegate {
	
	func windowWillClose(_ notification: Notification) {
		// ウィンドウコントローラを削除
		for i: Int in 0..<WindowController.WindowControllers.count {
			if WindowController.WindowControllers[i] == self {
				WindowController.WindowControllers.remove(at: i)
				break
			}
		}
	}
	
}


