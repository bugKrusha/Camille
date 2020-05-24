import ChameleonKit

/// A service that observes every message in a public channel, determines whether it requires an automatic moderator
/// response based on the message contents and replies with an in-line thread.
public enum AutoModerator {
    public struct Config {
        var triggerPhrases: [Parser<String>]

        init(triggerPhrases: [Parser<String>]) {
            self.triggerPhrases = triggerPhrases
        }

        public static func `default`() -> Config {
            return .init(triggerPhrases: [ // could these be simplified to "guys" ?
                "you guys",
                "thanks guys",
                "hi guys",
                "hey guys",
            ])
        }
    }
}
extension SlackBot {
    public func enableAutoModerator(config: AutoModerator.Config) -> SlackBot {
        listen(for: .message) { bot, message in
            guard message.user != bot.me.id else { return }
            guard !(message.subtype == .thread_broadcast && message.hidden) else { return }

            try message.matching(.anyOf(config.triggerPhrases)) { _ in
                let response: MarkdownString = "Maybe next time, consider using “y’all” or “folks” instead. It’s more inclusive than “guys”. \(.smile)"
                try bot.perform(.respond(to: message, .threaded, with: response))
            }
        }
        return self
    }
}
