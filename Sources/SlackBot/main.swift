import ChameleonKit
import Foundation
import LegibleError
import SlackBotKit
import VaporProviders

let env = Environment()
let storageUrl = URL(string: try env.get(forKey: "STORAGE_URL"))!
let storage = try! RedisStorage(url: storageUrl)

let bot = try SlackBot
    .vaporBased(
        verificationToken: try env.get(forKey: "VERIFICATION_TOKEN"),
        accessToken: try env.get(forKey: "ACCESS_TOKEN")
    )
    .enableHello()
    .enableKarma(config: .default(), storage: storage)
    .enableCamillink(config: .default(), storage: storage)
    .enableAutoModerator(config: .default())

//bot.listen(for: .error) { bot, error in
//    let channel = Identifier<Channel>(rawValue: "#camille-ionaires")
//    try bot.perform(.speak(in: channel, "\("Error: ", .bold) \(error.legibleLocalizedDescription)"))
//}

try bot.start()
