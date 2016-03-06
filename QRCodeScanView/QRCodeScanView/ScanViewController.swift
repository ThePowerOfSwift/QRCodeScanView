//
//  ScanViewController.swift
//  QRCodeScanView
//
//  Created by  lifirewolf on 16/3/3.
//  Copyright © 2016年  lifirewolf. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController {
    
    var preview: UIView!
    var blurView: UIView!
    var scanWindow: UIView!
    
    var mask: CAShapeLayer!
    
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    let session = AVCaptureSession()
    let output = AVCaptureMetadataOutput()
    var layer: AVCaptureVideoPreviewLayer!
    
    var resultCalBack: ((String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupAVFoundation()
    }
    
    func setupUI() {
        
        preview = UIView()
        preview.backgroundColor = UIColor.whiteColor()
        preview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(preview)
        
        var views = ["preview": preview]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[preview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[preview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        
        //        blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView = UIView()
        blurView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        
        views = ["blurView": blurView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[blurView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[blurView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        
        scanWindow = UIView()
        scanWindow.backgroundColor = UIColor.clearColor()
        scanWindow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanWindow)
        
        let side = CGFloat(250)
        scanWindow.addConstraint(NSLayoutConstraint(item: scanWindow, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: side))
        scanWindow.addConstraint(NSLayoutConstraint(item: scanWindow, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: scanWindow, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: scanWindow, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scanWindow, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // add blur view mask
        mask = CAShapeLayer()
        mask.fillRule = kCAFillRuleEvenOdd
        blurView.layer.mask = mask
    }
    
    func setupAVFoundation() {
        
        // input
        let input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: device)
            
        } catch let error as NSError {
            print(error)
            return
        }
        
        session.addInput(input)
        
        // output
        
        session.addOutput(output)
        
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        // add preview layer
        layer = AVCaptureVideoPreviewLayer(session: session)
        
        preview.layer.addSublayer(layer)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // layout preview layer
        layer.frame = preview.bounds
        layer.position = CGPointMake(CGRectGetMidX(preview.bounds), CGRectGetMidY(preview.bounds))
        
        // configure blur view mask layer
        mask.frame = blurView.bounds
        
        let outRectangle = UIBezierPath(rect: blurView.bounds)
        
        var inRect = scanWindow.convertRect(scanWindow.bounds, toView: blurView)
        
        let inRectangle = UIBezierPath(rect: inRect)
        
        outRectangle.appendPath(inRectangle)
        
        outRectangle.usesEvenOddFillRule = true
        mask.path = outRectangle.CGPath
        
        inRect = scanWindow.convertRect(scanWindow.bounds, toView: preview)
        
        let x = inRect.origin.x / preview.bounds.width
        let y = inRect.origin.y / preview.bounds.height
        let w = inRect.width / preview.bounds.width
        let h = inRect.origin.y / preview.bounds.height
        
        let rect = CGRect(x: y, y: x, width: h, height: w)
        output.rectOfInterest = rect
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // start
        session.startRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //        print("=====")
        //        let inRect = scanWindow.convertRect(scanWindow.bounds, toView: blurView)
        //
        //        let t = output.metadataOutputRectOfInterestForRect(inRect)
        //        print(t)
        //        let tt = layer.metadataOutputRectOfInterestForRect(inRect)
        //        print(tt)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop
        session.stopRunning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if nil != navigationController {
            return false
        }
        return true
    }
    
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if let objs = metadataObjects as? [AVMetadataMachineReadableCodeObject] {
            for metadata in objs {
                if metadata.type == AVMetadataObjectTypeQRCode {
                    print(metadata.stringValue)
                    
                    resultCalBack?(metadata.stringValue)
                    
                    if let nav = navigationController {
                        nav.popToRootViewControllerAnimated(true)
                    } else {
                        dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        }
    }
}
