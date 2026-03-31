import Foundation

/// A high-performance, declarative data validation engine.
///
/// `Validator` allows you to chain validation rules together to ensure
/// user input meets your application's requirements before processing.
///
/// ## Usage
/// ```swift
/// let isValid = Validator()
///     .required()
///     .email()
///     .validate("test@example.com")
/// ```
public struct Validator: Sendable {
    
    private var rules: [(@Sendable (String) -> Bool)] = []
    
    /// Creates a new, empty validator.
    public init() {}
    
    /// Adds a rule requiring the string to contain at least one character.
    ///
    /// - Returns: A new validator instance with the added rule.
    public func required() -> Validator {
        var copy = self
        copy.rules.append { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return copy
    }
    
    /// Adds a rule requiring the string to be a valid email format.
    ///
    /// - Returns: A new validator instance with the added rule.
    public func email() -> Validator {
        var copy = self
        copy.rules.append { value in
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: value)
        }
        return copy
    }
    
    /// Validates the provided string against all configured rules.
    ///
    /// - Parameter value: The string to validate.
    /// - Returns: `true` if every rule is satisfied, otherwise `false`.
    public func validate(_ value: String) -> Bool {
        for rule in rules {
            if !rule(value) { return false }
        }
        return true
    }
}
