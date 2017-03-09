import Foundation

extension String {
    func removeWhitespace() -> String {
        return replacingOccurrences(of: " +", with: "", options: .regularExpression, range: nil)
    }
}
