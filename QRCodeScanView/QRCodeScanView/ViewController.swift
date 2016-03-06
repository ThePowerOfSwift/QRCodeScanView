//
//  ViewController.swift
//  QRCodeScanView
//
//  Created by  lifirewolf on 16/3/6.
//  Copyright © 2016年  lifirewolf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var result: UILabel!
    
    @IBAction func scan(sender: AnyObject) {
        
        let scanViewController = ScanViewController()
        
        scanViewController.resultCalBack = { text in
            self.result.text = text
        }
        
        if let nav = navigationController {
            nav.pushViewController(scanViewController, animated: true)
        } else {
            presentViewController(scanViewController, animated: true, completion: nil)
        }
    }
    
}
