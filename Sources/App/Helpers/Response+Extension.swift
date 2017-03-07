import Vapor
import HTTP

extension Response {
    var message: Message? {
        get { return storage[Keys.messageType] as? Message }
        set { storage[Keys.messageType] = newValue }
    }
}
