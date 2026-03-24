import XCTest
@testable import ValidatorKit

final class ValidatorKitTests: XCTestCase {

    // MARK: - RequiredRule

    func test_required_emptyString_isInvalid() {
        XCTAssertFalse(RequiredRule().validate("").isValid)
    }

    func test_required_whitespaceOnly_isInvalid() {
        XCTAssertFalse(RequiredRule().validate("   ").isValid)
    }

    func test_required_nonEmptyString_isValid() {
        XCTAssertTrue(RequiredRule().validate("hello").isValid)
    }

    // MARK: - MinLengthRule

    func test_minLength_shortString_isInvalid() {
        XCTAssertFalse(MinLengthRule(8).validate("abc").isValid)
    }

    func test_minLength_exactLength_isValid() {
        XCTAssertTrue(MinLengthRule(5).validate("hello").isValid)
    }

    func test_minLength_longerString_isValid() {
        XCTAssertTrue(MinLengthRule(3).validate("hello world").isValid)
    }

    // MARK: - MaxLengthRule

    func test_maxLength_tooLong_isInvalid() {
        XCTAssertFalse(MaxLengthRule(5).validate("toolongstring").isValid)
    }

    func test_maxLength_withinLimit_isValid() {
        XCTAssertTrue(MaxLengthRule(10).validate("hello").isValid)
    }

    // MARK: - EmailRule

    func test_email_validFormat_isValid() {
        XCTAssertTrue(EmailRule().validate("user@example.com").isValid)
        XCTAssertTrue(EmailRule().validate("user.name+tag@sub.domain.io").isValid)
    }

    func test_email_missingAt_isInvalid() {
        XCTAssertFalse(EmailRule().validate("userexample.com").isValid)
    }

    func test_email_missingDomain_isInvalid() {
        XCTAssertFalse(EmailRule().validate("user@").isValid)
    }

    func test_email_empty_isInvalid() {
        XCTAssertFalse(EmailRule().validate("").isValid)
    }

    // MARK: - URLRule

    func test_url_validHTTPS_isValid() {
        XCTAssertTrue(URLRule().validate("https://apple.com").isValid)
    }

    func test_url_validHTTP_isValid() {
        XCTAssertTrue(URLRule().validate("http://example.com/path?query=1").isValid)
    }

    func test_url_missingScheme_isInvalid() {
        XCTAssertFalse(URLRule().validate("apple.com").isValid)
    }

    // MARK: - PhoneRule

    func test_phone_validFormats_areValid() {
        XCTAssertTrue(PhoneRule().validate("+1 555 000 0000").isValid)
        XCTAssertTrue(PhoneRule().validate("5550001234").isValid)
        XCTAssertTrue(PhoneRule().validate("+441234567890").isValid)
    }

    func test_phone_tooShort_isInvalid() {
        XCTAssertFalse(PhoneRule().validate("123").isValid)
    }

    // MARK: - PasswordRule

    func test_password_weak_shortPassword_isInvalid() {
        XCTAssertFalse(PasswordRule(strength: .weak).validate("abc").isValid)
    }

    func test_password_medium_noDigit_isInvalid() {
        XCTAssertFalse(PasswordRule(strength: .medium).validate("password").isValid)
    }

    func test_password_medium_withDigit_isValid() {
        XCTAssertTrue(PasswordRule(strength: .medium).validate("password1").isValid)
    }

    func test_password_strong_allRequirements_isValid() {
        XCTAssertTrue(PasswordRule(strength: .strong).validate("MyPass1!").isValid)
    }

    func test_password_strong_missingSpecial_isInvalid() {
        XCTAssertFalse(PasswordRule(strength: .strong).validate("MyPass123").isValid)
    }

    // MARK: - NumericRule

    func test_numeric_digitsOnly_isValid() {
        XCTAssertTrue(NumericRule().validate("12345").isValid)
    }

    func test_numeric_withLetters_isInvalid() {
        XCTAssertFalse(NumericRule().validate("123abc").isValid)
    }

    // MARK: - AlphanumericRule

    func test_alphanumeric_lettersAndDigits_isValid() {
        XCTAssertTrue(AlphanumericRule().validate("abc123").isValid)
    }

    func test_alphanumeric_withSpecialChar_isInvalid() {
        XCTAssertFalse(AlphanumericRule().validate("abc@123").isValid)
    }

    // MARK: - ValidationChain

    func test_chain_stopsAtFirstFailure() {
        let chain = ValidationChain().required().minLength(8).email()
        let result = chain.validate("")
        // required fails first
        XCTAssertEqual(result, .invalid(message: "This field is required."))
    }

    func test_chain_allRulesPass_isValid() {
        let chain = ValidationChain().required().email()
        XCTAssertTrue(chain.validate("user@example.com").isValid)
    }

    func test_chain_passwordFlow_isValid() {
        let result = ValidationChain()
            .required()
            .minLength(8)
            .password(strength: .strong)
            .validate("MyPass1!")
        XCTAssertTrue(result.isValid)
    }

    // MARK: - Validator (Static API)

    func test_validator_isEmail_true() {
        XCTAssertTrue(Validator.isEmail("test@example.com"))
    }

    func test_validator_isEmail_false() {
        XCTAssertFalse(Validator.isEmail("notanemail"))
    }

    func test_validator_isNotEmpty_false() {
        XCTAssertFalse(Validator.isNotEmpty(""))
    }

    func test_validator_isStrongPassword() {
        XCTAssertTrue(Validator.isStrongPassword("MyPass1!"))
        XCTAssertFalse(Validator.isStrongPassword("weak"))
    }

    func test_validator_multipleRules() {
        let result = Validator.validate("ab", rules: [
            RequiredRule(),
            MinLengthRule(5)
        ])
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Must be at least 5 characters.")
    }

    // MARK: - ValidationResult Helpers

    func test_result_isValid_true() {
        XCTAssertTrue(ValidationResult.valid.isValid)
    }

    func test_result_isValid_false() {
        XCTAssertFalse(ValidationResult.invalid(message: "Error").isValid)
    }

    func test_result_errorMessage_nil_whenValid() {
        XCTAssertNil(ValidationResult.valid.errorMessage)
    }

    func test_result_errorMessage_notNil_whenInvalid() {
        XCTAssertEqual(
            ValidationResult.invalid(message: "Error").errorMessage,
            "Error"
        )
    }
}
