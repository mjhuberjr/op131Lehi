import Vapor

final class PasswordValidator: ValidationSuite {
    static func validate(input value: String) throws {
        try Count.containedIn(low: 8, high: 30).validate(input: value)
        let range = value.range(of: "^[a-z-]+$", options: .regularExpression)
        guard let _ = range else {
            throw error(with: value)
        }
    }
}
