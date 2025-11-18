//
//  LibSMExtrasTests.swift
//  DriveAZ
//
//  Created by Ben on 2/7/25.
//


import XCTest
@testable import DriveAZ
import CoreLocation
import B2VExtras
import B2VExtrasSwift

class LibSMExtrasTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDecodeEncode() throws {
        let startingMessage = "001F808100000060D693A403AD27480000001650A01B80017E4A0F4D19777358827C8419F2EFBFC30F4D01C1C4CD8B325CD81812C00000100086EC00333328906B7FCFAA8000028FEBE541ABAF3E8830E9DC9FA20C2833EFDDBB0A0E187CA0DDBD074DFB362C4125073C3E79A0D997A20E9A32ED41D3975C7AF2F2E68396FD9B010181A120"
        
        let array = startingMessage.hexaBytes
        print("Array contents: \(array.map { String($0) }.joined(separator: ", "))")
        var message = MessageFrame()
        let decoded = libsm_decode_messageframe(array, array.count, &message)
        
        var bytes: [UInt8] = [UInt8](repeating: 0xFF, count: array.count)
        var otherByteCount = bytes.count
        let encoded = libsm_encode_messageframe(&message, &bytes, &otherByteCount)
        XCTAssertEqual(startingMessage, bytes.bytesToHex(spacing: ""))
    }
    
}
