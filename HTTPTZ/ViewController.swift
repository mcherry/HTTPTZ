//
//  ViewController.swift
//  HTTPTZ
//
//  Created by Mike Cherry on 7/31/20.
//  Copyright © 2020 Mike Cherry. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    private var shotList: [File] = []
    private var stopShots = false
    private var imagePath = ""
    private let stopActions = ["Up", "Down", "Left", "Right", "ZoomWide", "ZoomTele", "FocusNear", "FocusFar"]
    
    @IBOutlet weak var chkSSL: NSButton!
    @IBOutlet weak var prgSpinner: NSProgressIndicator!
    @IBOutlet weak var txtServer: NSTextField!
    @IBOutlet weak var txtPort: NSTextField!
    @IBOutlet weak var txtUser: NSTextField!
    @IBOutlet weak var txtPass: NSSecureTextField!
    @IBOutlet weak var btnFocusNeg: NSButton!
    @IBOutlet weak var btnMoveUp: NSButton!
    @IBOutlet weak var btnFocusPos: NSButton!
    @IBOutlet weak var btnMoveLeft: NSButton!
    @IBOutlet weak var btnMoveRight: NSButton!
    @IBOutlet weak var btnZoomNeg: NSButton!
    @IBOutlet weak var btnMoveDown: NSButton!
    @IBOutlet weak var btnZoomPos: NSButton!
    @IBOutlet weak var btnPreset1: NSButton!
    @IBOutlet weak var btnPreset2: NSButton!
    @IBOutlet weak var btnPreset3: NSButton!
    @IBOutlet weak var btnPreset4: NSButton!
    @IBOutlet weak var btnPreset5: NSButton!
    @IBOutlet weak var btnPreset6: NSButton!
    @IBOutlet weak var btnPreset7: NSButton!
    @IBOutlet weak var btnPreset8: NSButton!
    @IBOutlet weak var btnPreset9: NSButton!
    @IBOutlet weak var btnSnapshot: NSButton!
    @IBOutlet weak var btnMultishot: NSButton!
    @IBOutlet weak var btnMultishots: NSButton!
    @IBOutlet weak var btnStop: NSButton!
    @IBOutlet weak var tblShots: NSTableView!
    @IBOutlet weak var lblCount: NSTextField!
    
    @IBAction func tblShots_DoubleClick(_ sender: Any) {
        let table = sender as! NSTableView
        AppKit.NSWorkspace.shared.openFile(self.imagePath + "/" + shotList[table.selectedRow].name)
    }
    
    @IBAction func ButtonClick(_ sender: Any) {
        guard let button = sender as? NSButton else { return }
        
        var command = "GotoPreset"
        var preset = "0";
        
        switch button.tag {
            case btns.Stop:       command = "Stop";       break
            case btns.Multishots: command = "Multishots"; break
            case btns.Multishot:  command = "Multishot";  break
            case btns.Snapshot:   command = "Snapshot";   break
            case btns.FocusNeg:   command = "FocusNear";  break
            case btns.Up:         command = "Up";         break
            case btns.FocusPos:   command = "FocusFar";   break
            case btns.Left:       command = "Left";       break
            case btns.Right:      command = "Right";      break
            case btns.ZoomNeg:    command = "ZoomWide";   break
            case btns.Down:       command = "Down";       break
            case btns.ZoomPos:    command = "ZoomTele";   break
            default: preset  = String(button.tag-7); break
        }
        
        let user = txtUser.stringValue
        let pass = txtPass.stringValue
        let address = txtServer.stringValue
        var port = txtPort.stringValue
        let ssl = chkSSL.integerValue
        
        if (port == "") { port = "80" }
        
        UserDefaults().set(user, forKey: "HTTPTZUser")
        UserDefaults().set(pass, forKey: "HTTPTZPass")
        UserDefaults().set(address, forKey: "HTTPTZServer")
        UserDefaults().set(port, forKey: "HTTPTZPort")
        UserDefaults().set(ssl, forKey: "HTTPTZUseSSL")
        
        let ptcol = (ssl == 0) ? "http" : "https"
        let url = ptcol+"://"+user+":"+pass+"@"+address+":"+port+"/cgi-bin/"
        
        moveCamera(code: command, preset: preset, baseURL: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fm = FileManager.default
        self.imagePath = (NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true)[0] as String) + "/HTTPTZ"
        
        if (!fm.fileExists(atPath: self.imagePath)) {
            try! fm.createDirectory(atPath: self.imagePath, withIntermediateDirectories: true, attributes: nil)
        }

        let items = try! fm.contentsOfDirectory(atPath: self.imagePath)
        for item in items {
            if (item != "." && item != ".." && item != ".DS_Store") {
                self.shotList.append(File(name: item, size: self.getFileSize(self.imagePath + "/" + item)))
            }
            
        }
        
        lblCount.stringValue = String(self.shotList.count) + " Snapshots"
        sortShots()

        txtUser.stringValue = UserDefaults().string(forKey: "HTTPTZUser") ?? ""
        txtPass.stringValue = UserDefaults().string(forKey: "HTTPTZPass") ?? ""
        txtServer.stringValue = UserDefaults().string(forKey: "HTTPTZServer") ?? ""
        txtPort.stringValue = UserDefaults().string(forKey: "HTTPTZPort") ?? ""
        chkSSL.integerValue = UserDefaults().integer(forKey: "HTTPTZUseSSL")
    }
    
    private func debug(_ message: String) {
        if _isDebugAssertConfiguration() {
            print(message)
        }
    }
    
    private func getFileSize(_ file: String) -> String {
        let attr = try! FileManager.default.attributesOfItem(atPath: file)
        return Units(bytes: Int64(truncating: NSNumber(value:attr[FileAttributeKey.size] as! UInt64))).getReadableUnit()
    }
    
    private func sortShots() {
        self.shotList.sort { $0.name > $1.name }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    private func httpGet(_ url: String) {
        guard let urlGet = URL(string: url) else {
            debug("Invalid URL: \(url)")
            return
        }

        do {
            let html = try String(contentsOf: urlGet, encoding: .ascii)
            debug("HTML : \(html)")
        } catch let error {
            debug("Error: \(error)")
        }
    }
    
    private func downloadSnapshot(url: URL, completion: @escaping (String?, Error?) -> Void) {
        let format = DateFormatter();
        format.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        let filename = format.string(from: Date())
        
        let destinationUrl = self.imagePath + "/" + filename + ".jpg"

        if FileManager().fileExists(atPath: destinationUrl) {
            debug("Snapshot exists: \(destinationUrl)")
            completion(destinationUrl, nil)
        } else if let dataFromURL = NSData(contentsOf: url) {
            if dataFromURL.write(to: URL(string: destinationUrl)!, atomically: true) {
                debug("Saved: \(destinationUrl)")
                completion(destinationUrl, nil)
            } else {
                debug("Error saving snapshot")
                let error = NSError(domain:"Error saving snapshot", code: 1001, userInfo: nil)
                completion(destinationUrl, error)
            }
        } else {
            let error = NSError(domain:"Error downloading snapshot", code: 1002, userInfo: nil)
            completion(destinationUrl, error)
        }
        
    }
    
    private func reloadShots() {
        DispatchQueue.main.async {
            self.tblShots.reloadData()
        }
    }
    
    private func inputControls(_ state: Bool = true) {
        DispatchQueue.main.async {
            let c = self.prgSpinner
            (state) ? c?.stopAnimation(self) : c?.startAnimation(self)
            
            self.txtServer.isEnabled = state
            self.txtPort.isEnabled = state
            self.txtUser.isEnabled = state
            self.txtPass.isEnabled = state
            self.chkSSL.isEnabled = state
        }
    }
    
    private func multishotControls(_ state: Bool = true) {
        DispatchQueue.main.async {
            self.btnSnapshot.isEnabled = state
            self.btnMultishots.isEnabled = state
        }
    }
    
    private func multishotsControls(_ state: Bool = true) {
        DispatchQueue.main.async {
            self.btnSnapshot.isEnabled = state
            self.btnMultishot.isEnabled = state
            
            self.btnStop.isHidden = (state) ? true : false
            self.btnMultishots.isHidden = (state) ? false : true
        }
    }
    
    private func snapshot(_ url: String) {
        self.downloadSnapshot(url: URL(string: url + "snapshot.cgi?channel=0")!) { (path, error) in
            self.debug("Downloaded: \(path!)")
            let fileName = (path! as NSString).lastPathComponent
            
            self.shotList.append(File(name: fileName, size: self.getFileSize(path!)))
            self.sortShots()
            self.reloadShots()
            
            DispatchQueue.main.async {
                self.lblCount.stringValue = String(self.shotList.count) + " Snapshots"
            }
        }
    }
    
    private func moveCamera(code: String, preset: String, baseURL: String) {
        DispatchQueue.global(qos: .background).async {
            self.inputControls(false)
            
            switch code {
                case "Snapshot":
                    self.snapshot(baseURL);
                    break;
                case "Multishot":
                    self.multishotControls(false);
                    for _ in 0...4 { self.snapshot(baseURL) }
                    self.multishotControls();
                    break;
                case "Multishots":
                    self.multishotsControls(false)
                    while self.stopShots == false { self.snapshot(baseURL); }
                    self.stopShots = false
                    break;
                case "Stop":
                    self.stopShots = true
                    self.multishotsControls()
                    break;
                default:
                    let startURL = "ptz.cgi?action=start&code="+code+"&channel=0&arg1=1&arg2="+preset+"&arg3=0"
                    self.httpGet(baseURL + startURL)
                    
                    if (self.stopActions.contains(code)) {
                        usleep(250000)
                        let stopURL = "ptz.cgi?action=stop&code="+code+"&channel=0&arg1=1&arg2="+preset+"&arg3=0"
                        self.httpGet(baseURL + stopURL)
                    }
                    
                    break;
            }
            
            self.inputControls()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.shotList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let userCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "userCell"), owner: self) as? CustomTableCell else { return nil }
        
        userCell.lblFilename.stringValue = self.shotList[row].name
        userCell.lblImagesize.stringValue = self.shotList[row].size
        userCell.imgThumb.image = NSImage(contentsOfFile: self.imagePath + "/" + self.shotList[row].name)
        
        return userCell
    }
    
}
