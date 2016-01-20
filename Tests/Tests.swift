import Foundation
import XCTest

class Tests: XCTestCase {
    let baseURL = "http://httpbin.org"

    func testBasicAuth() {
        let networking = Networking(baseURL: baseURL)
        networking.authenticate("user", password: "passwd")
        networking.GET("/basic-auth/user/passwd", completion: { JSON, error in
            let JSON = JSON as! [String : AnyObject]
            let user = JSON["user"] as! String
            let authenticated = JSON["authenticated"] as! Bool
            XCTAssertEqual(user, "user")
            XCTAssertEqual(authenticated, true)
        })
    }

    func testURLForPath() {
        let networking = Networking(baseURL: baseURL)
        let url = networking.urlForPath("/hello")
        XCTAssertEqual(url.absoluteString, "http://httpbin.org/hello")
    }

    func testSkipTestMode() {
        let expectation = expectationWithDescription("testSkipTestMode")

        let networking = Networking(baseURL: baseURL)
        networking.disableTestingMode = true

        var synchronous = false
        networking.GET("/get", completion: { JSON, error in
            synchronous = true

            XCTAssertTrue(synchronous)

            expectation.fulfill()
        })

        XCTAssertFalse(synchronous)

        waitForExpectationsWithTimeout(3.0, handler: nil)
    }

    func testDestinationURL() {
        let networking = Networking(baseURL: baseURL)
        let path = "/image/png"
        let destinationURL = networking.destinationURL(path)
        XCTAssertEqual(destinationURL.lastPathComponent!, "http:--httpbin.org-image-png")
    }

    func testStatusCodeType() {
        XCTAssertEqual((-999).statusCodeType(), NetworkingStatusCodeType.Unknown)
        XCTAssertEqual(99.statusCodeType(), NetworkingStatusCodeType.Unknown)
        XCTAssertEqual(101.statusCodeType(), NetworkingStatusCodeType.Informational)
        XCTAssertEqual(203.statusCodeType(), NetworkingStatusCodeType.Successful)
        XCTAssertEqual(303.statusCodeType(), NetworkingStatusCodeType.Redirection)
        XCTAssertEqual(403.statusCodeType(), NetworkingStatusCodeType.ClientError)
        XCTAssertEqual(550.statusCodeType(), NetworkingStatusCodeType.ServerError)
    }
}
