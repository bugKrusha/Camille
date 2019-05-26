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
            try sendPrompt(bot: bot, message: message, linkURL: linkURL, previousLink: previous)
        } else {
            try markPreviousDiscussion(message: message, linkURL: linkURL)
        }

    }
    
    func previousLinkDiscussion(linkURL: URL) throws -> URL? {
        let urlString: String = try storage.get(key: linkURL.absoluteString, from: Keys.namespace, or: "INVALID")
        return URL(string: urlString)
    }
    
    func sendPrompt(bot: SlackBot, message: MessageDecorator, linkURL: URL, previousLink: URL) throws {
        let response = try message.respond()
        let comment = "👋 \(linkURL.absoluteString) is already being discussed here: \(previousLink.absoluteString)"
        response
            .text([comment])
            .newLine()
        try bot.send(response.makeChatMessage())
    }
    
    func markPreviousDiscussion(message: MessageDecorator, linkURL: URL    ) throws {
        guard let channel = message.message.channel else { return }
        // TODO: MAXG pending Chameleon change to get permalink
//        storage.set(value: channel.id, forKey: linkURL.absoluteString, in: Keys.namespace)
    }
    
    func isLinkWhitelisted(link: URL) throws -> Bool {
        return false
    }

}
