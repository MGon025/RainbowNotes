//
//  SettingsViewController.swift
//  iNote
//
//  Created by Mark Gonzalez on 5/16/21.
//

import UIKit

var rtx: Bool = false

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // toggles stylized note list and detail view
    // A message might pop up when using the switch, apparently this is just a harmless bug with the UISwitch
    @IBAction func toggleRTX(_ sender: UISwitch) { rtx = !rtx }
}
