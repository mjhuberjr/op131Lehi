import Vapor
import Foundation

struct SaveImage {
    fileprivate static func imagePath(imageName: String) -> (imagePath: String, savePath: String) {
        let imagePath = "profile/image/\(NSUUID().uuidString).\(imageName)".removeWhitespace()
        let savePath = drop.workDir + "Public/" + imagePath
        return (imagePath, savePath)
    }
    
    static func removeImage(for imagePath: String?) throws {
        if let imagePath = imagePath {
            if imagePath.characters.count > 0 {
                let savePath = drop.workDir + "Public/" + imagePath
                try FileManager.default.removeItem(atPath: savePath)
            }
        }
    }
    
    static func save(image: Multipart.File) throws -> String {
        guard let imageName = image.name else { throw Abort.badRequest }
        let result = SaveImage.imagePath(imageName: imageName)
        FileManager.default.createFile(atPath: result.savePath, contents: Data(bytes: image.data), attributes: nil)
        return result.imagePath
    }
}
