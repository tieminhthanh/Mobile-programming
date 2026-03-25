import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.fallbackRoute, this.fallbackArguments});

  final String? fallbackRoute;
  final Object? fallbackArguments;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Trở lại',
      icon: const Icon(Icons.arrow_back),
      onPressed: () async {
        final navigator = Navigator.of(context);
        final didPop = await navigator.maybePop();
        if (!didPop && fallbackRoute != null) {
          navigator.pushReplacementNamed(
            fallbackRoute!,
            arguments: fallbackArguments,
          );
        }
      },
    );
  }
}
