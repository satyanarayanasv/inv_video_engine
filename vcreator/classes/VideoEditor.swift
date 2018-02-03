//
//  VideoEditor.swift
//  vcreator
//
//  Created by Inwiter on 11/12/17.
//  Copyright © 2017 satya. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa


 

class VideoEditor {

    var vurl1 = NSURL.fileURL(withPath:"/Users/inwiter/Desktop/sitv.mp4")
    var vurl2 = NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/wedslide.mov")
    let vasset1:AVURLAsset
    let vasset2:AVURLAsset
    var backgroundAudioAsset:AVURLAsset?
    let composition = AVMutableComposition()
    let videoComposition = AVMutableVideoComposition()
    init(vUrl:URL, templateUrl:URL, backgroundAudioUrl:URL?) {
        vasset1 = AVURLAsset.init(url: vUrl)
        vasset2 = AVURLAsset.init(url: templateUrl)
        if let audioUrl = backgroundAudioUrl {
            backgroundAudioAsset = AVURLAsset.init(url: backgroundAudioUrl!)
        }
    }
//    func prepareAssets(videoPath:String, backgroundAudioPath:String, templatePath:String) -> String {
//        let videoUrl = NSURL.fileURL(withPath: videoPath)
//        let backgroundAudioUrl = NSURL.fileURL(withPath: backgroundAudioPath)
//        let templateUrl = NSURL.fileURL(withPath: templatePath)
//
//        if let vUrl:URL = videoUrl {
//            vasset1 = AVURLAsset.init(url: vUrl)
//        }
//        else {
//            return "Input video required"
//        }
//        if let bAudioUrl:URL = backgroundAudioUrl {
//            backgroundAudioAsset = AVURLAsset.init(url: bAudioUrl)
//        }
//        if let tUrl:URL = templateUrl {
//            vasset2 = AVURLAsset.init(url: tUrl )
//
//        }
//        else {
//            return "Template video is required"
//        }
//        return "success"
//
//
//    }
    func prepareTracks() {
        let vTrack1 = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let vTrack2 = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        
        var aTrack1:AVMutableCompositionTrack?
        let vt1 = vasset1.tracks(withMediaType: AVMediaType.video)[0]
        let vt2 = vasset2.tracks(withMediaType: AVMediaType.video)[0]
        var at1:AVAssetTrack?
        if let audioAsset = backgroundAudioAsset {
           aTrack1 = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
           at1 = audioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        }
        do
        {

            try vTrack1?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, vasset1.duration), of: vt1, at: kCMTimeZero)
            try vTrack2?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, vasset1.duration), of: vt2, at: kCMTimeZero)
            if let audioTrack = at1 {
                try aTrack1?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, vasset1.duration), of: audioTrack, at: kCMTimeZero)
            }
            

        }
        catch {
            print (error)
        }
    }
    
    func prepareCompositionInstructions() {
        
        videoComposition.renderSize = composition.naturalSize
        videoComposition.frameDuration = CMTimeMake(1, 25)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.enablePostProcessing = true
        let instructionLayer1 = AVMutableVideoCompositionLayerInstruction.init(assetTrack: composition.tracks[0])
        let instructionLayer2 = AVMutableVideoCompositionLayerInstruction.init(assetTrack: composition.tracks[1])
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, vasset1.duration)
        instruction.layerInstructions = [instructionLayer2, instructionLayer1]
        videoComposition.instructions = [instruction]
        
    }
    func renderVideo(outputPath:String?, completion:@escaping (URL) -> Void, failure:@escaping (String) -> Void) {
        let session = AVAssetExportSession.init(asset: composition, presetName: AVAssetExportPreset1280x720)
        
        session?.outputFileType = AVFileType.mp4
        if let lOutputPath = outputPath {
            do {
                if FileManager.default.fileExists(atPath: lOutputPath) {
                    try FileManager.default.removeItem(atPath: lOutputPath)
                }
                
            }
            catch {
                print(error)
            }
            
            let sessionWaitSemaphore = DispatchSemaphore(value: 0)
            session?.videoComposition = videoComposition
            session?.outputURL = NSURL.fileURL(withPath: lOutputPath)
            session?.exportAsynchronously(completionHandler: {
                if session?.status == AVAssetExportSessionStatus.completed {
                    print("Session exported successfully")
                    completion(URL.init(fileURLWithPath: lOutputPath))
                }
                else if session?.status == AVAssetExportSessionStatus.failed {
                    print("Session export failed")
                    failure("Session export failed")
                }
                sessionWaitSemaphore.signal()
                return Void()
            })
            sessionWaitSemaphore.wait(timeout: DispatchTime.distantFuture)
            print("My job is done..")
        }
        else {
            failure("Output path is required")
        }

    }
    
}
