import ChameleonKit
import ChameleonTestKit
@testable import SlackBotKit
import XCTest

class AutoModeratorTests: XCTestCase {
    func testModerator() throws {
        let test = try SlackBot.test()
        _ = test.bot.enableAutoModerator(config: .default())

        let messages = [
            "hey guys", "Hey guys!",
            "how are you guys?",
            "thank you guys"
        ]

        for message in messages {
            try test.send(.event(.message(message)), enqueue: [.emptyMessage()])
        }

        // This service triggers a response when the pattern is matched.
        // If one of the messages didn't result in a response then the
        // 'enqueued' message wont have been used and this assertion will fail
        XCTAssertClear(test)
    }
}
