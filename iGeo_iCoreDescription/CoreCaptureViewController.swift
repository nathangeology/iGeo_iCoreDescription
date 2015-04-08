//
//  CoreCaptureViewController.swift
//  iGeo_iCoreDescription
//
//  Created by Nathaniel Jones on 2/8/15.
//  Copyright (c) 2015 Nate Geo LLC. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

let SessionRunningAndDeviceAuthorizedContext = UnsafeMutablePointer<()>()
let CapturingStillImageContext = UnsafeMutablePointer<()>()

class CoreCaptureViewController: UIViewController, UIAlertViewDelegate {
    //AV Session Management
    var session : AVCaptureSession!
    var deviceInput : AVCaptureDeviceInput!
    var deviceOuput : AVCaptureStillImageOutput!
    var sessionQueue: dispatch_queue_t!
    //Utility Properties
    var backgroundRecordingID : UIBackgroundTaskIdentifier!
    var deviceAuthorized : Bool = false
    var runtimeErrorHandlingObserver : AnyObject?
    //Storyboard Outlets
    @IBOutlet weak var previewView: AVCamPreviewView!
    /*
// MARK: - ViewController Methods
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create the AVCaptureSession
        session = AVCaptureSession()
        session.startRunning()
        
        // Setup the preview view
        previewView.session = session
        
        //check device authorization status
        checkDeviceAuthorizationStatus()
        
        // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
        // Why not do all of this on the main queue?
        // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
        
        sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
        
        dispatch_async(sessionQueue) {
            self.backgroundRecordingID = UIBackgroundTaskInvalid
            var error : NSError? = nil
            var videoDevice = CoreCaptureViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Back)
            var videoDeviceInput = AVCaptureDeviceInput(device: videoDevice, error: &error)
            if((error) != nil) {
                println("\(error)")
            }
            if self.session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
                dispatch_async(dispatch_get_main_queue()) {
                    () -> () in
                    var layer = self.previewView.layer as AVCaptureVideoPreviewLayer
                    var connection = layer.connection
                    switch(self.interfaceOrientation) {
                    case .LandscapeLeft:
                        connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
                        break
                    case .LandscapeRight:
                        connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
                        break
                    case .Portrait:
                        connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                        break
                    case .PortraitUpsideDown:
                        connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
                        break
                    case .Unknown:
                        break
                
                    }
                    //connection.videoOrientation = self.interfaceOrientation.rawValue as AVCaptureVideoOrientation
                }
            }
            var stillImageOutput = AVCaptureStillImageOutput()
            if self.session.canAddOutput(stillImageOutput) {
                stillImageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                self.session.addOutput(stillImageOutput)
                self.deviceOuput = stillImageOutput
            }
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        //setup up async listeners 
        dispatch_async(sessionQueue) { () -> () in
            
            self.addObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", options: (NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New), context: SessionRunningAndDeviceAuthorizedContext)
            self.addObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", options: (NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New), context: CapturingStillImageContext)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.deviceInput.device)
            //setup runtime handling error
            self.runtimeErrorHandlingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionRuntimeErrorNotification, object: self.session, queue: nil) {
                (note : NSNotification!) -> () in
                self.session.startRunning()
                //TODO: Set recording button title when it is added via storyboards
                
            }
            self.session.startRunning()
        }
        
        
    }
    override func viewWillDisappear(animated: Bool) {
        dispatch_async(sessionQueue) { () -> () in
          self.session.stopRunning()
          NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.deviceInput.device)
          NSNotificationCenter.defaultCenter().removeObserver(self.runtimeErrorHandlingObserver!)
          self.removeObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", context: SessionRunningAndDeviceAuthorizedContext)
            self.removeObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", context: CapturingStillImageContext)
            
        }
        
    }
    //MARK: - Interface overrides
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    override func shouldAutorotate() -> Bool {
        //FIXME: need to implement this method
        return self.shouldAutorotate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Handle Interface Rotation
    override func supportedInterfaceOrientations() -> Int {
        let returnVal : Int =  Int(UIInterfaceOrientationMask.All.rawValue)
        return returnVal
    }
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let layer = self.previewView.layer as AVCaptureVideoPreviewLayer
        layer.connection.videoOrientation = AVCaptureVideoOrientation(rawValue: toInterfaceOrientation.rawValue)!
    }
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
       
        if( context == CapturingStillImageContext) {
            var isCapturingStillImage : Bool = change[NSKeyValueChangeNewKey] as Bool
            
            if(isCapturingStillImage) {
                //FIXME: Need to implement this function
                //self.runStillImageCaptureAnimation()
            }
        } else if(context == SessionRunningAndDeviceAuthorizedContext)
        {
            var isRunning : Bool = change[NSKeyValueChangeNewKey] as Bool
            dispatch_async(dispatch_get_main_queue()) {
                () -> () in
                if(isRunning) {
                    //FIXME: self enable buttons associated with image capture
                    println("Ready to go!");
                }else
                {
                    //FIXME: disable buttons associated with image capture
                    println("Not ready yet!");
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    //MARK: - Actions
    @IBAction func test(sender: AnyObject) {
        //test snapping a still image
        dispatch_async(self.sessionQueue) {
            () -> () in
            // Update the orientation on the still image output video connection before capturing.
            var mediaConnection = self.deviceOuput.connectionWithMediaType(AVMediaTypeVideo)!
            var videoView = self.previewView.layer as AVCaptureVideoPreviewLayer
            mediaConnection.videoOrientation = videoView.connection.videoOrientation
            
            // Flash set to Auto for Still Capture
        CoreCaptureViewController.setFlashMode(AVCaptureFlashMode.Auto, forDevice: self.deviceInput.device)
            
            // Capture a still image.
            self.deviceOuput.captureStillImageAsynchronouslyFromConnection(self.deviceOuput.connectionWithMediaType(AVMediaTypeVideo)) {
                (imageDataSampleBuffer : CMSampleBuffer!, error : NSError!) -> () in
                if((imageDataSampleBuffer) != nil) {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    var image = UIImage(data: imageData)
                    //PHPhotoLibrary.sharedPhotoLibrary().
                }
            }
            //TODO: Left off here!!
        }
    }
    //func snapStillImage(sender : AnyObject) -> IBAction {
        
    //}
    
    //MARK: File Output Delegate
    
   
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: - Device Configuration
    class func deviceWithMediaType( mediaType : String, preferringPosition position : AVCaptureDevicePosition) ->AVCaptureDevice {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice = devices[0] as AVCaptureDevice
        for device in devices {
            if device.position! == position {
                captureDevice = device as AVCaptureDevice
                break;
            }
        }
        return captureDevice
    }
    class func setFlashMode(flashMode : AVCaptureFlashMode, forDevice device : AVCaptureDevice) {
        //FIXME: Needs implementation
    }
    //MARK: - UI
    func checkDeviceAuthorizationStatus() -> () {
        var mediaType = AVMediaTypeVideo
        AVCaptureDevice.requestAccessForMediaType(mediaType)   { (granted : Bool) -> () in
            if(granted) {
                self.deviceAuthorized = true
            } else {
                dispatch_async(dispatch_get_main_queue()) { ()->() in
                    let alert = UIAlertController(title: "Core Image Viewer", message: "Core Image viewer does not have permission to access the camera, change privacy settings to use this feature.", preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.deviceAuthorized = false
                }
            }
        }
    }
    //MARK: - Actions
    @objc func subjectAreaDidChange(notification : NSNotification) {
        //TODO: Need to implement this method
    }
}
