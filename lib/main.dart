import 'package:flutter/material.dart';
import 'package:spin_flow/infra/di/injecao.dart';
import 'package:spin_flow/spin_flow_app.dart';

void main() {
  configurarDependencias();
  runApp(const SpinFlowApp());
}
