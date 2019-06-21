import Chameleon
import Foundation

extension CamillinkService {

    func trackLink(bot: SlackBot, message: MessageDecorator) throws {
        // thread_broadcast event for the main channel will be marked hidden, ignore to avoid double posts
        guard !(message.message.subtype == .thread_broadcast && message.message.hidden) else { return }
        guard !message.isIM else { return }
        guard let linkString = message.mentionedLinks.first.value?.value.link else { return }
        guard linkString.hasPrefix("http") else { return } // Check actual link, make sure it's not mail.app etc
        // Might be good to clean attribution links to prevent duplicates, etc...
        guard let linkURL = URL(string: linkString) else { return }
        if let previous = try previousLinkDiscussion(linkURL: linkURL) {
            guard try !shouldSilence(message: message, record: previous) else { return }
            try sendPrompt(bot: bot, message: message, currentLinkURL: linkURL, record: previous)
        } else {
            try markPreviousDiscussion(bot: bot, message: message, linkURL: linkURL)
        }
    }

    func previousLinkDiscussion(linkURL: URL) throws -> Record? {
        let recordString = try storage.get(key: linkURL.absoluteString, from: Keys.namespace, or: "")
        guard !recordString.isEmpty, let recordData = recordString.data(using: .utf8) else { return nil }

        let record = try JSONDecoder().decode(Record.self, from: recordData)

        guard !isRecordExpired(record: record) else {
            storage.remove(key: linkURL.absoluteString, from: Keys.namespace)
            return nil
        }
        return record
    }

    func sendPrompt(bot: SlackBot, message: MessageDecorator, currentLinkURL: URL, record: Record) throws {
        let response = try message.respond(.threaded)
        let comment = "👋 That <\(currentLinkURL.absoluteString)|link> is already being discussed in "
            + "<\(record.permalink.absoluteString)|this message> in <#\(record.channelID)>"
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
        return shouldSilenceForWhitelisting(record: record) ||
            shouldSilenceForCrossLink(message: message, record: record) ||
            shouldSilenceForSameChannel(message: message, record: record)
    }

    func shouldSilenceForWhitelisting(record: Record) -> Bool {
        // Eventually implement whitelisting here
        // This is WIP until I get time to implement attachments
        // in Chameleon
        return false
    }

    func shouldSilenceForCrossLink(message: MessageDecorator, record: Record) -> Bool {
        guard config.silentCrossLink else { return false }
        let ids = message
            .mentionedChannels
            .map({ $0.value.id })
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

