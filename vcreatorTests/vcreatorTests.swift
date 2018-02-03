//
//  vcreatorTests.swift
//  vcreatorTests
//
//  Created by Inwiter on 05/01/18.
//  Copyright © 2018 satya. All rights reserved.
//

import XCTest

class vcreatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testImageAspectRatio() {
        let iSize = CGSize.init(width: 480, height: 854)
        let rSize = ImageUtils.getAspectSize(imageSize: iSize)
        print("\(rSize)")
    }
    func testCropImage() {
        let imageURL = NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/baby2.JPG")
        let image:NSImage = NSImage.init(contentsOf: imageURL)!
        let rSize = ImageUtils.getAspectSize(imageSize: image.size)
        let rImage = ImageUtils.cropImage(url: imageURL , targetSize: NSSize.init(width: 1920, height: 1080))
//        assert(rImage?.size.width == 850, "Invalid width")
        
    }
    func testSingleImageTemplate()  {
        let singleImageTemplate = SingleImageTemplate.init()
        let imageUrl = NSURL.fileURL(withPath:"/Users/inwiter/Movies/inviter/assets/baby2.JPG")
        singleImageTemplate.prepareTemplate(imageUrl: imageUrl as NSURL )

    }
}
