import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:katrin_calculator/theme/calculator_theme.dart';
import 'package:katrin_calculator/widgets/calculator_button.dart';
import 'package:katrin_calculator/widgets/markdown_view.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: calculatorTheme,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Gradient mainGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color.fromRGBO(164, 48, 255, 1),
        Color.fromRGBO(243, 24, 173, 1),
        Color.fromRGBO(255, 33, 113, 1)
      ]);

  String lastExpression = "";
  String expression = "";

  String operation = "";

  void clearAll() {
    setState(() {
      lastExpression = "";
      expression = "";
      operation = "";
    });
  }

  void calculateExpression() {
    setState(() {
      try {
        if (expression.contains("π")) {
          expression = expression.replaceAll("π", math.pi.toString());
        }
        if (expression.contains("%")) {
          final tmpArray = expression.split(operation);
          final List<String> nArray = [];
          tmpArray.map((e) {
            if (e.contains("%")) {
              double tmpPerc = double.parse(e.substring(0, e.length - 1)) / 100;
              if ((operation == "-") || (operation == "+")) {
                final anotherElement = double.parse(
                    tmpArray.firstWhere((element) => element != e));
                tmpPerc = anotherElement * tmpPerc;
              }
              nArray.add(tmpPerc.toString());
            } else {
              nArray.add(e);
            }
          }).toList();
          expression = nArray[0] + operation + nArray[1];
        }
        Parser p = Parser();
        Expression exp = p.parse(expression);

        ContextModel cm = ContextModel();
        final result = exp.evaluate(EvaluationType.REAL, cm).toString();
        lastExpression = expression;
        expression = result;
        operation = "";
      } catch (e) {
        operation = "";
        expression = "Ошибка";
      }
    });
  }

  void addToExpression(String symbol) {
    setState(() {
      if (!(operation.isNotEmpty &&
          (symbol == "*" || symbol == "/" || symbol == "+" || symbol == "-"))) {
        if (symbol == "*" || symbol == "/" || symbol == "+" || symbol == "-") {
          operation = symbol;
        }
        expression += symbol;
      }
    });
  }

  void removeFromExpression() {
    setState(() {
      if (expression.endsWith("ln(")) {
        expression = expression.substring(0, expression.length - 3);
      } else if (expression.contains("Ошибка")) {
        expression = "";
      } else if (expression.isNotEmpty) {
        if (expression.endsWith("-") ||
            expression.endsWith("/") ||
            expression.endsWith("*") ||
            expression.endsWith("+")) {
          operation = "";
        }
        expression = expression.substring(0, expression.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = MediaQuery.of(context).size.width * 0.22;
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.25,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (lastExpression.isNotEmpty)
                  FittedBox(
                    child: Text(
                      lastExpression,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.5)),
                    ),
                  ),
                if (expression.isNotEmpty)
                  FittedBox(
                    child: Text(
                      expression,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(gradient: mainGradient),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.010,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            CupertinoPageRoute(builder: (BuildContext context) {
                          return const MarkdownView();
                        }));
                      },
                      icon: Icon(Icons.info_outline_rounded)),
                  IconButton(
                      onPressed: () {
                        removeFromExpression();
                      },
                      icon: Icon(
                        Icons.backspace_outlined,
                        size: 40,
                      )),
                ],
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CalculatorButton(
                            label: "C",
                            size: buttonSize,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            onTap: () {
                              clearAll();
                            }),
                        CalculatorButton(
                            label: "ln(x)",
                            size: buttonSize,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            onTap: () {
                              addToExpression("ln(");
                            }),
                        CalculatorButton(
                            label: "%",
                            size: buttonSize,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            onTap: () {
                              addToExpression("%");
                            }),
                        CalculatorButton(
                            label: "/",
                            size: buttonSize,
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            onTap: () {
                              addToExpression("/");
                            }),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CalculatorButton(
                            label: "7",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("7");
                            }),
                        CalculatorButton(
                            label: "8",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("8");
                            }),
                        CalculatorButton(
                            label: "9",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("9");
                            }),
                        CalculatorButton(
                            label: "x",
                            size: buttonSize,
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            onTap: () {
                              addToExpression("*");
                            }),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CalculatorButton(
                            label: "4",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("4");
                            }),
                        CalculatorButton(
                            label: "5",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("5");
                            }),
                        CalculatorButton(
                            label: "6",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("6");
                            }),
                        CalculatorButton(
                            label: "-",
                            size: buttonSize,
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            onTap: () {
                              addToExpression("-");
                            }),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CalculatorButton(
                            label: "1",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("1");
                            }),
                        CalculatorButton(
                            label: "2",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("2");
                            }),
                        CalculatorButton(
                            label: "3",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("3");
                            }),
                        CalculatorButton(
                            label: "+",
                            size: buttonSize,
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            onTap: () {
                              addToExpression("+");
                            }),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CalculatorButton(
                            label: "0",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("0");
                            }),
                        CalculatorButton(
                            label: "00",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("00");
                            }),
                        CalculatorButton(
                            label: "000",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("000");
                            }),
                        CalculatorButton(
                            label: ".",
                            size: buttonSize,
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            onTap: () {
                              addToExpression(".");
                            }),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CalculatorButton(
                            label: "π",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("π");
                            }),
                        CalculatorButton(
                            label: "(",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression("(");
                            }),
                        CalculatorButton(
                            label: ")",
                            size: buttonSize,
                            color: Theme.of(context).colorScheme.background,
                            onTap: () {
                              addToExpression(")");
                            }),
                        CalculatorButton(
                            label: "=",
                            gradient: mainGradient,
                            size: buttonSize,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            onTap: () {
                              calculateExpression();
                            }),
                      ],
                    ))
                  ],
                ),
              ))
            ],
          ),
        )
      ],
    ));
  }
}
