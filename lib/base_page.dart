import 'package:flutter/material.dart';

abstract class BasePage extends StatefulWidget {
  const BasePage({super.key, required this.title});
  final String title;
}
