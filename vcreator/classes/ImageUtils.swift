//
//  ImageUtils.swift
//  vcreator
//
//  Created by Inwiter on 05/01/18.
//  Copyright © 2018 satya. All rights reserved.
//

import Foundation
import Cocoa

class ImageUtils {
    static func cropImage(url:URL, targetSize:NSSize) -> NSImage? {
        
        return crop(url: url, toSize: targetSize)
    }
    static func resize(image:NSImage, targetSize: NSSize) -> NSImage? {
        let frame = NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        guard let representation = image.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        let image = NSImage(size: targetSize, flipped: false, drawingHandler: { (_) -> Bool in
            return representation.draw(in: frame)
        })
        
        return image
    }
    static func resizeMaintainingAspectRatio(image:NSImage, targetSize: NSSize) -> NSImage? {
        let newSize: NSSize
        let widthRatio  = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        if widthRatio > heightRatio {
            newSize = NSSize(width: floor(image.size.width * widthRatio),
                             height: floor(image.size.height * widthRatio))
        } else {
            newSize = NSSize(width: floor(image.size.width * heightRatio),
                             height: floor(image.size.height * heightRatio))
        }
        return ImageUtils.resize(image:image, targetSize: newSize)!
    }

    static func crop(url:URL, toSize targetSize: NSSize) -> NSImage? {
        if let image:NSImage = NSImage.init(contentsOf: url as URL) {
//            guard let resizedImage:NSImage = ImageUtils.resizeMaintainingAspectRatio(image:image, targetSize: targetSize) else {
//                return nil
//            }
//            let newSize = getAspectSize(imageSize: image.size)
            let newSize = getOriginalAspectSize(sourceWidth: image.size.width)
            var x     = floor((image.size.width - newSize.width) / 2)
            var y     = floor((image.size.height - newSize.height) / 2)
            y = image.size.height - newSize.height
            let frame = NSRect(x: x, y: y, width: newSize.width, height: newSize.height)
            
//            guard let representation = resizedImage.bestRepresentation(for: frame, context: nil, hints: nil) else {
//                return nil
//            }
            
            var resultImage = NSImage.init(size: targetSize)
            resultImage.lockFocus()
//          image.draw(at: NSPoint.init(x: 0, y: 0), from: frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0 )
            image.draw(in: NSRect.init(x: 0, y: 0, width: targetSize.width, height: targetSize.height), from: frame, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            resultImage.unlockFocus()
//            let resultImage = NSImage(size: targetSize,
//                                flipped: false,
//                                drawingHandler: { (destinationRect: NSRect) -> Bool in
//                                    return representation.draw(in: destinationRect)
//            })
            
            return resultImage

        }
        return nil
    }
    static func getAspectSize(imageSize:CGSize, scale:CGFloat) -> CGSize {
        var size = getAspectSize(imageSize: imageSize)
        size.width *= scale
        size.height *= scale
        return size
    }
    static func getOriginalAspectSize(sourceWidth:CGFloat) -> CGSize {
        
       return CGSize.init(width: sourceWidth, height:  round((9.0 / 16.0) * sourceWidth))
    }
    static func getAspectSize(imageSize:CGSize) -> CGSize {
        var newWidth:CGFloat = imageSize.width
        var inputImageWidth:CGFloat
        var newHeight:CGFloat = imageSize.height
        var inputImageHeight:CGFloat
        var videoAspectRatio:CGFloat
        var displayAspectRatio:CGFloat
        inputImageWidth = imageSize.width;
        inputImageHeight = imageSize.height;
        videoAspectRatio = CGFloat(inputImageHeight / inputImageWidth)
        displayAspectRatio = CGFloat(Constants.FINAL_VIDEO_HEIGHT / Constants.FINAL_VIDEO_WIDTH)
        if (Constants.FINAL_VIDEO_WIDTH == Constants.RENDER_VIDEO_WIDTH  && Constants.FINAL_VIDEO_HEIGHT == Constants.RENDER_VIDEO_HEIGHT) {
            displayAspectRatio = 9.0/16.0;
            
        }
        if(videoAspectRatio < displayAspectRatio)
        {
            newWidth = CGFloat(Constants.FINAL_VIDEO_WIDTH)
            newHeight = newWidth * videoAspectRatio
        }
        
        if(videoAspectRatio > displayAspectRatio)
        {
            newHeight = CGFloat(Constants.FINAL_VIDEO_HEIGHT)
            newWidth = newHeight / videoAspectRatio
        }
        
        if(displayAspectRatio == videoAspectRatio)
        {
            newHeight = CGFloat(Constants.FINAL_VIDEO_HEIGHT)
            newWidth = CGFloat(Constants.FINAL_VIDEO_WIDTH)
        }
        
        let x = newWidth .truncatingRemainder(dividingBy: 2) == 0 ? newWidth : newWidth + 1
        let y = newHeight .truncatingRemainder(dividingBy: 2) == 0 ? newHeight : newHeight + 1
        print("Image original size  \(imageSize) new size \(x) , \(y)" )
        return CGSize.init(width: x, height: y)
    }
}
