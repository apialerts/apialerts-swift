protocol Client {
    func configure(apiKey: String, debug: Bool)
    func send(apiKey: String?, channel: String?, message: String, tags: [String]?, link: String?)
    func sendAsync(apiKey: String?, channel: String?, message: String, tags: [String]?, link: String?) async
}

class ClientImpl: Client {

    private var defaultKey: String? = nil
    private var debug: Bool = false

    func configure(apiKey: String, debug: Bool) {
        self.defaultKey = apiKey
        self.debug = debug
    }

    func send(apiKey: String?, channel: String?, message: String, tags: [String]?, link: String?) {
        Task {
            await sendAsync(
                apiKey: apiKey,
                channel: channel,
                message: message,
                tags: tags,
                link: link
            )
        }
    }

    func sendAsync(apiKey: String?, channel: String?, message: String, tags: [String]?, link: String?) async {
        let useKey = apiKey ?? defaultKey ?? ""
        
        if useKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("x (apialerts.com) Error: API Key not provided. Use configure() to set a default key, or pass the key as a parameter to the send function.")
            return
        }

        if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("x (apialerts.com) Error: Message is required")
            return
        }

        let payload = EventRequest(
            channel: channel,
            message: message,
            tags: tags,
            link: link
        )

        let response = await EventEndpoints.send(useKey, payload)
        switch response {
        case .success(let data):
            if debug {
                print("✓ (apialerts.com) Alert sent to \(data.workspace ?? "??") (\(data.channel ?? "??")) successfully.")
                data.errors?.forEach { text in
                    print("! (apialerts.com) Warning: \(text)")
                }
            }
        case .failure(let error):
            if debug {
                print("x (apialerts.com) Error: \(error.message)")
            }
        }
    }
}
