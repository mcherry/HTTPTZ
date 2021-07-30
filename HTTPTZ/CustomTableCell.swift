//
//  CustomTableCell.swift
//  HTTPTZ
//
//  Created by Michael Cherry on 3/29/21.
//  Copyright © 2021 Mike Cherry. All rights reserved.
//

import Cocoa

class CustomTableCell: NSTableCellView {

    @IBOutlet weak var lblImagesize: NSTextField!
    @IBOutlet weak var lblFilename: NSTextField!
    @IBOutlet weak var imgThumb: NSImageView!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
