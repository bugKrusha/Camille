import ChameleonTestKit

extension FixtureSource {
    static func messageWithLink1() throws -> FixtureSource<Any> { try .init(jsonFile: "MessageWithLink") }
    static func unfurlLink1() throws -> FixtureSource<Any> { try.init(jsonFile: "MessageWithLinkUnfurl") }
    static func threadedMessageWithLink1() throws -> FixtureSource<Any> { try.init(jsonFile: "ThreadedMesssageWithLink") }
    static func deleteThreadedMessageWithLink1() throws -> FixtureSource<Any> { try .init(jsonFile: "ThreadedMesssageWithLinkDelete") }
    static func deleteMessageWithLink1() throws -> FixtureSource<Any> { try .init(jsonFile: "MessageWithLinkDelete") }
}
