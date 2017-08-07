import Chameleon

let store = Environment()

let authenticator = OAuthAuthenticator(
    network: NetworkProvider(),
    clientId: try store.get(forKey: "CLIENT_ID"),
    clientSecret: try store.get(forKey: "CLIENT_SECRET"),
    scopes: [.channels_write, .chat_write_bot, .users_read]
)

let bot = SlackBot(
    authenticator: authenticator,
    services: []
)

bot.on(message.self) { bot, data in
    let msg = data.message.makeDecorator()

    guard msg.text.patternMatches(against: ["hello"]) else { return }

    let response = try msg
        .respond()
        .text(["hey!"])
        .makeChatMessage()

    try bot.send(response)
}

bot.start()
