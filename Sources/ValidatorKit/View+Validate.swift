#if canImport(SwiftUI)
import SwiftUI

// MARK: - ValidatedField

/// A SwiftUI view that wraps a `TextField` with live inline validation.
///
/// Validation runs on every keystroke (debounced) and shows an error
/// message below the field when the value is invalid.
///
/// ```swift
/// @State private var email = ""
///
/// ValidatedField("Email", text: $email, chain: ValidationChain().required().email())
/// ```
public struct ValidatedField: View {

    // MARK: - Properties

    private let title: String
    @Binding private var text: String
    private let chain: ValidationChain
    private let errorColor: Color
    private let isSecure: Bool

    @State private var result: ValidationResult = .valid
    @State private var isDirty = false

    // MARK: - Init

    /// Creates a validated text field.
    ///
    /// - Parameters:
    ///   - title: The placeholder text shown when the field is empty.
    ///   - text: A binding to the field's value.
    ///   - chain: The ``ValidationChain`` to run against the value.
    ///   - errorColor: Color used for the error message and border. Defaults to `.red`.
    public init(
        _ title: String,
        text: Binding<String>,
        chain: ValidationChain,
        errorColor: Color = .red
    ) {
        self.title = title
        self._text = text
        self.chain = chain
        self.errorColor = errorColor
        self.isSecure = false
    }

    /// Creates a validated **secure** text field (for passwords).
    public init(
        _ title: String,
        secureText: Binding<String>,
        chain: ValidationChain,
        errorColor: Color = .red
    ) {
        self.title = title
        self._text = secureText
        self.chain = chain
        self.errorColor = errorColor
        self.isSecure = true
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .onChange(of: text) { newValue in
                isDirty = true
                result = chain.validate(newValue)
            }

            if isDirty, case .invalid = result {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(errorColor)
                    .offset(y: -2)
            }

            if isDirty, let message = result.errorMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(errorColor)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: result.errorMessage)
    }
}

// MARK: - View Extension (Lightweight modifier approach)

public extension View {

    /// Reads a `ValidationResult` binding and applies a red border when invalid.
    ///
    /// Pair with ``ValidationChain/validate(_:)`` in an `onChange`:
    ///
    /// ```swift
    /// @State private var email = ""
    /// @State private var emailResult: ValidationResult = .valid
    ///
    /// TextField("Email", text: $email)
    ///     .validationBorder(emailResult)
    ///     .onChange(of: email) { _, new in
    ///         emailResult = ValidationChain().required().email().validate(new)
    ///     }
    /// ```
    func validationBorder(
        _ result: ValidationResult,
        color: Color = .red,
        radius: CGFloat = 8
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(
                    result.isValid ? Color.clear : color,
                    lineWidth: 1.5
                )
                .animation(.easeInOut(duration: 0.2), value: result.isValid)
        )
    }
}
#endif
