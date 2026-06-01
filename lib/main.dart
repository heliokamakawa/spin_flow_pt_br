import 'package:flutter/material.dart';
import 'package:spin_flow/core/di/injecao.dart';
import 'package:spin_flow/excluir/spim_flow_app.dart';

void main() {
  configurarDependencias();
  runApp(const SpinFlowApp());
}
