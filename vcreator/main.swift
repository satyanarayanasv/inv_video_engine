//
//  main.swift
//  vcreator
//
//  Created by Inwiter on 11/12/17.
//  Copyright © 2017 satya. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa
/*
let renderSize = CGSize.init(width: Constants.FINAL_VIDEO_WIDTH, height: Constants.FINAL_VIDEO_HEIGHT)
let vurl1 = NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/blankvideo.mp4")
let vurl2 = NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/wedding1.mp4")

let vasset1 = AVURLAsset.init(url: vurl1)
let vasset2 = AVURLAsset.init(url: vurl2)

let composition = AVMutableComposition()
let videoComposition = AVMutableVideoComposition()

let vtrack1 = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
//let vtrack2 = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
let atrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
do {
    let vt = vasset1.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
//    let vt2 = vasset2.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
    let at = vasset2.tracks(withMediaType: AVMediaType.audio)[0] as AVAssetTrack
    try vtrack1!.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(59, 600)), of:vt, at: kCMTimeZero)
//    try vtrack2!.insertTimeRange(CMTimeRangeMake(kCMTimeZero, vasset2.duration), of: vt2, at: kCMTimeZero)
    try atrack!.insertTimeRange(CMTimeRangeMake(CMTimeMakeWithSeconds(30, 600), CMTimeMakeWithSeconds(59, 600)), of: at, at: kCMTimeZero)
}
catch {
    print(error)
}



func prepareCompositionLayers() {
    videoComposition.renderSize = composition.naturalSize
    videoComposition.frameDuration = CMTimeMake(1, 25)
    let instruction = AVMutableVideoCompositionInstruction()
    instruction.enablePostProcessing = true
    let videoLayerInstruction1 = AVMutableVideoCompositionLayerInstruction.init(assetTrack: vtrack1!)
//    let videoLayerInstruction2 = AVMutableVideoCompositionLayerInstruction.init(assetTrack: vtrack2!)
    
//    videoLayerInstruction2.setTransform(CGAffineTransform.init(translationX: 0, y: 0).scaledBy(x: 0.666, y: 0.666) , at: kCMTimeZero)
    let layers = [videoLayerInstruction1]
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, vasset1.duration)
    instruction.layerInstructions = layers
    
    videoComposition.instructions = [instruction]
}
func renderVideo() {
    let session = AVAssetExportSession.init(asset: composition, presetName: AVAssetExportPreset1920x1080)
    session?.outputFileType = AVFileType.mp4
    let outputUrl:String = "/Users/inwiter/Desktop/finalVideo5.mp4"
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
//            let videoEditor = VideoEditor.init()
//            videoEditor.prepareTracks()
//            videoEditor.prepareCompositionInstructions()
//            videoEditor.renderVideo()

        }
        else if session?.status == AVAssetExportSessionStatus.failed {
            print("Session export failed")
        }
        sessionWaitSemaphore.signal()
        return Void()
    })
    sessionWaitSemaphore.wait(timeout: DispatchTime.distantFuture)
    print("My job is done..")
}
func getWhiteBoarderedLayer(url:NSURL) -> CALayer {
    let parentLayer:CALayer = CALayer.init()
    let imageLayer:CATiledLayer = CATiledLayer.init()
    let whiteBoardedWidth:CGFloat = 30;
    if let image:NSImage = NSImage.init(contentsOf: url as URL) {
        var imageSize = CGSize.init(width: image.size.width, height: image.size.height)
        imageSize = ImageUtils.getAspectSize(imageSize: imageSize, scale: 0.7)
        parentLayer.frame = CGRect.init(x: 0, y: 0, width: imageSize.width + whiteBoardedWidth, height: imageSize.height + whiteBoardedWidth)
        imageLayer.frame = CGRect.init(x: whiteBoardedWidth / 2, y: whiteBoardedWidth / 2, width: imageSize.width, height: imageSize.height)
        imageLayer.contents = image
        parentLayer.backgroundColor = CGColor.white
        parentLayer.addSublayer(imageLayer)
    }
    return parentLayer
    
}
func getFadeInAnimation(startTime:Double, duration:Double ) -> CABasicAnimation {
    let animation = CABasicAnimation.init(keyPath: "opacity")
    animation.beginTime = startTime
    animation.duration = duration
    animation.fromValue = 0.0
    animation.toValue = 1.0
    animation.isRemovedOnCompletion = false
    return animation
}
func getFadeOutAnimation(startTime:Double, duration:Double ) -> CABasicAnimation {
    let animation = CABasicAnimation.init(keyPath: "opacity")
    animation.beginTime = startTime
    animation.duration = duration
    animation.fromValue = 1.0
    animation.toValue = 0.0
    animation.isRemovedOnCompletion = false
    return animation
}
func getStillAnimation(startTime:Double, duration:Double ) -> CABasicAnimation {
    let animation = CABasicAnimation.init(keyPath: "opacity")
    animation.beginTime = startTime
    animation.duration = duration
    animation.fromValue = 1.0
    animation.toValue = 1.0
    animation.isRemovedOnCompletion = false
    return animation
}
func getRotateAnimation(startTime:Double, duration:Double ) -> CABasicAnimation {
    let animation = CABasicAnimation.init(keyPath: "transform.rotation")
    animation.fromValue = Double.pi / 4
    animation.toValue = 0
    animation.beginTime = startTime
    animation.duration = duration
//    animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
    animation.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.5, 0, 0.9, 0.7)
    animation.isRemovedOnCompletion = false
    return animation
}
func getCentreTranslateAnimation(startTime:Double, duration:Double, layerSize:CGSize ) -> CABasicAnimation {
    let animation = CABasicAnimation.init(keyPath: "transform.translation")
    let y:CGFloat = (CGFloat(Constants.FINAL_VIDEO_HEIGHT) - layerSize.height) / 2
    let x:CGFloat = (CGFloat(Constants.FINAL_VIDEO_WIDTH) - layerSize.width) / 2
    animation.fromValue = CGSize(width: x, height: y)
    animation.toValue = CGSize(width: x, height: y)
    animation.beginTime = startTime
    animation.duration = duration
    animation.isRemovedOnCompletion = false
    return animation
}
func getLeftInTranslateAnimation(startTime:Double, duration:Double, layerSize:CGSize ) -> CABasicAnimation {
    let animation = CABasicAnimation.init(keyPath: "transform.translation")
    let y:CGFloat = (CGFloat(Constants.FINAL_VIDEO_HEIGHT) - layerSize.height) / 2
    let x:CGFloat = (CGFloat(Constants.FINAL_VIDEO_WIDTH) - layerSize.width) / 2
    animation.fromValue = CGSize(width: -layerSize.width, height: y)
    animation.toValue = CGSize(width: x, height: y)
    animation.beginTime = startTime
    animation.duration = duration
//    animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
    animation.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.5, 0, 0.9, 0.7)
    animation.isRemovedOnCompletion = false
    return animation
}
func getLeftOutTranslateAnimation(startTime:Double, duration:Double, layerSize:CGSize ) -> CABasicAnimation {
    let animation = CABasicAnimation.init(keyPath: "transform.translation")
    let y:CGFloat = (CGFloat(Constants.FINAL_VIDEO_HEIGHT) - layerSize.height) / 2
    let x:CGFloat = (CGFloat(Constants.FINAL_VIDEO_WIDTH) - layerSize.width) / 2
    animation.fromValue = CGSize(width: x, height: y)
    animation.toValue = CGSize(width: CGFloat(Constants.FINAL_VIDEO_WIDTH), height: y)
    animation.beginTime = startTime
    animation.duration = duration
//    animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
    animation.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.5, 0, 0.9, 0.7)
    animation.isRemovedOnCompletion = false
    return animation
}
func getBlurOutTranslateAnimation(startTime:Double, duration:Double ) -> CABasicAnimation {
    let animation = CABasicAnimation.init(keyPath: "filters.blur.inputRadius")
    animation.fromValue = 10.0
    animation.toValue = 0.0
    animation.beginTime = startTime
    animation.duration = duration
    //    animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
    animation.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.5, 0, 0.9, 0.7)
    animation.isRemovedOnCompletion = false
    return animation
}
func getBlurInTranslateAnimation(startTime:Double, duration:Double ) -> CABasicAnimation {
    let animation = CABasicAnimation.init(keyPath: "filters.blur.inputRadius")
    animation.fromValue = 0.0
    animation.toValue = 10.0
    animation.beginTime = startTime
    animation.duration = duration
    //    animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
    animation.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.5, 0, 0.9, 0.7)
    animation.isRemovedOnCompletion = false
    return animation
}
func getFullRect() -> CGRect {
    return CGRect.init(x: 0, y: 0, width: renderSize.width, height: renderSize.height)
}
func prepareAnimationTool() {
    
    let animationLayer = CALayer.init()
    animationLayer.frame = CGRect.init(x: 0, y: 0, width: renderSize.width, height: renderSize.height)
    let imageUrl = NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/IMG_1320.JPG")
    let backgroundImageUrl = NSURL.fileURL(withPath: "/Users/inwiter/Movies/inviter/assets/background_wed3.jpg")
    let backgroundLayer = CATiledLayer.init()
    backgroundLayer.frame = getFullRect()
    backgroundLayer.contents = NSImage.init(contentsOf: backgroundImageUrl as URL)
    animationLayer.addSublayer(backgroundLayer)

//    let images = [NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/IMG_1320.JPG"),
//                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/IMG_1317.JPG"),
//                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/IMG_1327.JPG"),
//                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/IMG_1326.JPG"),
//                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/IMG_1325.JPG"),
//                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/IMG_1316.JPG")]
    let images = [NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1450.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1453.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1452.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1455.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1456.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1457.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1460.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1461.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1462.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1454.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1458.JPG"),
                  NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/anji/IMG_1459.JPG"),]

    
//    let imageLayers:NSMutableArray = []
    var slideStartTime:Double = 1.0
    var incr = 0
    for url in images {
        let imageLayer = getWhiteBoarderedLayer(url: url as NSURL)
//        imageLayers.add(imageLayer)
        animationLayer.addSublayer(imageLayer)
        imageLayer.opacity = 0.0
        imageLayer.masksToBounds = false
        
        let blurFilter:CIFilter = CIFilter.init(name: "CIGaussianBlur")!
        blurFilter.setDefaults()
        blurFilter.setValue(0.0, forKey: "inputRadius")
        blurFilter.name = "blur"
        imageLayer.filters = [blurFilter]
        
        imageLayer.add(getStillAnimation(startTime: slideStartTime, duration: 5.2), forKey: "still\(incr)")
        imageLayer.add(getRotateAnimation(startTime: slideStartTime, duration: 0.5), forKey: "rotatein\(incr)")
        imageLayer.add(getBlurOutTranslateAnimation(startTime: slideStartTime, duration: 0.5), forKey: "blurout\(incr)")
        
        imageLayer.add(getCentreTranslateAnimation(startTime: slideStartTime + 0.5, duration: 4.0, layerSize: imageLayer.frame.size), forKey: "centre\(incr)")
        imageLayer.add(getLeftInTranslateAnimation(startTime: slideStartTime, duration: 0.5, layerSize: imageLayer.frame.size), forKey: "leftin\(incr)")
        imageLayer.add(getLeftOutTranslateAnimation(startTime: slideStartTime + 4.5, duration: 0.7, layerSize: imageLayer.frame.size), forKey: "leftout\(incr)")
        imageLayer.add(getBlurInTranslateAnimation(startTime: slideStartTime + 4.5, duration: 0.7), forKey: "blurin\(incr)")
        slideStartTime = slideStartTime + 4.5
        incr = incr + 1
        
    }
//    let imageLayer = getWhiteBoarderedLayer(url: imageUrl as NSURL)
//
//    imageLayers.add(imageLayer2)
//    imageLayer2.opacity = 0.0
//    imageLayer2.masksToBounds = false

    
//    imageLayer.shadowColor = CGColor.init(red: 227.0/255.0, green: 236.0/255.0, blue: 244.0/255.0, alpha: 1.0);
//    imageLayer.shadowOffset = CGSize.init(width: -20.0, height: 20.0)
//    imageLayer.shadowOpacity = 0.4;
//    imageLayer.shadowRadius = 20.0;
//    imageLayer.add(getFadeInAnimation(startTime: 1.0, duration: 1.0), forKey: "fadein")
//    imageLayer2.add(getStillAnimation(startTime: 5.5, duration: 5.2
//    ), forKey: "still2")
//    imageLayer2.add(getRotateAnimation(startTime: 5.5, duration: 0.5), forKey: "rotatein2")
//    imageLayer2.add(getCentreTranslateAnimation(startTime: 6.0, duration: 4.0, layerSize: imageLayer2.frame.size), forKey: "centre2")
//    imageLayer2.add(getLeftInTranslateAnimation(startTime: 5.5, duration: 0.5, layerSize: imageLayer2.frame.size), forKey: "leftin2")
//    imageLayer2.add(getLeftOutTranslateAnimation(startTime: 10.0, duration: 0.7, layerSize: imageLayer2.frame.size), forKey: "leftout2")
    
//    imageLayer.add(getFadeOutAnimation(startTime: 7.0, duration: 1.0), forKey: "fadeout")
    
    let videoLayer = CALayer.init()
    videoLayer.frame = CGRect.init(x: 0, y: 0, width: renderSize.width, height: renderSize.height)
    let parentLayer = CALayer.init()
    parentLayer.frame = CGRect.init(x: 0, y: 0, width: renderSize.width, height: renderSize.height)
    
    parentLayer.addSublayer(videoLayer)
    parentLayer.addSublayer(animationLayer)

    videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    
}
*/
print("VCreator initiated..")

