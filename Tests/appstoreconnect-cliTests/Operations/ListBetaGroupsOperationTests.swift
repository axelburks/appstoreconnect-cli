// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class ListBetaGroupsOperationTests: XCTestCase {
    typealias Operation = ListBetaGroupsOperation
    typealias Options = Operation.Options

    let successRequestor = OneEndpointTestRequestor(
        response: { _ in Future { $0(.success(response)) } }
    )

    func testExecute_success() {
        let operation = Operation(options: Options(appIds: [], bundleIds: []))

        var expectedGroup = BetaGroup(appId: "1234567890")
        expectedGroup.appBundleId = "com.example.test"
        expectedGroup.appName = "Test App"
        expectedGroup.groupName = "Example Group 1"
        expectedGroup.isInternal = true
        expectedGroup.creationDate = "2020-04-08T07:40:14Z"

        let result = Result { try operation.execute(with: successRequestor).await() }

        switch result {
        case .success(let betaGroups):
            XCTAssertEqual(betaGroups, [expectedGroup])
        case .failure(let error):
            XCTFail("Expected success, got: \(error.localizedDescription)")
        }
    }

    func testExecute_propagatesUpstreamErrors() {
        let operation = Operation(options: Options(appIds: [], bundleIds: []))
        let requestor = FailureTestRequestor()

        let result = Result { try operation.execute(with: requestor).await() }

        switch result {
        case .failure(TestError.somethingBadHappened):
            break
        default:
            XCTFail("Expected \(TestError.somethingBadHappened), got: \(result)")
        }
    }

    static let response: BetaGroupsResponse = """
    {
        "data": [
            {
                "type": "betaGroups",
                "id": "12345678-90ab-cdef-1234-567890abcdef",
                "attributes": {
                    "name": "Example Group 1",
                    "createdDate": "2020-04-08T07:40:14.179Z",
                    "isInternalGroup": true,
                    "publicLinkEnabled": null,
                    "publicLinkId": null,
                    "publicLinkLimitEnabled": null,
                    "publicLinkLimit": null,
                    "publicLink": null,
                    "feedbackEnabled": true
                },
                "relationships": {
                    "app": {
                        "data": {
                            "type": "apps",
                            "id": "1234567890"
                        },
                        "links": {
                            "self": "https://api.appstoreconnect.apple.com/v1/betaGroups/12345678-90ab-cdef-1234-567890abcdef/relationships/app",
                            "related": "https://api.appstoreconnect.apple.com/v1/betaGroups/12345678-90ab-cdef-1234-567890abcdef/app"
                        }
                    }
                },
                "links": {
                    "self": "https://api.appstoreconnect.apple.com/v1/betaGroups/12345678-90ab-cdef-1234-567890abcdef"
                }
            }
        ],
        "included": [
            {
                "type": "apps",
                "id": "1234567890",
                "attributes": {
                    "name": "Test App",
                    "bundleId": "com.example.test",
                    "sku": "TEST1",
                    "primaryLocale": "en-AU"
                },
                "links": {
                    "self": "https://api.appstoreconnect.apple.com/v1/apps/1234567890"
                }
            }
        ],
        "links": {
            "self": "https://api.appstoreconnect.apple.com/v1/betaGroups?include=app"
        }
    }
    """
    .data(using: .utf8)
    .map({ try! jsonDecoder.decode(BetaGroupsResponse.self, from: $0) })!
}
