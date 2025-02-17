//
//  Cache.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/15/25.
//

import Foundation

final class Cache<Key: Hashable & Codable, Value: Codable> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let fileManager: FileManager
    private let diskCacheURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        dateProvider: @escaping () -> Date = Date.init,
        entryLifetime: TimeInterval = 12 * 60 * 60,
        cacheName: String,
        fileManager: FileManager = .default
    ) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        self.fileManager = fileManager

        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.diskCacheURL = cacheDirectory.appendingPathComponent(cacheName, isDirectory: true)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }

    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        insert(entry)
    }

    func value(forKey key: Key) -> Value? {
        entry(forKey: key)?.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))

        if let fileURL = fileURL(forKey: key) {
            try? fileManager.removeItem(at: fileURL)
        }
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

// MARK: - Disk Cache Helpers
private extension Cache {
    func fileURL(forKey key: Key) -> URL? {
        guard let keyData = try? encoder.encode(key) else { return nil }

        let keyHash = keyData.base64EncodedString().replacingOccurrences(of: "/", with: "-")

        return diskCacheURL.appendingPathComponent(keyHash).appendingPathExtension("cache")
    }

    func encoded(_ value: Entry) -> Data? {
        try? encoder.encode(value)
    }

    func decoded(_ data: Data) -> Entry? {
        try? decoder.decode(Entry.self, from: data)
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else { return false }

            return value.key == key
        }
    }

    final class Entry: Codable {
        let key: Key
        let value: Value
        let expirationDate: Date

        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

private extension Cache {
    func entry(forKey key: Key) -> Entry? {
        var entry = wrapped.object(forKey: WrappedKey(key))

        if entry == nil, let fileURL = fileURL(forKey: key), let data = try? Data(contentsOf: fileURL) {
            entry = decoded(data)

            if let entry {
                insert(entry.value, forKey: key)
            }
        }

        guard let entry else { return nil }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)

            return nil
        }

        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))

        if let data = encoded(entry), let fileURL = fileURL(forKey: entry.key) {
            try? data.write(to: fileURL)
        }
    }
}
