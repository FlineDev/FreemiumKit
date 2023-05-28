import Foundation

#warning("🧑‍💻 consider adding to HandySwift")
extension Sequence {
   /// Returns the first matching element in a sequence with an Equatable keypath value equal to the provided value.
   public func first<Value: Equatable>(where keyPath: KeyPath<Element, Value>, equalsTo otherValue: Value) -> Element? {
      self.first { $0[keyPath: keyPath] == otherValue }
   }

   /// Returns a Boolean value indicating whether the sequence contains an element with an Equatable keypath value equal to the provided value.
   public func contains<Value: Equatable>(where keyPath: KeyPath<Element, Value>, equalTo otherValue: Value) -> Bool {
      self.contains { $0[keyPath: keyPath] == otherValue }
   }

   /// Returns a Boolean value indicating whether the sequence contains an element with an Equatable keypath value not equal to the provided value.
   public func contains<Value: Equatable>(where keyPath: KeyPath<Element, Value>, notEqualTo otherValue: Value) -> Bool {
      self.contains { $0[keyPath: keyPath] == otherValue }
   }

   /// Returns a Boolean value indicating whether the sequence contains an element with a String keypath value that begins with the specified prefix.
   public func contains(where keyPath: KeyPath<Element, String>, prefixedBy prefix: String) -> Bool {
      self.contains { $0[keyPath: keyPath].hasPrefix(prefix) }
   }

   /// Returns a Boolean value indicating whether the sequence contains an element with a String keypath value that begins with one of the specified prefixes.
   public func contains(where keyPath: KeyPath<Element, String>, prefixedByOneOf prefixes: some Sequence<String>) -> Bool {
      prefixes.contains { self.contains(where: keyPath, prefixedBy: $0) }
   }

   /// Returns a Boolean value indicating whether the sequence contains an element with a String keypath value that contains the specified substring.
   public func contains(where keyPath: KeyPath<Element, String>, contains substring: String) -> Bool {
      self.contains { $0[keyPath: keyPath].contains(substring) }
   }

   /// Returns a Boolean value indicating whether the sequence contains an element with a String keypath value that contains one of the specified substrings.
   public func contains(where keyPath: KeyPath<Element, String>, containsOneOf substrings: [String]) -> Bool {
      substrings.contains { self.contains(where: keyPath, contains: $0) }
   }

   /// Returns a Boolean value indicating whether the sequence contains an element with a String keypath value that ends with the specified suffix.
   public func contains(where keyPath: KeyPath<Element, String>, suffixedBy suffix: String) -> Bool {
      self.contains { $0[keyPath: keyPath].hasSuffix(suffix) }
   }

   /// Returns a Boolean value indicating whether the sequence contains an element with a String keypath value that ends with one of the specified suffixes.
   public func contains(where keyPath: KeyPath<Element, String>, suffixedByOneOf suffixes: [String]) -> Bool {
      suffixes.contains { self.contains(where: keyPath, suffixedBy: $0) }
   }
}
