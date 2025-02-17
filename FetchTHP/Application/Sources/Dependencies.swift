//
//  Dependencies.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/16/25.
//

import Foundation

protocol InjectionKey {
    associatedtype Value

    static var liveValue: Value { get set }
    static var previewValue: Value? { get set }
}

extension InjectionKey {
    static var previewValue: Value? {
        get { nil }
        set {}
    }
}

struct InjectedValues {
    private static var current = InjectedValues()

    private static var isPreview: Bool {
        if let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"], isPreview == "1" {
            return true
        }

        return false
    }

    static subscript<K>(key: K.Type) -> K.Value where K: InjectionKey {
        get {
            if isPreview {
                return key.previewValue ?? key.liveValue
            }

            return key.liveValue
        }
        set {
            if isPreview {
                return key.previewValue = newValue
            }

            return key.liveValue = newValue
        }
    }

    static subscript<T>(_ keyPath: WritableKeyPath<InjectedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

@propertyWrapper
struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectedValues, T>

    var wrappedValue: T {
        get { InjectedValues[keyPath] }
        set { InjectedValues[keyPath] = newValue }
    }

    init(_ keyPath: WritableKeyPath<InjectedValues, T>) {
        self.keyPath = keyPath
    }
}
