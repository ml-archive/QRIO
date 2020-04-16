//
//  QRIOTests.swift
//  QRIOTests
//
//  Created by Chris on 01/07/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import XCTest
import UIKit
@testable import QRIO

class QRIOTests: XCTestCase {
    
    func testQRImageFromStringCreatedSuccessfully() {
        let image = UIImage.QRImageFrom(string: "Hello World!")
        XCTAssertNotNil(image)
    }
}
