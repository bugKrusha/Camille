import ChameleonKit
import ChameleonTestKit
@testable import SlackBotKit
import XCTest

class CamillinkTests: XCTestCase {
    func testLinkTracking() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        var config: SlackBot.Camillink.Config = .default()
        var date = Date()
        config.dateFactory = { date }

        _ = test.bot.enableCamillink(config: config, storage: storage)

        // sanity check
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), [])
        XCTAssertClear(test)

        // messages without links aren't triggering
        try test.send(.event(.message([.text("hello world")])))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), [])
        XCTAssertClear(test)

        // initial link
        try test.enqueue([.permalink(channelId: "C0000000000", url: URL("https://www.slack.com/permalink/channel1/link1"))])
        try test.send(.event(.messageWithLink1()))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), ["https://twitter.com/IanKay"])
        XCTAssertClear(test)

        try test.send(.event(.unfurlLink1()))
        XCTAssertClear(test)

        // same link, same channel, 1 second later
        date.addTimeInterval(1)
        try test.enqueue([.emptyMessage()])
        try test.send(.event(.messageWithLink1()))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), ["https://twitter.com/IanKay"])
        XCTAssertClear(test)

        // same link, thread
        try test.enqueue([.emptyMessage()])
        try test.send(.event(.threadedMessageWithLink1()))
        XCTAssertClear(test)

        // delete link from thread
        try test.send(.event(.deleteThreadedMessageWithLink1()))
        XCTAssertClear(test)

        // same link, different channel, 1 second later
        date.addTimeInterval(1)
        try test.enqueue([.emptyMessage()])
        try test.send(.event(.message([.link(url: URL("https://twitter.com/IanKay"))])))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), ["https://twitter.com/IanKay"])
        XCTAssertClear(test)

        // same link, different channel, after expiration
        let day = 60 * 60 * 24
        date.addTimeInterval(TimeInterval(day * (config.recencyLimitInDays! + 1)))
        try test.send(.event(.message([.link(url: URL("https://twitter.com/IanKay"))])))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), [])
        XCTAssertClear(test)
    }

    func testLinkTracking_EdgeCases_LinksInCodeBlocks() throws {
        let test = try SlackBot.test()
        let storage = MemoryStorage()
        _ = test.bot.enableCamillink(config: .default(), storage: storage)

        try test.send(.event(.messageWithPreformattedLink()))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), [])
        XCTAssertClear(test)
    }
}
