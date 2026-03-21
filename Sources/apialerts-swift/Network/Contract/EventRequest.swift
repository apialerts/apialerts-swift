import Foundation

struct EventRequest: Encodable {
    let message: String
    let channel: String?
    let event: String?
    let title: String?
    let tags: [String]?
    let link: String?
    let data: (any Encodable)?

    init(from src: Event) {
        self.message = src.message
        self.channel = src.channel
        self.event = src.event
        self.title = src.title
        self.tags = src.tags
        self.link = src.link
        self.data = src.data
    }

    enum CodingKeys: String, CodingKey {
        case message, channel, event, title, tags, link, data
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encodeIfPresent(channel, forKey: .channel)
        try container.encodeIfPresent(event, forKey: .event)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(link, forKey: .link)
        if let data {
            try data.encode(to: container.superEncoder(forKey: .data))
        }
    }
}
