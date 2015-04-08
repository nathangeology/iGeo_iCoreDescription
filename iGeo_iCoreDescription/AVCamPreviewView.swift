//
//  AVCamPreviewView.swift
//  iGeo_iCoreDescription
//
//  Created by Nathaniel Jones on 2/8/15.
//  Copyright (c) 2015 Nate Geo LLC. All rights reserved.
//

import UIKit
import AVFoundation
class AVCamPreviewView: UIView {
    var session : AVCaptureSession! {
        get {
            var aLayer = self.layer as AVCaptureVideoPreviewLayer
            return  aLayer.session
        }
        set (newSession) {
            var aLayer = self.layer as AVCaptureVideoPreviewLayer
            aLayer.session = newSession
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.classForCoder()
    }
    
}
