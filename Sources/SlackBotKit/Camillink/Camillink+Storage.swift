import Foundation

extension CamillinkService {

    public struct Record: Codable {

        let date: Date
        let channelID: String
        let permalink: URL

        init(channelID: String, permalink: URL){
            self.date = Date()
            self.channelID = channelID
            self.permalink = permalink
        }

    }
}

