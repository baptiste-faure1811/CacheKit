
import QuickLookThumbnailing
import UIKit

public final class CacheKit {

    private static let manager: FileManager = FileManager.default
    private static let cacheDirectory: String = "cache_kit_directory"
    private static let cacheSuiteName: String = "cache_kit_index"
    private static let cacheUserDefaults = UserDefaults(suiteName: cacheSuiteName)


    public static func getData(for id: String, type: FileType) -> Data? {
        return try? Data(contentsOf: url(for: id, type: type))
    }

    @discardableResult
    public static func saveData(for id: String, type: FileType, data: Data, version: Int) -> Error? {
        removeData(for: id, type: type)
        do {
            try data.write(to: url(for: id, type: type))
            cacheUserDefaults?.set(version, forKey: id)
            return nil
        } catch let error {
            return error
        }
    }

    public static func removeData(for id: String, type: FileType) {
        try? manager.removeItem(at: url(for: id, type: type))
        cacheUserDefaults?.removeObject(forKey: id)
    }

    public static func resetCache() {
        try? manager.removeItem(at: globalCacheDirectory())
        cacheUserDefaults?.removeSuite(named: cacheSuiteName)
    }

    public static func isInCache(_ id: String, type: FileType) -> Bool {
        return manager.fileExists(atPath: url(for: id, type: type).path)
    }

    public static func cacheVersion(for id: String) -> Int {
        return cacheUserDefaults?.integer(forKey: id) ?? 0
    }

    public static func getThumbnail(for id: String, type: FileType, size: CGSize = CGSize(width: 56, height: 82), representations: QLThumbnailGenerator.Request.RepresentationTypes = .thumbnail) async -> UIImage? {
        let request = await QLThumbnailGenerator.Request(fileAt: url(for: id, type: type), size: size, scale: UIScreen.main.scale, representationTypes: representations)
        return await withCheckedContinuation { continuation in
            QLThumbnailGenerator.shared.generateRepresentations(for: request) { thumbnail, type, error in
                continuation.resume(returning: thumbnail?.uiImage)
            }
        }
    }

    public static func temporaryCache(data: Data?, name: String, fileExtension: String) -> URL? {
        let cachePath = manager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileURL = cachePath.appendingPathComponent(name).appendingPathExtension(fileExtension)
        try? manager.removeItem(at: fileURL)
        try? data?.write(to: fileURL)
        return fileURL
    }

    public static func url(for id: String, type: FileType) -> URL {
        return cacheDirectory(for: type).appendingPathComponent(id + type.fileExtension)
    }

    public static func getCacheList(forType type: FileType) -> [String] {
        guard let files = try? manager.contentsOfDirectory(atPath: cacheDirectory(for: type).path) else { return [] }
        return files.map { $0.replacingOccurrences(of: type.fileExtension, with: "") }
    }
}

extension CacheKit {

    private static func cacheDirectory(for type: FileType) -> URL {
        let path = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let finalPath = path.appendingPathComponent(cacheDirectory, isDirectory: true).appendingPathComponent(type.directory, isDirectory: true)
        try? manager.createDirectory(at: finalPath, withIntermediateDirectories: true, attributes: nil)
        return finalPath
    }

    private static func globalCacheDirectory() -> URL {
        let path = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let finalPath = path.appendingPathComponent(cacheDirectory, isDirectory: true)
        try? manager.createDirectory(at: finalPath, withIntermediateDirectories: true, attributes: nil)
        return finalPath
    }
}
