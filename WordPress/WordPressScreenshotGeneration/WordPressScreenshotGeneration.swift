import UIKit
import XCTest
import SimulatorStatusMagic

class WordPressScreenshotGeneration: XCTestCase {
    let imagesWaitTime: UInt32 = 10

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        SDStatusBarManager.sharedInstance()?.enableOverrides()

        // This does the shared setup including injecting mocks and launching the app
        setUpTestSuite()

        // The app is already launched so we can set it up for screenshots here
        let app = XCUIApplication()
        setupSnapshot(app)

        if isIpad {
            XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        } else {
            XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        }

        LoginFlow.login(siteUrl: "WordPress.com", username: ScreenshotCredentials.username, password: ScreenshotCredentials.password)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SDStatusBarManager.sharedInstance()?.disableOverrides()

        super.tearDown()
    }

    func testGenerateScreenshots() {

        let mySite = MySiteScreen()
            .showSiteSwitcher()
            .switchToSite(withTitle: "infocusphotographers.com")

        let postList = mySite
            .gotoPostsScreen()
            .showOnly(.drafts)

        let firstPostEditorScreenshot = postList.selectPost(withSlug: "summer-band-jam")
        thenTakeScreenshot(1, named: "PostEditor")
        firstPostEditorScreenshot.close()

        // Get a screenshot of the drafts feature
        let secondPostEditorScreenshot = postList.selectPost(withSlug: "ideas")
        thenTakeScreenshot(5, named: "DraftEditor")
        secondPostEditorScreenshot.close()

        // Get a screenshot of the full-screen editor
        if isIpad {
            let ipadScreenshot = postList.selectPost(withSlug: "now-booking-summer-sessions")
            thenTakeScreenshot(6, named: "No-Keyboard-Editor")
            ipadScreenshot.close()
        }

        if !isIpad {
            postList.pop()
        }

        _ = mySite.gotoMediaScreen()
        sleep(imagesWaitTime) // wait for post images to load
        thenTakeScreenshot(4, named: "Media")

        if !isIpad {
            postList.pop()
        }
        // Get Stats screenshot
        let statsScreen = mySite.gotoStatsScreen()
        statsScreen
            .dismissCustomizeInsightsNotice()
            .switchTo(mode: .years)

        thenTakeScreenshot(2, named: "Stats")

        TabNavComponent()
            .gotoNotificationsScreen()
            .dismissNotificationAlertIfNeeded()

        thenTakeScreenshot(3, named: "Notifications")
    }
}

extension XCTestCase {
    func thenTakeScreenshot(_ index: Int, named title: String) {
        let mode = isDarkMode ? "dark" : "light"
        let filename = "\(index)-\(mode)-\(title)"

        snapshot(filename)
    }
}
