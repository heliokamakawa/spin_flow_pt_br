import 'package:flutter/material.dart';

abstract final class ConfiguracaoAbas {
  static const tema = TabBarThemeData(
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white70,
    indicatorColor: Colors.white,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      height: 1.15,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.15,
    ),
  );

  static Tab texto(String rotulo) => Tab(text: rotulo);
}
