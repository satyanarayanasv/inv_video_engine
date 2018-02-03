//
//  SingleImageTemplate.swift
//  vcreator
//
//  Created by Inwiter on 25/01/18.
//  Copyright © 2018 satya. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

class SingleImageTemplate {
    
    var sourceImageUrl:NSURL?
    var backgroundVideoUrl:URL?
    var vasset1:AVURLAsset
    let composition = AVMutableComposition()
    let videoComposition = AVMutableVideoComposition()
    var renderDuration = CMTimeMakeWithSeconds(59, 600)
    init() {
        vasset1 = AVURLAsset.init(url: Constants.BLANK_VIDEO_SINGLE_IMAGE_TEMPLETE)
    }
    func prepareTemplate(imageUrl:NSURL, backgroundVideoUrl:URL?)  {
        sourceImageUrl = imageUrl
        if let videoUrl = backgroundVideoUrl {
            self.backgroundVideoUrl = videoUrl
        }
    }
    func prepareTracks() {
        let vTrack1 = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let vt1 = vasset1.tracks(withMediaType: AVMediaType.video)[0]
        do
        {
//            renderDuration = vasset1.duration
            try vTrack1?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, renderDuration), of: vt1, at: kCMTimeZero)
        }
        catch {
            print (error)
        }
    }
    func prepareAnimationTool() {
        guard  let imageUrl = sourceImageUrl  else { return  }
        
        
        let animationLayer = CALayer.init()
        animationLayer.frame = CGRect.init(x: 0, y: 0, width: Constants.renderSize.width, height: Constants.renderSize.height)
        let backgroundLayer = CATiledLayer.init()
        backgroundLayer.frame = animationLayer.frame
        guard let originalImage = NSImage.init(contentsOf: imageUrl as URL) else {
            print("original image not created")
            return
        }
        
        var isPortrait = false
        if (CGFloat(originalImage.size.height) / CGFloat(originalImage.size.width)) != 9.0/16.0  {
            isPortrait = true
            if let croppedImage = ImageUtils.crop(url: imageUrl as URL, toSize: Constants.renderSize) {
                backgroundLayer.contents = croppedImage
                let blurFilter:CIFilter = CIFilter.init(name: "CIGaussianBlur")!
                blurFilter.setDefaults()
                blurFilter.setValue(10.0, forKey: "inputRadius")
                blurFilter.name = "blur"
                backgroundLayer.filters = [blurFilter]
                
                animationLayer.addSublayer(backgroundLayer)
                
                
            }
            
        }
        var imageSize = CGSize.init(width: originalImage.size.width, height: originalImage.size.height)
        imageSize = ImageUtils.getAspectSize(imageSize: imageSize, scale: isPortrait ? 0.8 : 1.0)
        let imageLayer = CALayer()
        let y:CGFloat = (CGFloat(Constants.FINAL_VIDEO_HEIGHT) - imageSize.height) / 2
        let x:CGFloat = (CGFloat(Constants.FINAL_VIDEO_WIDTH) - imageSize.width) / 2
        imageLayer.frame = CGRect.init(x: x, y: y, width: imageSize.width, height: imageSize.height)
        imageLayer.contents = originalImage
        
        animationLayer.addSublayer(imageLayer)
        
        let videoLayer = CALayer.init()
        videoLayer.frame = CGRect.init(x: 0, y: 0, width: Constants.renderSize.width, height: Constants.renderSize.height)
        let parentLayer = CALayer.init()
        parentLayer.frame = CGRect.init(x: 0, y: 0, width: Constants.renderSize.width, height: Constants.renderSize.height)
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(animationLayer)
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        print("Animation layer is prepared")
        
    }
    
    func prepareCompositionInstructions() {
        
        videoComposition.renderSize = composition.naturalSize
        videoComposition.frameDuration = CMTimeMake(1, 25)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.enablePostProcessing = true
        let instructionLayer1 = AVMutableVideoCompositionLayerInstruction.init(assetTrack: composition.tracks[0])
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, renderDuration)
        instruction.layerInstructions = [ instructionLayer1]
        videoComposition.instructions = [instruction]
        
    }
    
    func processTemplate()  {
        prepareTracks()
        prepareCompositionInstructions()
        prepareAnimationTool()
        
    }
    func renderTemplate(filePath:NSURL, completion:@escaping (URL) -> Void, failure:@escaping (String) -> Void) {
        var isRenderedSuccessfully = false
        let session = AVAssetExportSession.init(asset: composition, presetName: AVAssetExportPreset1920x1080)
        session?.outputFileType = AVFileType.mp4
        let outputUrl:String = "/Users/user135745/Desktop/sitv.mp4"
        do {
            if FileManager.default.fileExists(atPath: outputUrl) {
                try FileManager.default.removeItem(atPath: outputUrl)
            }
            
        }
        catch {
            print(error)
        }
        
        let sessionWaitSemaphore = DispatchSemaphore(value: 0)
        session?.videoComposition = videoComposition
        session?.outputURL = NSURL.fileURL(withPath: outputUrl)
        session?.exportAsynchronously(completionHandler: {
            if session?.status == AVAssetExportSessionStatus.completed {
                print("Session exported successfully")
                isRenderedSuccessfully = true
                completion(URL.init(fileURLWithPath: outputUrl))
            }
            else if session?.status == AVAssetExportSessionStatus.failed {
                print("Session export failed")
                isRenderedSuccessfully = false
                failure("SIT export failed")
            }
            sessionWaitSemaphore.signal()
            return Void()
        })
        sessionWaitSemaphore.wait(timeout: DispatchTime.distantFuture)
        print("SIT job is done..")
    }

}
