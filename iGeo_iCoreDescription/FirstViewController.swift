//
//  FirstViewController.swift
//  iGeo_iCoreDescription
//
//  Created by Nathaniel Jones on 1/23/15.
//  Copyright (c) 2015 Nate Geo LLC. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func testPhoto(sender: AnyObject) {
       // var testOverlay = CorePhotoOverlay()
       // testOverlay.testLabel = UILabel(frame: CGRect(origin: CGPoint(x: view.frame.size.width * 0.5, y: view.frame.size.height * 0.5), size: CGSize(width: 300.0, height: 300.0)))
       // testOverlay.testLabel.text = "Testing!"
      //  testOverlay.opaque = false
      //  testOverlay.frame = CGRect(origin: CGPoint(x: view.frame.size.width * 0.5, y: view.frame.size.height * 0.5), size: CGSize(width: 300.0, height: 300.0))
        var imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        var subviews = imagePicker.view.subviews
        
        let overlayView = UIImageView(image: testImage(self.view.frame))
        imagePicker.cameraOverlayView = overlayView
        //imagePicker.cameraOverlayView = testOverlay
        self .presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: Image picker delegate methods
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //nothing yet
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //nothing yet
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        //nothing yet
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: Image Overlay Tests
    func testImage(rect : CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        //create box
        CGContextMoveToPoint(context, 4.0, 4.0)
        CGContextAddLineToPoint(context, 4.0, rect.size.height - 4.0)
        CGContextAddLineToPoint(context, rect.size.width * 0.5, rect.size.height - 4.0)
        CGContextAddLineToPoint(context, rect.size.width * 0.5, 4.0)
        CGContextClosePath(context)
        //set line width
        CGContextSetLineWidth(context, 8.0)
        //var colorspace = CGColorSpaceCreateDeviceRGB()
        var colors : [CGFloat] = [1.0,1.0, 1.0, 1.0]
        //var color = CGColorCreate(colorspace, colors)
        CGContextSetStrokeColor(context, colors)
        CGContextStrokePath(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
        
    }
    
}

