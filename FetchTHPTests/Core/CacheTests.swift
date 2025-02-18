//
//  CacheTests.swift
//  FetchTHPTests
//
//  Created by Petlyuk, Oleksiy on 2/17/25.
//

import Testing
import Foundation
@testable import FetchTHP

class CacheTests {
    private let fileManager = FileManager.default
    private let cacheName = "TestCache"
    private let cacheDirectory: URL

    init() {
        cacheDirectory = fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(cacheName, isDirectory: true)

        try? fileManager.removeItem(at: cacheDirectory)
    }

    deinit {
        try? fileManager.removeItem(at: cacheDirectory)
    }

    func makeSUT(dateProvider: @escaping () -> Date = { .now }) -> Cache<String, String> {
        return Cache(dateProvider: dateProvider, entryLifetime: 10, cacheName: cacheName, fileManager: fileManager)
    }

    @Test func insert_shouldWriteEntryToMemory() throws {
        let sut = makeSUT()
        let key = UUID().uuidString
        let value = UUID().uuidString

        sut.insert(value, forKey: key)
        let result = sut.value(forKey: key)

        #expect(result == value)
    }

    @Test func insert_shouldWriteEntryToDisk() {
        let sut = makeSUT()
        let key = UUID().uuidString
        let value = UUID().uuidString
        sut.insert(value, forKey: key)

        // Create new sut to force retrieval from disk
        let newSut = makeSUT()
        let result = newSut.value(forKey: key)

        #expect(result == value)
    }

    @Test func value_shouldNotReturnExpiredEntry() {
        var currentDate = Date.now
        let sut = makeSUT(dateProvider: { currentDate })
        let key = UUID().uuidString
        let value = UUID().uuidString
        sut.insert(value, forKey: key)

        currentDate = currentDate.addingTimeInterval(20)
        let result = sut.value(forKey: key)

        #expect(result == nil)
    }

    @Test func removeValue_shouldRemoveEntryFromMemoryAndDisk() {
        let sut = makeSUT()
        let key = UUID().uuidString
        let value = UUID().uuidString
        sut.insert(value, forKey: key)

        sut.removeValue(forKey: key)
        let memoryValue = sut.value(forKey: key)
        #expect(memoryValue == nil)

        let fileURL = cacheDirectory.appendingPathComponent(key).appendingPathExtension("cache")
        #expect(fileManager.fileExists(atPath: fileURL.path) == false)
    }

    @Test func subscript_shouldSetAndReadEntry() {
        let sut = makeSUT()
        let key = UUID().uuidString
        let value = UUID().uuidString

        sut[key] = value
        #expect(sut[key] == value)

        sut[key] = nil
        #expect(sut[key] == nil)
    }
}
