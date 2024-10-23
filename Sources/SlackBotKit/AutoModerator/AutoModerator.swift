import Foundation
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
            return .init(triggerPhrases: [
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
                let heyGuysLink = URL(string: "https://iosfolks.com/hey-guys")!
                let response: MarkdownString = "To promote inclusivity we ask people to use an alternative to guys such as y’all or folks. We all make mistakes so don't overthink it, you can learn more about \("this message", heyGuysLink) or Camille in our Community Guide."
                try bot.perform(.respond(to: message, .threaded, with: response))
            }
        }

        return self
    }
}
