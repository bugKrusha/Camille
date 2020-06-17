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
        try test.send(.event(
            .message(userId: "1", channelId: "1", kind: .channel, [
                .text("hello world")
            ])
        ))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), [])
        XCTAssertClear(test)

        // initial link
        try test.enqueue([.permalink(channelId: "1", url: URL("https://www.slack.com/permalink/channel1/link1"))])
        try test.send(.event(
            .message(userId: "1", channelId: "1", kind: .channel, [
                .link(url: URL("https://www.link1.com"))
            ])
        ))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), ["https://www.link1.com"])
        XCTAssertClear(test)

        // same link, same channel, 1 second later
        date.addTimeInterval(1)
        try test.enqueue([.emptyMessage()])
        try test.send(.event(
            .message(userId: "1", channelId: "1", kind: .channel, [
                .link(url: URL("https://www.link1.com"))
            ])
        ))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), ["https://www.link1.com"])
        XCTAssertClear(test)

        // same link, different channel, 1 second later
        date.addTimeInterval(1)
        try test.enqueue([.emptyMessage()])
        try test.send(.event(
            .message(userId: "1", channelId: "2", kind: .channel, [
                .link(url: URL("https://www.link1.com"))
            ])
        ))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), ["https://www.link1.com"])
        XCTAssertClear(test)

        // same link, different channel, after expiration
        let day = 60 * 60 * 24
        date.addTimeInterval(TimeInterval(day * (config.recencyLimitInDays! + 1)))
        try test.send(.event(
            .message(userId: "1", channelId: "2", kind: .channel, [
                .link(url: URL("https://www.link1.com"))
            ])
        ))
        try XCTAssertEqual(storage.keys(in: SlackBot.Camillink.Keys.namespace), [])
        XCTAssertClear(test)
    }
}

extension FixtureSource {
    public static func link(text: String? = nil, url: URL) throws -> FixtureSource<RichTextElement> {
        return .init(raw: """
        {
            "type": "link",
            "text": "\(text ?? "null")",
            "url": "\(url.absoluteString)"
        }
        """)
    }
}

extension RichTextFixture {
    public static func link(text: String? = nil, url: URL) -> RichTextFixture {
        let string: MarkdownString

        switch text {
        case let text?: string = "\("\(text)", url)"
        case nil: string = "\(url)"
        }

        return .init { try (string, Message.Layout.RichText.Element.Link(from: .link(text: text, url: url))) }
    }
}

extension FixtureSource {
    public static func permalink(channelId: String, url: URL) -> FixtureSource<SlackDispatcher> {
        return .init(raw: """
        {
            "ok": true,
            "channel": "\(channelId)",
            "permalink": "\(url.absoluteString)"
        }
        """)
    }
}
