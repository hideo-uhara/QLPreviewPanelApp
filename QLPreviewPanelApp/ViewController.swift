//
// ViewController.swift
//

import QuickLookUI
import Cocoa

protocol QLTableViewProtocol {
	func toggleQLPreviewPanel()
}

extension QLTableViewProtocol {
	
	func toggleQLPreviewPanel() {
		
		if QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible {
			QLPreviewPanel.shared().orderOut(self)
		} else {
			QLPreviewPanel.shared().makeKeyAndOrderFront(self)
		}
	}
	
}

class QLTableView: NSTableView {
	@IBOutlet var viewController: NSViewController!
	
	override func keyDown(with event: NSEvent) {
		let key: String? = event.charactersIgnoringModifiers
		  
		if key == " " {
			(self.viewController as? QLTableViewProtocol)?.toggleQLPreviewPanel()
		} else {
			super.keyDown(with: event)
		}
	}
	
}

class ViewController: NSViewController, QLTableViewProtocol {
	let fileURLList: [URL] = [
		Bundle.main.url(forResource: "IMG_3802", withExtension: "jpeg")!,
		Bundle.main.url(forResource: "34", withExtension: "csv")!,
		Bundle.main.url(forResource: "IMG_3809", withExtension: "jpeg")!,
		Bundle.main.url(forResource: "IMG_3813", withExtension: "jpeg")!,
	]
	
	@IBOutlet var tableView: NSTableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override var representedObject: Any? {
		didSet {
		}
	}
	
	@IBAction func reloadAction(_ sender: Any?) {
		self.tableView.reloadData()
		
		if QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible {
			QLPreviewPanel.shared().reloadData()
		}
		
	}
	
}

extension ViewController: NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.fileURLList.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let tableCellView: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TableCellView"), owner: nil) as! NSTableCellView
		let imageView: NSImageView = tableCellView.viewWithTag(1) as! NSImageView
		let textField: NSTextField = tableCellView.viewWithTag(2) as! NSTextField
		
		if #available(macOS 13.0, *) {
			imageView.image = NSWorkspace.shared.icon(forFile: self.fileURLList[row].path(percentEncoded: false))
		} else {
			imageView.image = NSWorkspace.shared.icon(forFile: self.fileURLList[row].path)
		}
		
		textField.stringValue = self.fileURLList[row].lastPathComponent
		
		return tableCellView
	}

}

extension ViewController: NSTableViewDelegate {
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		if QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible {
			QLPreviewPanel.shared().reloadData()
		}
	}
	
	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		return 24.0
	}
	
}

extension ViewController: QLPreviewPanelDataSource {
	
	func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
		return self.tableView.selectedRow == -1 ? 0 : 1
	}
	
	func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
		let url: URL = self.fileURLList[self.tableView.selectedRow]
		
		if #available(macOS 13.0, *) {
			return NSURL(fileURLWithPath: url.path(percentEncoded: false))
		} else {
			return NSURL(fileURLWithPath: url.path)
		}
	}
	
}

extension ViewController: QLPreviewPanelDelegate {
	
	func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
		
		if event.type == .keyDown { // キーダウンイベントは、TableViewにリダイレクト

			self.tableView.keyDown(with: event)
			
			return true
		} else {
			return false
		}
	}
	
	func previewPanel(_ panel: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
		var rect: NSRect = NSZeroRect
		
		if self.tableView.selectedRow != -1 {
			let iconX: CGFloat = 10.0
			let iconY: CGFloat = 4.0
			let iconWidth: CGFloat = 16.0
			let visibleRect: NSRect = self.tableView.visibleRect
			let cellRect: NSRect = self.tableView.frameOfCell(atColumn: 0, row: self.tableView.selectedRow)
			let iconRect: NSRect = NSRect(x: cellRect.origin.x + iconX, y: cellRect.origin.y + iconY, width: iconWidth, height: iconWidth)
			
			if NSIntersectsRect(visibleRect, iconRect) {
				rect = self.tableView.convert(iconRect, to: nil)
				rect.origin = (self.tableView.window?.convertPoint(toScreen: rect.origin))!
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
