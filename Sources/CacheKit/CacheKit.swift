
import Foundation

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
}

extension CacheKit {
    private static func url(for id: String, type: FileType) -> URL {
        return cacheDirectory(for: type).appendingPathComponent(id + type.fileExtension)
    }

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
