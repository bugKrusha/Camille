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
                { "You rock, \($0)! Now at \($1)." },
                { "Nice job, \($0)! Your karma just bumped to \($1)." },
                { "Awesome, \($0)! You’re now at \($1) \(pluralizedScoreString(from: $1))." },
                { "Fantastic work, \($0)! You earned \($1) magic points." },
                { "Well done, \($0)! You scored \($1) karma." },
                { "Great job, \($0)! You achieved \($1) \(pluralizedScoreString(from: $1))." },
                { "Impressive, \($0)! You got \($1) magic points." },
                { "You're amazing, \($0)! \($1) karma for you!" },
                { "Excellent, \($0)! You racked up \($1) \(pluralizedScoreString(from: $1))." },
                { "Brilliant, \($0)! You secured \($1) magic points." },
                { "Outstanding, \($0)! You gained \($1) karma." },
                { "Superb, \($0)! You accumulated \($1) \(pluralizedScoreString(from: $1))." },
                { "Keep it up, \($0)! \($1) magic points are yours!" },
            ]
            let negativeComments: [CommentsFormatter] = [
                { "Booooo, \($0)! Now at \($1)." },
                { "Tssss, \($0). Dropped your karma to \($1)." },
                { "Sorry, but I have to drop \($0)’s karma down to \($1) \(pluralizedScoreString(from: $1))." },
                { "Not your best, \($0). You're down to \($1) magic points." },
                { "Disappointing, \($0). You dropped to \($1) karma." },
                { "Poor effort, \($0). You decreased to \($1) \(pluralizedScoreString(from: $1))." },
                { "Unimpressive, \($0). \($1) magic points are what you have left." },
                { "You can do better, \($0). \($1) karma remaining." },
                { "Needs improvement, \($0). You fell to \($1) \(pluralizedScoreString(from: $1))." },
                { "Not great, \($0). Only \($1) magic points left over." },
                { "Try harder, \($0). You are down to \($1) karma." },
                { "Below par, \($0). You decreased by \($1) \(pluralizedScoreString(from: $1))." },
                { "Disappointing, \($0). \($1) magic points still available." },
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
