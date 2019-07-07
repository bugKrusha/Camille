import Chameleon

/// A service that observes every message in a public channel, determines whether it requires an automatic moderator
/// response based on the message contents and replies with an in-line thread.
public final class AutoModeratorService: SlackBotMessageService {

    public init() {}

    public func onMessage(slackBot: SlackBot, message: MessageDecorator, previous: MessageDecorator?) throws {
        guard !(message.message.subtype == .thread_broadcast && message.message.hidden) else { return }

        if let messageText = message.message.text?.lowercased(), let trigger = containsTriggerPhrase(messageText) {
            do {
                try sendThreadedResponse(from: slackBot, to: message, with: trigger)
            } catch let error {
                print("Error sending AutoModerator response: \(error)")
            }
        }
    }

    func sendThreadedResponse(from bot: SlackBot, to message: MessageDecorator, with trigger: TriggerPhrase) throws {
        let response = try message.respond(.threaded)

        guard let comment = TriggerResponses.all[trigger]?.responses.randomElement() else {
            throw AutoModeratorError.noResponseForTriggerFound
        }

        response
            .text([comment])
            .newLine()
        try bot.send(response.makeChatMessage())
    }


    func containsTriggerPhrase(_ messageText: String) -> TriggerPhrase? {
        for trigger in TriggerPhrase.allCases {
            if messageText.contains(trigger.rawValue) {
                return trigger
            }
        }

        return nil
    }
}
