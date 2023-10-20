//
// AppDelegate.swift
//

import QuickLookUI
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		self.newDocument(self)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}
	
	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
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
	
	@IBAction func newDocument(_ sender: Any?) {
		let windowController: WindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "WindowController") as! WindowController
		
		WindowController.WindowControllers.append(windowController)
		WindowController.NextWindowTopLeft = windowController.window!.cascadeTopLeft(from: WindowController.NextWindowTopLeft)
		windowController.showWindow(self)
	}
	
}

extension AppDelegate: QLPreviewPanelDataSource {
	
	func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
		return 0
	}
	
	func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
		return NSURL() // ダミー
	}

}