//prepareCompositionLayers()
//prepareAnimationTool()
//renderVideo()
if CommandLine.arguments.count > 2 {
    let userImagePath = CommandLine.arguments[1]
    let singleImageTemplate = SingleImageTemplate.init()
    let templateUrl = URL.init(fileURLWithPath: CommandLine.arguments[2])
    var backgroundAudioUrl:URL?
    if CommandLine.arguments.count > 3 {
        if let audioPath:String = CommandLine.arguments[3] {
            backgroundAudioUrl = URL.init(fileURLWithPath: audioPath)
        }
    }
    let finalVideoUrl = "/Users/user135745/Desktop/finalVideo.mp4"
//    let imageUrl = NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/wed2.JPG")
    let imageUrl = NSURL.fileURL(withPath:userImagePath)
    singleImageTemplate.prepareTemplate(imageUrl: imageUrl as NSURL)
    singleImageTemplate.processTemplate()
    singleImageTemplate.renderTemplate(filePath: imageUrl as NSURL, completion: { videoUrl in
        let videoEditor = VideoEditor.init(vUrl:videoUrl, templateUrl: templateUrl, backgroundAudioUrl: backgroundAudioUrl)
        videoEditor.prepareTracks()
        videoEditor.prepareCompositionInstructions()
        videoEditor.renderVideo(outputPath:finalVideoUrl, completion: { outputUrl in }, failure:{ error in })

    }, failure: { error in
        
    })
}

