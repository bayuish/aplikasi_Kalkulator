import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/calculator_logic.dart';
import '../widgets/calculator_button.dart';
import '../widgets/custom_bottom_navbar.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculator = Provider.of<CalculatorLogic>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Standar'),
              Tab(text: 'Ilmiah'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(calculator.expression,
                        style: const TextStyle(fontSize: 30, color: Colors.white54)),
                    const SizedBox(height: 10),
                    Text(calculator.result,
                        style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // Button Area
            Expanded(
              flex: 2,
              child: TabBarView(
                children: [
                  _buildStandardButtons(context),
                  _buildScientificButtons(context),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      ),
    );
  }

  Widget _buildStandardButtons(BuildContext context) {
    final calculator = Provider.of<CalculatorLogic>(context, listen: false);

    final rows = [
      ["C", "÷", "×", "⌫"],
      ["7", "8", "9", "-"],
      ["4", "5", "6", "+"],
      ["1", "2", "3", "="],
      ["0", ".", "(", ")"],
    ];

    return Column(
      children: rows.map((row) {
        return Expanded(
          child: Row(
            children: row.map((text) {
              Color bgColor;
              if (["C", "÷", "×", "⌫", "="].contains(text)) {
                bgColor = Colors.orange;
              } else if (["0", "1", "2", "3", ".", "(", ")"].contains(text)) {
                bgColor = Colors.blue;
              } else {
                bgColor = Colors.grey[800]!;
              }

              return Expanded(
                child: CalculatorButton(
                  text: text,
                  color: bgColor,
                  onPressed: () => calculator.addCharacter(text),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScientificButtons(BuildContext context) {
    final calculator = Provider.of<CalculatorLogic>(context, listen: false);

    final rows = [
      ["sin(", "cos(", "tan(", "log("],
      ["√(", "^", "e", "π"],
      ["7", "8", "9", "÷"],
      ["4", "5", "6", "×"],
      ["1", "2", "3", "-"],
      ["0", ".", "=", "C"],
      ["(", ")"],
    ];

    return Column(
      children: rows.map((row) {
        return Expanded(
          child: Row(
            children: row.map((text) {
              Color bgColor;
              if (["sin(", "cos(", "tan(", "log(", "√(", "^", "e", "π"].contains(text)) {
                bgColor = Colors.purple;
              } else if (["=", "C"].contains(text)) {
                bgColor = Colors.orange;
              } else if (["(", ")", ".", "0", "1", "2", "3"].contains(text)) {
                bgColor = Colors.blue;
              } else {
                bgColor = Colors.grey[800]!;
              }

              return Expanded(
                child: CalculatorButton(
                  text: text,
                  color: bgColor,
                  onPressed: () => calculator.addCharacter(text),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}