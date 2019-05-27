import Chameleon
import Foundation

extension CamillinkService {
    
    func trackLink(bot: SlackBot, message: MessageDecorator) throws {
        guard !message.isIM else { return }
        guard let linkString = message.mentionedLinks.first.value?.value.link else { return }
        // Might be good to clean attribution links to prevent duplicates, etc...
        guard let linkURL = URL(string: linkString) else { return }
        guard try !isLinkWhitelisted(link: linkURL) else { return }
        if let previous = try previousLinkDiscussion(linkURL: linkURL) {
            try sendPrompt(bot: bot, message: message, linkURL: linkURL, previousLink: previous.permalink)
        } else {
            try markPreviousDiscussion(bot: bot, message: message, linkURL: linkURL)
        }

    }
    
    func previousLinkDiscussion(linkURL: URL) throws -> Record? {
        let string = try storage.get(key: linkURL.absoluteString, from: Keys.namespace, or: "INVALID")
        guard let data = string.data(using: .utf8) else { return nil }
        let record = try JSONDecoder().decode(Record.self, from: data)
        if let dayLimit = config.recencyLimitInDays {
            // Dave please don't yell at me
            guard let daysSince = Calendar.current.dateComponents([.day], from: record.date, to: Date()).day else { return nil }
            if dayLimit > daysSince {
                return record
            } else {
                // Past limit, remove it
                storage.remove(key: linkURL.absoluteString, from: Keys.namespace)
                return nil
            }
        } else {
            return record
        }
    }
    
    func sendPrompt(bot: SlackBot, message: MessageDecorator, linkURL: URL, previousLink: URL) throws {
        let response = try message.respond()
        let comment = "👋 \(linkURL.absoluteString) is already being discussed here: \(previousLink.absoluteString)"
        response
            .text([comment])
            .newLine()
        try bot.send(response.makeChatMessage())
    }
    
    func markPreviousDiscussion(bot: SlackBot, message: MessageDecorator, linkURL: URL) throws {
        guard let channel = message.message.channel else { return }
        let permalink = try bot.permalink(message.message)
        guard let permalinkURL = URL(string: permalink) else { return }
        let record = Record(channelID: channel.id, permalink: permalinkURL)
        // Hack since Storage only takes strings for the moment
        let data = try JSONEncoder().encode(record)
        guard let string = String(data: data, encoding: .utf8) else { return }
        storage.set(value: string, forKey: linkURL.absoluteString, in: Keys.namespace)
    }
    
    func isLinkWhitelisted(link: URL) throws -> Bool {
        return false
    }

}
