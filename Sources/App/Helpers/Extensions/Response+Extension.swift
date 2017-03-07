import Vapor
import HTTP

extension Response {
    var message: Message? {
        get { return storage[Keys.messageStorage] as? Message }
        set { storage[Keys.messageStorage] = newValue }
    }
    
    var messages: [Message]? {
        get { return storage[Keys.messagesStorage] as? [Message] }
        set { storage[Keys.messagesStorage] = newValue }
    }
}
