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
    validate: (v) => RegExp(r'^[0-9]*$').hasMatch(v),
  );

  static InputValidation maxLength(int max) => InputValidation(
    errorMessage: 'Input has exceeded max length of $max',
    validate: (v) => v.length <= max,
  );

  static InputValidation minLength(int min, String msg) => InputValidation(
    errorMessage: "Input is shorter than min length of $min",
    validate: (v) => v.length >= min,
  );

  static InputValidation minValue(num min) => InputValidation(
    errorMessage: 'Input is less than the minimum value of $min',
    validate: (v) {
      if (v.isEmpty) return false;
      final n = num.tryParse(v);
      return n != null && n >= min;
    },
  );

  static InputValidation maxValue(num max) => InputValidation(
    errorMessage: 'Input is greater than the maximum value of $max',
    validate: (v) {
      if (v.isEmpty) return false;
      final n = num.tryParse(v);
      return n != null && n <= max;
    },
  );
}
