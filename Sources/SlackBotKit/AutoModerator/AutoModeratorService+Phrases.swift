
extension AutoModeratorService {
    enum TriggerPhrase: String, CaseIterable {
        case youGuys = "you guys"
        case thanksGuys = "thanks guys"
        case hiGuys = "hi guys"
        case heyGuys = "hey guys"
    }
    
    enum AutoModeratorError: Error {
        case noResponseForTriggerFound
    }

    enum MessageResponse {
        case inclusivity

        var responses: [String] {
            switch self {
            case .inclusivity:
                return [
                    "Maybe next time, consider using “y’all” or “folks” instead. It’s more inclusive "
                        + "than “guys”. :slightly_smiling_face:"
                ]
            }
        }
    }

    public struct TriggerResponses {
        static let all: [TriggerPhrase: MessageResponse] = [
            .youGuys: .inclusivity,
            .thanksGuys: .inclusivity,
            .hiGuys: .inclusivity,
            .heyGuys: .inclusivity
        ]
    }
}
