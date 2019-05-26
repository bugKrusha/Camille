import Chameleon

extension CamillinkService {
    
    enum Patterns: PatternRepresentable {
        
        case http

        var pattern: [Matcher] {
            switch self {
            case .http: return [String.any.orNone, "<http", "s".orNone, "://", String.any, ">"]
            }
        }

        var strict: Bool { return false }
    }
}
