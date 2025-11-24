class InputValidation {
  final String errorMessage;
  final bool Function(String value) validate;

  InputValidation({
    required this.errorMessage,
    required this.validate,
  });

  static InputValidation required(String msg) => InputValidation(
    errorMessage: msg,
    validate: (v) => v.trim().isNotEmpty,
  );

  static InputValidation onlyNumbers() => InputValidation(
    errorMessage: 'Input must be numbers',
    validate: (v) => RegExp(r'^[0-9,.]*$').hasMatch(v),
  );

  static InputValidation maxLength(int max) => InputValidation(
    errorMessage: 'Max length is $max',
    validate: (v) => v.length <= max,
  );

  static InputValidation minLength(int min, String msg) => InputValidation(
    errorMessage: "Min length is $min",
    validate: (v) => v.length >= min,
  );

  static InputValidation minValue(num min) => InputValidation(
    errorMessage: 'Minimum value $min',
    validate: (v) {
      if (v.isEmpty) return false;
      final cleaned = v.replaceAll(',', '');
      final n = num.tryParse(cleaned);
      return n != null && n >= min;
    },
  );

  static InputValidation maxValue(num max) => InputValidation(
    errorMessage: 'Maximum value $max',
    validate: (v) {
      if (v.isEmpty) return false;
      final cleaned = v.replaceAll(',', '');
      final n = num.tryParse(cleaned);
      return n != null && n <= max;
    },
  );
}
