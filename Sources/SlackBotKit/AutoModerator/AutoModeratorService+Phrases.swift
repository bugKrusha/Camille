//
//extension AutoModeratorService {
//    typealias Responses = [String]
//
//    enum TriggerPhrase: String {
//        case youGuys = "you guys"
//        case thanksGuys = "thanks guys"
//        case hiGuys = "hi guys"
//        case heyGuys = "hey guys"
//
//        static let all: [TriggerPhrase] = [.youGuys, .thanksGuys, .hiGuys, .heyGuys]
//    }
//    
//    enum AutoModeratorError: Error {
//        case noResponseForTriggerFound
//    }
//
//    struct MessageResponse {
//        static let inclusivity: Responses = [
//            "Maybe next time, consider using “y’all” or “folks” instead. It’s more inclusive "
//                + "than “guys”. :slightly_smiling_face:"
//        ]
//    }
//
//    func getResponses(for trigger: TriggerPhrase) -> Responses {
//        switch trigger {
//        case .heyGuys, .hiGuys, .thanksGuys, .youGuys:
//            return MessageResponse.inclusivity
//        }
//    }
//}
