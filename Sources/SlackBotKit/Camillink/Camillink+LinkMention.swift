import Chameleon
import Foundation

extension CamillinkService {
    
    func trackLink(bot: SlackBot, message: MessageDecorator) throws {
        guard !message.isIM else { return }
        guard let linkString = message.mentionedLinks.first.value?.value.link else { return }
        // Might be good to clean attribution links to prevent duplicates, etc...
        guard let linkURL = URL(string: linkString) else { return }
        if let previous = try previousLinkDiscussion(linkURL: linkURL) {
            guard try !shouldSilence(message: message, record: previous) else { return }
            try sendPrompt(bot: bot, message: message, linkURL: linkURL, previousLink: previous.permalink)
        } else {
            try markPreviousDiscussion(bot: bot, message: message, linkURL: linkURL)
        }
    }
    
    func previousLinkDiscussion(linkURL: URL) throws -> Record? {
        let string = try storage.get(key: linkURL.absoluteString, from: Keys.namespace, or: "")
        guard !string.isEmpty else { return nil }
        guard let data = string.data(using: .utf8) else { return nil }
        let record = try JSONDecoder().decode(Record.self, from: data)
        guard !isRecordExpired(record: record) else {
            storage.remove(key: linkURL.absoluteString, from: Keys.namespace)
            return nil
        }
        return record
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
    
    func shouldSilence(message: MessageDecorator, record: Record) throws -> Bool {
        return try shouldSilenceForWhitelisting(record: record) ||
            shouldSilenceForCrossLink(message: message, record: record) ||
            shouldSilenceForSameChannel(message: message, record: record)
    }
    
    func shouldSilenceForWhitelisting(record: Record) throws -> Bool {
        return false
    }
    
    func shouldSilenceForCrossLink(message: MessageDecorator, record: Record) -> Bool {
        guard config.silentCrossLink else { return false }
        let ids = message.mentionedChannels.map({ $0.value.id })
        .compactMap({ $0.split(separator: "|").first })
            .map({ String($0) })
        return ids.contains(record.channelID)
    }
    
    func shouldSilenceForSameChannel(message: MessageDecorator, record: Record) -> Bool {
        guard config.silentSameChannel else { return false }
        return message.message.channel?.id == record.channelID
    }
    
    func isRecordExpired(record: Record) -> Bool {
        guard let dayLimit = config.recencyLimitInDays else { return false }
        // Dave please don't yell at me
        guard let daysSince = Calendar.current.dateComponents([.day], from: record.date, to: Date()).day else { return true }
        return dayLimit < daysSince
    }

}
