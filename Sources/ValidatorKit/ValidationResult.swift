// MARK: - ValidationResult

/// The outcome of a validation check.
///
/// Every validation operation returns a `ValidationResult` — either `.valid`
/// if all rules pass, or `.invalid` carrying a human-readable error message.
///
/// ```swift
/// let result = ValidationChain().required().email().validate("hello")
///
/// switch result {
/// case .valid:
///     print("Good to go!")
/// case .invalid(let message):
///     print("Error:", message)
/// }
/// ```
public enum ValidationResult: Equatable, Sendable {

    /// The value passed all validation rules.
    case valid

    /// The value failed one or more rules.
    ///
    /// - Parameter message: A human-readable description of the failure,
    ///   suitable for display directly in the UI.
    case invalid(message: String)
}

// MARK: - Convenience

public extension ValidationResult {

    /// Returns `true` when the result is `.valid`.
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    /// Returns the error message, or `nil` when the result is `.valid`.
    var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}
