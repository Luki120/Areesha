import Foundation

/// credits ⇝ https://gist.github.com/leptos-null/e17d675496b5894fb2699c37589b3750
struct OrderedSet<Element: Hashable>: Sequence {
	private var order: [Element]
	private var membership: Set<Element>

	func makeIterator() -> IndexingIterator<Array<Element>> {
		order.makeIterator()
	}

	var underestimatedCount: Int { order.underestimatedCount }

	func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
		try order.withContiguousStorageIfAvailable(body)
	}
}

extension OrderedSet: ExpressibleByArrayLiteral {
	init(arrayLiteral elements: Element...) {
		self.init(elements)
	}
}

extension OrderedSet {
	init<S: Sequence>(_ elements: S) where S.Element == Element {
		self.init()
		elements.forEach { insert($0) }
	}

	mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
		newElements.forEach { insert($0) }
	}

    @discardableResult
    mutating func remove(at index: Int) -> Element {
        let element = order.remove(at: index)
        membership.remove(element)
        return element
    }

	mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
		order.removeAll(keepingCapacity: keepCapacity)
		membership.removeAll(keepingCapacity: keepCapacity)
	}

	static func += <S: Sequence>(lhs: inout Self, rhs: S) where S.Element == Element {
		lhs.append(contentsOf: rhs)
	}
}

extension OrderedSet: Decodable where Element: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let elements = try container.decode([Element].self)
		self.init(elements)
	}
}

extension OrderedSet: Encodable where Element: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(order)
	}
}

extension OrderedSet: Collection {
	subscript(position: Int) -> Element {
		order[position]
	}

	var startIndex: Int { order.startIndex }
	var endIndex: Int { order.endIndex }

	func index(after i: Int) -> Int {
		order.index(after: i)
	}

	var isEmpty: Bool { membership.isEmpty }
}

extension OrderedSet {
	init() {
		order = []
		membership = []
	}

	@discardableResult
	mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
		let result = membership.insert(newMember)
		if result.inserted {
			order.append(newMember)
		}
		return result
	}
}
