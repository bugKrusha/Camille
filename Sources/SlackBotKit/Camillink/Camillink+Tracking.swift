import ChameleonKit
import Foundation

extension SlackBot.Camillink {
    static func tryTrackLink(_ config: Config, _ storage: Storage, _ bot: SlackBot, _ message: Message) throws {
        // Check actual link, make sure it's not mail.app etc
        let links = message.links().filter({ $0.url.absoluteString.hasPrefix("http") }).map({ $0.url })
        guard !links.isEmpty else { return }

        // Might be good to clean attribution links to prevent duplicates, etc...

        for link in links {
            switch try? storage.get(Record.self, forKey: link.absoluteString, from: Keys.namespace) {
            case let record?:
                if isRecordExpired(config, record) {
                    try storage.remove(forKey: link.absoluteString, from: Keys.namespace)

                } else if !shouldSilence(config, message, record) {
                    let response: MarkdownString = "\(.wave) That \("link", link) is also being discussed in \("this message", record.permalink) in \(record.channelID)"
                    try bot.perform(.respond(to: message, .threaded, with: response))
                }

            case nil: // new link
                let permalink = try bot.perform(.permalink(for: message))
                let record = Record(channelID: permalink.channel, permalink: permalink.permalink)
                try storage.set(forKey: link.absoluteString, from: Keys.namespace, value: record)
            }
        }
    }

    private static func isRecordExpired(_ config: Config, _ record: Record) -> Bool {
        guard let dayLimit = config.recencyLimitInDays else { return false }
        // Dave please don't yell at me
        guard let daysSince = Calendar.current.dateComponents([.day], from: record.date, to: Date()).day else { return true }
        return dayLimit < daysSince
    }

    private static func shouldSilence(_ config: Config, _ message: Message, _ record: Record) -> Bool {
        return shouldSilenceForWhitelisting(record)
            || shouldSilenceForCrossLink(config, message, record)
            || shouldSilenceForSameChannel(config, message, record)
    }
    private static func shouldSilenceForCrossLink(_ config: Config, _ message: Message, _ record: Record) -> Bool {
        guard config.silentCrossLink else { return false }
        return message.channels().contains(record.channelID)
    }
    private static func shouldSilenceForWhitelisting(_ record: Record) -> Bool {
        // Eventually implement whitelisting here
        // This is WIP until I get time to implement attachments
        // in Chameleon
        return false
    }
    private static func shouldSilenceForSameChannel(_ config: Config, _ message: Message, _ record: Record) -> Bool {
        guard config.silentSameChannel else { return false }
        return message.channel == record.channelID
    }
}
