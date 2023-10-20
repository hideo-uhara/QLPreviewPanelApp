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
		panel.delegate = self
		panel.dataSource = self
		QLPreviewPanel.shared().reloadData()
	}
	
	override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
		panel.delegate = nil
		panel.dataSource = nil
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

extension WindowController: QLPreviewPanelDataSource {
	
	func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
		let viewController: ViewController = self.contentViewController as! ViewController
		let tableView: NSTableView = viewController.tableView
		
		return tableView.selectedRow == -1 ? 0 : 1
	}
	
	func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
		let viewController: ViewController = self.contentViewController as! ViewController
		let url: URL = viewController.fileURLList[viewController.tableView.selectedRow]
		
		if #available(macOS 13.0, *) {
			return NSURL(fileURLWithPath: url.path(percentEncoded: false))
		} else {
			return NSURL(fileURLWithPath: url.path)
		}
	}
	
}

extension WindowController: QLPreviewPanelDelegate {
	
	func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
		
		if event.type == .keyDown { // キーダウンイベントは、TableViewにリダイレクト
			let viewController: ViewController = self.contentViewController as! ViewController
			let tableView: NSTableView = viewController.tableView
			
			tableView.keyDown(with: event)
			
			return true
		} else {
			return false
		}
	}
	
	func previewPanel(_ panel: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
		let viewController: ViewController = self.contentViewController as! ViewController
		let tableView: NSTableView = viewController.tableView
		var rect: NSRect = NSZeroRect
		
		if tableView.selectedRow != -1 {
			let iconX: CGFloat = 10.0
			let iconY: CGFloat = 4.0
			let iconWidth: CGFloat = 16.0
			let visibleRect: NSRect = tableView.visibleRect
			let cellRect: NSRect = tableView.frameOfCell(atColumn: 0, row: tableView.selectedRow)
			let iconRect: NSRect = NSRect(x: cellRect.origin.x + iconX, y: cellRect.origin.y + iconY, width: iconWidth, height: iconWidth)
			
			if NSIntersectsRect(visibleRect, iconRect) {
				rect = tableView.convert(iconRect, to: nil)
				rect.origin = (tableView.window?.convertPoint(toScreen: rect.origin))!
			}
		}
		
		return rect
	}
	
	func previewPanel(_ panel: QLPreviewPanel!, transitionImageFor item: QLPreviewItem!, contentRect: UnsafeMutablePointer<NSRect>!) -> Any! {
		var image: NSImage! = nil
		
		if #available(macOS 13.0, *) {
			image = NSWorkspace.shared.icon(forFile: item.previewItemURL.path(percentEncoded: false))
		} else {
			image = NSWorkspace.shared.icon(forFile: item.previewItemURL.path)
		}
		
		return image
	}
	
}

