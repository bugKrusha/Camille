import ChameleonKit
import Foundation

extension SlackBot {
    public enum Camillink {
        enum Keys {
            static let namespace = "Camillink"
            static let count = "count"
            static let user = "user"
        }

        struct Record: LosslessStringCodable {
            let date: Date
            let channelID: Identifier<Channel>
            let permalink: URL
        }
    }
}

extension SlackBot {
    public func enableCamillink(config: Camillink.Config, storage: Storage) -> SlackBot {
        listen(for: .message) { bot, message in
            guard message.user != bot.me.id else { return }
            guard !message.isUnfurl else { return }
            guard !(message.subtype == .thread_broadcast && message.hidden) else { return }
            guard message.subtype != .message_changed else { return }
            guard message.channel_type != .im else { return }

            try Camillink.tryTrackLink(config, storage, bot, message)
        }

        return self
    }
}
