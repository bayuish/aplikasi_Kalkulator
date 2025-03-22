import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic extends ChangeNotifier {
  String _expression = "";
  String _result = "0";

  String get expression => _expression;
  String get result => _result;

  void addCharacter(String char) {
    if (char == "C") {
      _expression = "";
      _result = "0";
    } else if (char == "=") {
      _calculate();
    } else if (char == "⌫") {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    } else {
      _expression += char;
    }
    notifyListeners();
  }

  void _calculate() {
    try {
      String finalExp = _expression
          .replaceAll("×", "*")
          .replaceAll("÷", "/")
          .replaceAll("π", "3.14159265359")
          .replaceAll("√", "sqrt")
          .replaceAll("log", "log")
          .replaceAll("sin", "sin")
          .replaceAll("cos", "cos")
          .replaceAll("tan", "tan")
          .replaceAll("e", "2.71828182846");

      Parser p = Parser();
      Expression exp = p.parse(finalExp);
      ContextModel cm = ContextModel();
      _result = exp.evaluate(EvaluationType.REAL, cm).toString();
    } catch (e) {
      _result = "Error";
    }
    notifyListeners();
  }
}