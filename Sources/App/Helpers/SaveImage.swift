import Vapor
import Foundation

struct SaveImage {
    fileprivate static func imagePath(imageName: String) -> (imagePath: String, savePath: String) {
        let imagePath = "profile/images/\(NSUUID().uuidString)\(imageName)".removeWhitespace()
        let savePath = drop.workDir + "Public/" + imagePath
        return (imagePath, savePath)
    }
    
    
    static func save(imageName: String?, image: Bytes?) throws -> String {
        guard let imageName = imageName,
            let image = image else { throw Abort.badRequest }
        let result = SaveImage.imagePath(imageName: imageName)
        FileManager.default.createFile(atPath: result.savePath, contents: Data(bytes: image), attributes: nil)
        return result.imagePath
    }
    
    static func removeImage(for imagePath: String?) throws {
        if let imagePath = imagePath {
            if imagePath.characters.count > 0 {
                let savePath = drop.workDir + "Public/" + imagePath
                try FileManager.default.removeItem(atPath: savePath)
            }
        }
    }
}
