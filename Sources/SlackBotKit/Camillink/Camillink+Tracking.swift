import ChameleonKit
import Foundation

extension SlackBot.Camillink {

    static func tryTrackLink(_ config: Config, _ storage: Storage, _ bot: SlackBot, _ message: Message) throws {
        // Check for a web link, make sure it's not Mail.app, etc
        let links = message.links()
            .filter({ $0.url.absoluteString.hasPrefix("http") })
            .map({ $0.url })
            .compactMap({ self.removeGarbageQueryParameters(url: $0) })
            .removeDuplicates()

        guard !links.isEmpty else { return }

        for link in links {
            switch try? storage.get(Record.self, forKey: link.absoluteString, from: Keys.namespace) {
            case let record?:
                if isRecordExpired(config, record) {
                    try storage.remove(forKey: link.absoluteString, from: Keys.namespace)
                } else if !shouldSilence(link, config, message, record) {
                    let response: MarkdownString = "\(.wave) That \("link", link) is also being discussed in \("this message", record.permalink) in \(record.channelID)"
                    try bot.perform(.respond(to: message, .threaded, with: response))
                }

            case nil: // new link
                guard !shouldSilenceForAllowListedDomain(link) else { return }

                let permalink = try bot.perform(.permalink(for: message))
                let record = Record(date: config.dateFactory(), channelID: permalink.channel, permalink: permalink.permalink)
                try storage.set(forKey: link.absoluteString, from: Keys.namespace, value: record)
            }
        }
    }

    private static func isRecordExpired(_ config: Config, _ record: Record) -> Bool {
        guard let dayLimit = config.recencyLimitInDays else { return false }
        guard let daysSince = config.calendar.dateComponents([.day], from: record.date, to: config.dateFactory()).day else { return true }
        return dayLimit < daysSince
    }

    private static func shouldSilence(_ link: URL, _ config: Config, _ message: Message, _ record: Record) -> Bool {
        return shouldSilenceForAllowListedDomain(link)
            || shouldSilenceForCrossLink(config, message, record)
            || shouldSilenceForSameChannel(config, message, record)
    }

    private static func shouldSilenceForCrossLink(_ config: Config, _ message: Message, _ record: Record) -> Bool {
        guard config.silentCrossLink else { return false }
        return message.channels().contains(record.channelID)
    }

    private static func shouldSilenceForAllowListedDomain(_ link: URL) -> Bool {
        let allowListedHosts = [
            "apple.com",
            "developer.apple.com",
            "iosdevelopers.slack.com",
            "iosfolks.com",
            "mlb.tv",
            "youtube.com/watch?v=dQw4w9WgXcQ"
        ]

        guard let components = URLComponents(url: link, resolvingAgainstBaseURL: false) else { return false }

        return allowListedHosts.contains(where: { $0 == components.host })
    }

    private static func shouldSilenceForSameChannel(_ config: Config, _ message: Message, _ record: Record) -> Bool {
        guard config.silentSameChannel else { return false }
        return message.channel == record.channelID
    }

    private static func removeGarbageQueryParameters(url: URL) -> URL? {
        let denyListedQueryParameters = [
            "utm",
            "utm_source",
            "utm_media",
            "utm_campaign",
            "utm_medium",
            "utm_term",
            "utm_content",
            "t",
            "s",
        ]

        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

        urlComponents.queryItems?.removeAll(where: { queryItem in
            denyListedQueryParameters.contains(where: { $0 == queryItem.name })
        })

        if let queryItems = urlComponents.queryItems, queryItems.isEmpty {
            // An empty queryItems array will retain a trailing ? but nilling it out removes that
            urlComponents.queryItems = nil
        }

        return urlComponents.url
    }

}
