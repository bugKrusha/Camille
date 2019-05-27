
extension CamillinkService {

    public struct Config {

        // How many days have to have passed before a prompt. No limit if nil.
        let recencyLimitInDays: Int?

        // Whether camille should prompt if a message has a link and a reference to the channel it was originally posted in.
        // eg: "hey check out http://example.com that's being discussed in #exampletalk
        // if true, do not post a message
        let silentCrossLink: Bool

        // Whether camille should prompt if a message has a link that was posted earlier in the same channel.
        // if true, do not post a message when a link is in the same channel
        let silentSameChannel: Bool

        public init(recencyLimitInDays: Int?, silentCrossLink: Bool, silentSameChannel: Bool) {
            self.recencyLimitInDays = recencyLimitInDays
            self.silentCrossLink = silentCrossLink
            self.silentSameChannel = silentSameChannel
        }

        public static func `default`() -> Config {
            return Config(
                recencyLimitInDays: nil,
                silentCrossLink: true,
                silentSameChannel: true
            )
        }
    }
}

