import Chameleon
import SlackBotKit

let store = Environment()
let storage = RedisStorage(url: try store.get(forKey: "STORAGE_URL"))

let authenticator = OAuthAuthenticator(
    network: NetworkProvider(),
    storage: storage,
    clientId: try store.get(forKey: "CLIENT_ID"),
    clientSecret: try store.get(forKey: "CLIENT_SECRET"),
    scopes: [.channels_write, .chat_write_bot, .users_read],
    redirectUri: try? store.get(forKey: "REDIRECT_URI")
)

let bot = SlackBot(
    authenticator: authenticator,
    services: [
        KarmaService(storage: storage),
        CamillinkService(storage: storage),
        AutoModeratorService()
    ]
)

bot.on(message.self) { bot, data in
    let msg = data.message.makeDecorator()

    guard msg.text.patternMatches(against: ["hello"]) else { return }

    try bot.send(["hey!"], to: msg.target())
}

bot.start()
