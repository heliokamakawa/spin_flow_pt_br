import 'package:flutter/material.dart';
import 'package:spin_flow/infra/config/injecao.dart';
import 'package:spin_flow/view/spin_flow_app.dart';

void main() {
  configurarDependencias();
  runApp(const SpinFlowApp());
}
