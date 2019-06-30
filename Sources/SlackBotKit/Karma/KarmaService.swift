import Chameleon

public final class KarmaService: SlackBotMessageService {
    // MARK: - Properties
    let storage: Storage
    let config: Config
    public let allowedSubTypes: [Message.Subtype] = [.me_message, .message_changed, .thread_broadcast]

    enum Keys {
        static let namespace = "Karma"
        static let count = "count"
        static let user = "user"
    }

    // MARK: - Lifecycle
    public init(config: Config = Config.default(), storage: Storage) {
        self.config = config
        self.storage = storage
    }

    // MARK: - Public Functions
    public func configure(slackBot: SlackBot) {
        configureMessageService(slackBot: slackBot)

        slackBot
            .registerHelp(item: Patterns.topUsers)
            .registerHelp(item: Patterns.myCount)
            .registerHelp(item: Patterns.userCount)
            .registerHelp(item: Patterns.adjustment)
    }
    public func onMessage(slackBot: SlackBot, message: MessageDecorator, previous: MessageDecorator?) throws {
        // thread_broadcast event for the main channel will be marked hidden, ignore to avoid double adjustments
        guard !(message.message.subtype == .thread_broadcast && message.message.hidden) else { return }

        try slackBot
            .route(message, matching: Patterns.topUsers, to: topUsers)
            .route(message, matching: Patterns.myCount, to: senderCount)
            .route(message, matching: Patterns.userCount, to: userCount)
            .route(message, matching: Patterns.adjustment, to: noop)

        try adjust(bot: slackBot, message: message)
    }

    private func noop(bot: SlackBot, message: MessageDecorator, match: PatternMatch) throws { }
}
