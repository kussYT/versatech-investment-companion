import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatech_investment_companion/app/app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VersaTechApp(),
    ),
  );
}
