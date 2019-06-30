import Chameleon

public final class CamillinkService: SlackBotMessageService {
    // MARK: - Properties
    let storage: Storage
    let config: Config
    public let allowedSubTypes: [Message.Subtype] = [.me_message, .thread_broadcast]

    enum Keys {
        static let namespace = "Camillink"
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
    }

    public func onMessage(slackBot: SlackBot, message: MessageDecorator, previous: MessageDecorator?) throws {
        try trackLink(bot: slackBot, message: message)
    }

}
