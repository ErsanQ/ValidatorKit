// MARK: - ValidationChain

/// A fluent builder for composing multiple validation rules.
///
/// Rules are evaluated in the order they are added. The chain stops
/// at the **first failure** and returns its error message.
///
/// ```swift
/// let result = ValidationChain()
///     .required()
///     .minLength(8)
///     .password(strength: .strong)
///     .validate("MyPass1!")
///
/// if case .invalid(let message) = result {
///     print(message)
/// }
/// ```
public struct ValidationChain: Sendable {

    // MARK: - Properties

    private var rules: [any ValidationRule]

    // MARK: - Init

    public init() {
        self.rules = []
    }

    // MARK: - Core

    /// Validates `value` against all added rules in order.
    ///
    /// Stops at the first failure and returns its error message.
    ///
    /// - Parameter value: The string to validate.
    /// - Returns: `.valid` if all rules pass, or `.invalid(message:)` on the first failure.
    public func validate(_ value: String) -> ValidationResult {
        for rule in rules {
            let result = rule.validate(value)
            if case .invalid = result { return result }
        }
        return .valid
    }

    /// Appends a custom rule to the chain.
    @discardableResult
    public func rule(_ rule: any ValidationRule) -> ValidationChain {
        var copy = self
        copy.rules.append(rule)
        return copy
    }
}

// MARK: - Built-in Rule Builders

public extension ValidationChain {

    /// Adds a ``RequiredRule``.
    @discardableResult
    func required(message: String = "This field is required.") -> ValidationChain {
        rule(RequiredRule(message: message))
    }

    /// Adds a ``MinLengthRule``.
    @discardableResult
    func minLength(_ min: Int, message: String? = nil) -> ValidationChain {
        rule(MinLengthRule(min, message: message))
    }

    /// Adds a ``MaxLengthRule``.
    @discardableResult
    func maxLength(_ max: Int, message: String? = nil) -> ValidationChain {
        rule(MaxLengthRule(max, message: message))
    }

    /// Adds an ``ExactLengthRule``.
    @discardableResult
    func exactLength(_ length: Int, message: String? = nil) -> ValidationChain {
        rule(ExactLengthRule(length, message: message))
    }

    /// Adds an ``EmailRule``.
    @discardableResult
    func email(message: String = "Please enter a valid email address.") -> ValidationChain {
        rule(EmailRule(message: message))
    }

    /// Adds a ``URLRule``.
    @discardableResult
    func url(message: String = "Please enter a valid URL.") -> ValidationChain {
        rule(URLRule(message: message))
    }

    /// Adds a ``PhoneRule``.
    @discardableResult
    func phone(message: String = "Please enter a valid phone number.") -> ValidationChain {
        rule(PhoneRule(message: message))
    }

    /// Adds a ``PasswordRule``.
    @discardableResult
    func password(
        strength: PasswordRule.Strength = .medium,
        message: String? = nil
    ) -> ValidationChain {
        rule(PasswordRule(strength: strength, message: message))
    }

    /// Adds a ``MatchesRule``.
    @discardableResult
    func matches(pattern: String, message: String) -> ValidationChain {
        rule(MatchesRule(pattern: pattern, message: message))
    }

    /// Adds a ``NumericRule``.
    @discardableResult
    func numeric(message: String = "Must contain numbers only.") -> ValidationChain {
        rule(NumericRule(message: message))
    }

    /// Adds an ``AlphanumericRule``.
    @discardableResult
    func alphanumeric(message: String = "Must contain letters and numbers only.") -> ValidationChain {
        rule(AlphanumericRule(message: message))
    }
}
