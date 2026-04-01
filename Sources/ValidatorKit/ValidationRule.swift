import Foundation

// MARK: - ValidationRule Protocol

/// A type that validates a `String` value and returns a ``ValidationResult``.
///
/// Conform to `ValidationRule` to create your own custom rules:
///
/// ```swift
/// struct NoProfanityRule: ValidationRule {
///     func validate(_ value: String) -> ValidationResult {
///         let blocked = ["spam", "fake"]
///         let found = blocked.first { value.lowercased().contains($0) }
///         guard found == nil else {
///             return .invalid(message: "Value contains inappropriate content.")
///         }
///         return .valid
///     }
/// }
/// ```
public protocol ValidationRule: Sendable {
    func validate(_ value: String) -> ValidationResult
}

// MARK: - RequiredRule

/// Fails when the trimmed value is empty.
public struct RequiredRule: ValidationRule {
    let message: String

    public init(message: String = "This field is required.") {
        self.message = message
    }

    public func validate(_ value: String) -> ValidationResult {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? .invalid(message: message)
            : .valid
    }
}

// MARK: - MinLengthRule

/// Fails when the value has fewer characters than `min`.
public struct MinLengthRule: ValidationRule {
    let min: Int
    let message: String

    public init(_ min: Int, message: String? = nil) {
        self.min = min
        self.message = message ?? "Must be at least \(min) characters."
    }

    public func validate(_ value: String) -> ValidationResult {
        value.count >= min ? .valid : .invalid(message: message)
    }
}

// MARK: - MaxLengthRule

/// Fails when the value exceeds `max` characters.
public struct MaxLengthRule: ValidationRule {
    let max: Int
    let message: String

    public init(_ max: Int, message: String? = nil) {
        self.max = max
        self.message = message ?? "Must be no more than \(max) characters."
    }

    public func validate(_ value: String) -> ValidationResult {
        value.count <= max ? .valid : .invalid(message: message)
    }
}

// MARK: - EmailRule

/// Fails when the value is not a valid email address format.
public struct EmailRule: ValidationRule {
    let message: String

    public init(message: String = "Please enter a valid email address.") {
        self.message = message
    }

    public func validate(_ value: String) -> ValidationResult {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: value) ? .valid : .invalid(message: message)
    }
}

// MARK: - URLRule

/// Fails when the value is not a valid URL.
public struct URLRule: ValidationRule {
    let message: String

    public init(message: String = "Please enter a valid URL.") {
        self.message = message
    }

    public func validate(_ value: String) -> ValidationResult {
        guard let url = URL(string: value),
              url.scheme != nil,
              url.host != nil else {
            return .invalid(message: message)
        }
        return .valid
    }
}

// MARK: - PhoneRule

/// Fails when the value doesn't look like a phone number.
///
/// Accepts formats like `+1 555 000 0000`, `(555) 000-0000`, `5550000000`.
public struct PhoneRule: ValidationRule {
    let message: String

    public init(message: String = "Please enter a valid phone number.") {
        self.message = message
    }

    public func validate(_ value: String) -> ValidationResult {
        let cleaned = value.components(separatedBy: CharacterSet(charactersIn: " +-().")).joined()
        let isValid = cleaned.allSatisfy(\.isNumber) && (7...15).contains(cleaned.count)
        return isValid ? .valid : .invalid(message: message)
    }
}

// MARK: - PasswordRule

/// Validates password strength.
public struct PasswordRule: ValidationRule {

    /// The required strength level.
    public enum Strength: Sendable {
        /// At least 6 characters.
        case weak
        /// At least 8 characters with a digit.
        case medium
        /// At least 8 characters with uppercase, lowercase, digit, and special character.
        case strong
    }

    let strength: Strength
    let message: String?

    public init(strength: Strength = .medium, message: String? = nil) {
        self.strength = strength
        self.message = message
    }

    public func validate(_ value: String) -> ValidationResult {
        switch strength {
        case .weak:
            return value.count >= 6
                ? .valid
                : .invalid(message: message ?? "Password must be at least 6 characters.")

        case .medium:
            let hasDigit = value.contains(where: \.isNumber)
            guard value.count >= 8, hasDigit else {
                return .invalid(message: message ?? "Password must be at least 8 characters and include a number.")
            }
            return .valid

        case .strong:
            let hasUpper   = value.contains(where: \.isUppercase)
            let hasLower   = value.contains(where: \.isLowercase)
            let hasDigit   = value.contains(where: \.isNumber)
            let hasSpecial = value.contains(where: { "!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) })
            guard value.count >= 8, hasUpper, hasLower, hasDigit, hasSpecial else {
                return .invalid(message: message ?? "Password must be 8+ characters with uppercase, lowercase, number, and special character.")
            }
            return .valid
        }
    }
}

// MARK: - MatchesRule

/// Fails when the value doesn't match the given regular expression.
public struct MatchesRule: ValidationRule {
    let pattern: String
    let message: String

    public init(pattern: String, message: String) {
        self.pattern = pattern
        self.message = message
    }

    public func validate(_ value: String) -> ValidationResult {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: value) ? .valid : .invalid(message: message)
    }
}

// MARK: - ExactLengthRule

/// Fails when the value is not exactly `length` characters.
public struct ExactLengthRule: ValidationRule {
    let length: Int
    let message: String

    public init(_ length: Int, message: String? = nil) {
        self.length = length
        self.message = message ?? "Must be exactly \(length) characters."
    }

    public func validate(_ value: String) -> ValidationResult {
        value.count == length ? .valid : .invalid(message: message)
    }
}

// MARK: - NumericRule

/// Fails when the value contains non-numeric characters.
public struct NumericRule: ValidationRule {
    let message: String

    public init(message: String = "Must contain numbers only.") {
        self.message = message
    }

    public func validate(_ value: String) -> ValidationResult {
        value.allSatisfy(\.isNumber) ? .valid : .invalid(message: message)
    }
}

// MARK: - AlphanumericRule

/// Fails when the value contains characters other than letters and digits.
public struct AlphanumericRule: ValidationRule {
    let message: String

    public init(message: String = "Must contain letters and numbers only.") {
        self.message = message
    }

    public func validate(_ value: String) -> ValidationResult {
        value.allSatisfy { $0.isLetter || $0.isNumber } ? .valid : .invalid(message: message)
    }
}
