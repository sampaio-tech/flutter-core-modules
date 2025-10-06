import 'dart:math';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({
    this.enableNegative = true,
    this.minValue,
    this.maxValue,
    this.onChange,
    this.locale,
  });

  final String? locale;

  /// Defaults `enableNegative` is true.
  ///
  /// Set to false if you want to disable negative numbers.
  final bool enableNegative;

  /// Defaults `minValue` is null.
  final num? minValue;

  /// Defaults `maxValue` is null.
  final num? maxValue;

  /// Callback when value is changed.
  /// You can use this to listen to value changes.
  /// e.g. onChange: (value) => print(value);
  final void Function(String)? onChange;

  int _decimalDigits = 0;
  bool _containsDecimalSeparator = false;
  num _newNum = 0;
  String _newString = '';
  bool _isNegative = false;

  void _formatter(String newText) {
    final format = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: _decimalDigits,
    );
    _newNum = _parseStrToNum(newText);
    _newString = format.format(_newNum).trim();
    if (_isNegative) {
      _newString = '-$_newString';
    }
    if (_containsDecimalSeparator && _decimalDigits == 0) {
      final decimalSeparator = format.symbols.DECIMAL_SEP;
      _newString = '$_newString$decimalSeparator';
    }
  }

  num _parseStrToNum(String text) {
    num value = num.tryParse(text) ?? 0;
    if (_decimalDigits > 0) {
      value /= pow(10, _decimalDigits);
    }
    return value;
  }

  bool _isLessThanMinValue(num value) {
    if (minValue == null) {
      return false;
    }
    return value < minValue!;
  }

  bool _isMoreThanMaxValue(num value) {
    if (maxValue == null) {
      return false;
    }
    return value > maxValue!;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final format = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    );
    final decimalSeparator = format.symbols.DECIMAL_SEP;

    // Prevent any space characters from being inserted
    if (newValue.text.contains(' ')) {
      return oldValue;
    }

    // final bool isInsertedCharacter =
    //     oldValue.text.length + 1 == newValue.text.length &&
    //         newValue.text.startsWith(oldValue.text);
    final bool isRemovedCharacter =
        oldValue.text.length - 1 == newValue.text.length &&
        oldValue.text.startsWith(newValue.text);

    // Apparently, Flutter has a bug where the framework calls
    // formatEditUpdate twice, or even four times, after a backspace press (see
    // https://github.com/gtgalone/currency_text_input_formatter/issues/11).
    // However, only the first of these calls has inputs which are consistent
    // with a character insertion/removal at the end (which is the most common
    // use case of editing the TextField - the others being insertion/removal
    // in the middle, or pasting text onto the TextField). This condition
    // fixes a problem where a character wasn't properly erased after a
    // backspace press, when this Flutter bug was present. This comes at the
    // cost of losing insertion/removal in the middle and pasting text.
    // if (!isInsertedCharacter && !isRemovedCharacter) {
    //   return oldValue;
    // }

    if (enableNegative) {
      _isNegative = newValue.text.startsWith('-');
    } else {
      _isNegative = false;
    }

    _containsDecimalSeparator = newValue.text.contains(decimalSeparator);
    _decimalDigits = switch (newValue.text.split(decimalSeparator)) {
      final splittedNumber when splittedNumber.length > 1 =>
        splittedNumber.lastOrNull?.replaceAll(RegExp('[^0-9]'), '').length ?? 0,
      _ => 0,
    };

    String newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    // If the user wants to remove a digit, but the last character of the
    // formatted text is not a digit (for example, "1,00 €"), we need to remove
    // the digit manually.
    if (isRemovedCharacter &&
        !_lastCharacterIsDigit(text: oldValue.text, format: format)) {
      final int length = newText.length - 1;
      newText = newText.substring(0, length > 0 ? length : 0);
    }

    final num value = _parseStrToNum(newText);

    if (_isLessThanMinValue(value) || _isMoreThanMaxValue(value)) {
      return oldValue;
    }

    _formatter(newText);

    if (newText.trim() == '' || newText == '00' || newText == '000') {
      return TextEditingValue(
        text: _isNegative ? '-' : '',
        selection: TextSelection.collapsed(offset: _isNegative ? 1 : 0),
      );
    }

    onChange?.call(_newString);

    return TextEditingValue(
      text: _newString,
      selection: TextSelection.collapsed(offset: _newString.length),
    );
  }

  bool _lastCharacterIsDigit({
    required String text,
    required NumberFormat format,
  }) {
    final decimalSeparator = format.symbols.DECIMAL_SEP;
    final String lastChar = text.substring(text.length - 1);
    if (lastChar == decimalSeparator) {
      return true;
    }
    return RegExp('[0-9]').hasMatch(lastChar);
  }

  /// Get String type value with format such as `$ 2,000.00`
  String getFormattedValue() {
    return _newString;
  }

  /// Get num type value without format such as `2000.00`
  num getUnformattedValue() {
    return _isNegative ? (_newNum * -1) : _newNum;
  }

  /// Method for formatting value.
  /// You can use initialValue with this method.
  String formatString(String value) {
    if (enableNegative) {
      _isNegative = value.startsWith('-');
    } else {
      _isNegative = false;
    }

    final String newText = value.replaceAll(RegExp('[^0-9]'), '');
    _formatter(newText);
    return _newString;
  }

  /// Method for formatting value.
  /// You can use initialValue(double) with this method.
  String formatDouble(double value) {
    if (enableNegative) {
      _isNegative = value.isNegative;
    } else {
      _isNegative = false;
    }

    final String newText = value
        .toStringAsFixed(_decimalDigits)
        .replaceAll(RegExp('[^0-9]'), '');
    _formatter(newText);
    return _newString;
  }

  /// get double value
  double getDouble() {
    return getUnformattedValue().toDouble();
  }
}
