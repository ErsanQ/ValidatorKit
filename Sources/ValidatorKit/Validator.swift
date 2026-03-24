// MARK: - Validator

/// A collection of static convenience methods for quick, single-rule validation.
///
/// Use `Validator` when you need a fast inline check without building a chain:
///
/// ```swift
/// // Quick checks
/// Validator.isEmail("user@example.com")    // true
/// Validator.isPhone("+1 555 000 0000")     // true
///
/// // With result
/// let result = Validator.validate("", rule: .required)
/// // → .invalid(message: "This field is required.")
///
/// // Combine with any rule
/// let result2 = Validator.validate("abc", rules: [.required, .minLength(6)])
/// ```
public enum Validator {

    // MARK: - Single Rule

    /// Validates `value` against a single rule.
    public static func validate(
        _ value: String,
        rule: any ValidationRule
    ) -> ValidationResult {
        rule.validate(value)
    }

    /// Validates `value` against multiple rules in order.
    ///
    /// Stops at the first failure.
    public static func validate(
        _ value: String,
        rules: [any ValidationRule]
    ) -> ValidationResult {
        for rule in rules {
            let result = rule.validate(value)
            if case .invalid = result { return result }
        }
        return .valid
    }

    // MARK: - Boolean Shortcuts

    /// Returns `true` if `value` is a valid email address.
    public static func isEmail(_ value: String) -> Bool {
        EmailRule().validate(value).isValid
    }

    /// Returns `true` if `value` is a valid URL.
    public static func isURL(_ value: String) -> Bool {
        URLRule().validate(value).isValid
    }

    /// Returns `true` if `value` looks like a valid phone number.
    public static func isPhone(_ value: String) -> Bool {
        PhoneRule().validate(value).isValid
    }

    /// Returns `true` if `value` is not empty (after trimming whitespace).
    public static func isNotEmpty(_ value: String) -> Bool {
        RequiredRule().validate(value).isValid
    }

    /// Returns `true` if `value` is a strong password.
    public static func isStrongPassword(_ value: String) -> Bool {
        PasswordRule(strength: .strong).validate(value).isValid
    }

    /// Returns `true` if `value` is purely numeric.
    public static func isNumeric(_ value: String) -> Bool {
        NumericRule().validate(value).isValid
    }

    /// Returns `true` if `value` is alphanumeric.
    public static func isAlphanumeric(_ value: String) -> Bool {
        AlphanumericRule().validate(value).isValid
    }
}
