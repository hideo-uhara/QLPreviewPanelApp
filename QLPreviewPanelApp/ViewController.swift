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

