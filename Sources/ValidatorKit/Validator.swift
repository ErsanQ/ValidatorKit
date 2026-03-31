import Foundation

/// A declarative data validation engine.
public struct Validator: Sendable {
    
    private var rules: [(String) -> Bool] = []
    
    public init() {}
    
    /// Adds a rule requiring the value to be non-empty.
    public func required() -> Validator {
        var copy = self
        copy.rules.append { !$0.isEmpty }
        return copy
    }
    
    /// Adds a rule requiring the value to be a valid email format.
    public func email() -> Validator {
        var copy = self
        copy.rules.append { value in
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: value)
        }
        return copy
    }
    
    /// Validates the input string against all rules.
    public func validate(_ value: String) -> Bool {
        for rule in rules {
            if !rule(value) { return false }
        }
        return true
    }
}
