import ChameleonKit

extension SlackBot.Karma {
    public typealias CommentsFormatter = (Identifier<User>, Int) -> MarkdownString

    public struct Config {
        public var topUserLimit: Int
        public var positiveComments: [CommentsFormatter]
        public var negativeComments: [CommentsFormatter]

        public init(topUserLimit: Int, positiveComments: [CommentsFormatter], negativeComments: [CommentsFormatter]) {
            self.topUserLimit = topUserLimit
            self.positiveComments = positiveComments
            self.negativeComments = negativeComments
        }

        public static func `default`() -> Config {
            let positiveComments: [CommentsFormatter] = [
                { "You rock \($0)! Now at \($1)." },
                { "Nice job, \($0)! Your karma just bumped to \($1)." },
                { "Awesome \($0)! You’re now at \($1) \(pluralizedScoreString(from: $1))." },
            ]
            let negativeComments: [CommentsFormatter] = [
                { "booooo \($0)! Now at \($1)." },
                { "Tssss \($0). Dropped your karma to \($1)." },
                { "Sorry, but I have to drop \($0)’s karma down to \($1) \(pluralizedScoreString(from: $1))." },
            ]

            return Config(
                topUserLimit: 10,
                positiveComments: positiveComments,
                negativeComments: negativeComments
            )
        }
    }
}

private extension SlackBot.Karma.Config {
    /// Non-localized pluralization.
    ///
    /// - Parameter score: a camillecoin score.
    /// - Returns: `"camillecoin"` if score is 1; otherwise, `"camillecoins"`.
    /// - Note: Should be replaced by proper localized pluralization
    static func pluralizedScoreString(from score: Int) -> String {
        return score == 1 ? "camillecoin" : "camillecoins"
    }
}
