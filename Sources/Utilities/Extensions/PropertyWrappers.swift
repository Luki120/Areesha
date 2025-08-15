import UIKit

// ! Foundation

struct CodableDefaults<Value: Codable> {
	let key: String

	func load(defaultValue: Value) -> Value {
		guard let data = UserDefaults.standard.data(forKey: key),
			let decodedData = try? JSONDecoder().decode(Value.self, from: data) else {
				return defaultValue
			}
			return decodedData
	}

	func save(_ value: Value) {
		guard let encodedData = try? JSONEncoder().encode(value) else { return }
		UserDefaults.standard.set(encodedData, forKey: key)
	}
}

@propertyWrapper
struct Storage<Value: Codable> {
	private let codableDefaults: CodableDefaults<Value>
	private let defaultValue: Value

	var wrappedValue: Value {
		get { codableDefaults.load(defaultValue: defaultValue) }
		set { codableDefaults.save(newValue) }
	}

	init(key: String, defaultValue: Value) {
		self.codableDefaults = .init(key: key)
		self.defaultValue = defaultValue
	}
}

@propertyWrapper
final class PublishedStorage<Value: Codable>: ObservableObject {
	private let codableDefaults: CodableDefaults<Value>
	private let defaultValue: Value

	@Published
	private var value: Value

	var wrappedValue: Value {
		get { value }
		set {
			value = newValue
			codableDefaults.save(newValue)
		}
	}

	var projectedValue: Published<Value>.Publisher {
		$value
	}

	init(key: String, defaultValue: Value) {
		self.codableDefaults = .init(key: key)
		self.defaultValue = defaultValue
		self.value = codableDefaults.load(defaultValue: defaultValue)
	}
}

// ! UIKit

@propertyWrapper
@MainActor
struct UsesAutoLayout<T: UIView> {
	var wrappedValue: T {
		didSet {
			wrappedValue.translatesAutoresizingMaskIntoConstraints = false
		}
	}

	init(wrappedValue: T) {
		self.wrappedValue = wrappedValue
		wrappedValue.translatesAutoresizingMaskIntoConstraints = false
	}
}
