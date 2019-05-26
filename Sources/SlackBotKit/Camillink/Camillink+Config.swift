
extension CamillinkService {
    
    public struct Config {
        
        // How many days have to have passed before a prompt. No limit if nil.
        let recencyLimitInDays: Int?
        
        public init(recencyLimitInDays: Int?) {
            self.recencyLimitInDays = recencyLimitInDays
        }
        
        public static func `default`() -> Config {
            return Config(
                recencyLimitInDays: nil
            )
        }
    }
}
