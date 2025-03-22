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
    return Column(
      children: [
        _buildButtonRow(context, ["C", "÷", "×", "⌫"], Colors.orange),
        _buildButtonRow(context, ["7", "8", "9", "-"], Colors.grey[800]!),
        _buildButtonRow(context, ["4", "5", "6", "+"], Colors.grey[800]!),
        _buildButtonRow(context, ["1", "2", "3", "="], Colors.blue),
        _buildButtonRow(context, ["0", ".", "(", ")"], Colors.blue),
      ],
    );
  }

  Widget _buildScientificButtons(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildButtonRow(context, ["sin(", "cos(", "tan(", "log("], Colors.purple),
          _buildButtonRow(context, ["√(", "^", "e", "π"], Colors.purple),
          _buildButtonRow(context, ["7", "8", "9", "÷"], Colors.grey[800]!),
          _buildButtonRow(context, ["4", "5", "6", "×"], Colors.grey[800]!),
          _buildButtonRow(context, ["1", "2", "3", "-"], Colors.grey[800]!),
          _buildButtonRow(context, ["0", ".", "=", "C"], Colors.blue),
          _buildButtonRow(context, ["(", ")"], Colors.grey[700]!),
        ],
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context, List<String> buttons, Color color) {
    final calculator = Provider.of<CalculatorLogic>(context, listen: false);
    return Row(
      children: buttons.map((text) {
        return CalculatorButton(
          text: text,
          color: text == "=" ? Colors.orange : color,
          onPressed: () {
            calculator.addCharacter(text);
          },
        );
      }).toList(),
    );
  }
}