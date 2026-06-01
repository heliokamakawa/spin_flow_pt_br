import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spin_flow/core/tema/cores_app.dart';

abstract final class TemaApp {
  static ThemeData get claro {
    const esquema = ColorScheme.light(
      brightness: Brightness.light,
      primary: CoresApp.primaria,
      onPrimary: Colors.white,
      primaryContainer: CoresApp.primariaSuave,
      onPrimaryContainer: CoresApp.primariaEscura,
      secondary: CoresApp.destaque,
      onSecondary: Colors.white,
      secondaryContainer: CoresApp.sucessoSuave,
      onSecondaryContainer: CoresApp.destaque,
      error: CoresApp.erro,
      onError: Colors.white,
      errorContainer: CoresApp.erroSuave,
      onErrorContainer: CoresApp.erro,
      surface: CoresApp.superficie,
      onSurface: CoresApp.textoPrincipal,
      surfaceContainerHighest: CoresApp.superficieSuave,
      outline: CoresApp.borda,
      outlineVariant: CoresApp.bordaForte,
    );

    final textoBase = GoogleFonts.interTextTheme().apply(
      bodyColor: CoresApp.textoPrincipal,
      displayColor: CoresApp.textoPrincipal,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      primaryColor: CoresApp.primaria,
      scaffoldBackgroundColor: CoresApp.fundoTela,
      textTheme: textoBase,
      hintColor: CoresApp.textoFraco,
      dividerColor: CoresApp.borda,
      appBarTheme: const AppBarTheme(
        backgroundColor: CoresApp.barraApp,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: CoresApp.primaria,
        unselectedLabelColor: Colors.white70,
        indicatorColor: CoresApp.primaria,
        dividerColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: CoresApp.superficieElevada,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CoresApp.borda),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CoresApp.superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.borda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.primaria, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.erro),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.erro, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CoresApp.primariaEscura,
          foregroundColor: Colors.white,
          disabledBackgroundColor: CoresApp.superficieSuave,
          disabledForegroundColor: CoresApp.textoSuave,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CoresApp.primariaForte,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CoresApp.primariaEscura,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CoresApp.erro,
        contentTextStyle: textoBase.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      extensions: const <ThemeExtension<dynamic>>[CoresSemanticasApp()],
    );
  }
}

class CoresSemanticasApp extends ThemeExtension<CoresSemanticasApp> {
  final Color primaria;
  final Color primariaForte;
  final Color sucesso;
  final Color sucessoSuave;
  final Color erro;
  final Color erroSuave;
  final Color alerta;
  final Color alertaSuave;
  final Color info;
  final Color infoSuave;
  final Color textoSuave;
  final Color textoFraco;
  final Color borda;
  final Color bikeLivre;
  final Color bikeOcupada;
  final Color bikeProfessora;
  final Color bikeManutencao;
  final Color bikeMinhaReserva;

  const CoresSemanticasApp({
    this.primaria = CoresApp.primaria,
    this.primariaForte = CoresApp.primariaForte,
    this.sucesso = CoresApp.sucesso,
    this.sucessoSuave = CoresApp.sucessoSuave,
    this.erro = CoresApp.erro,
    this.erroSuave = CoresApp.erroSuave,
    this.alerta = CoresApp.alerta,
    this.alertaSuave = CoresApp.alertaSuave,
    this.info = CoresApp.info,
    this.infoSuave = CoresApp.infoSuave,
    this.textoSuave = CoresApp.textoSuave,
    this.textoFraco = CoresApp.textoFraco,
    this.borda = CoresApp.borda,
    this.bikeLivre = CoresApp.bikeLivre,
    this.bikeOcupada = CoresApp.bikeOcupada,
    this.bikeProfessora = CoresApp.bikeProfessora,
    this.bikeManutencao = CoresApp.bikeManutencao,
    this.bikeMinhaReserva = CoresApp.bikeMinhaReserva,
  });

  @override
  CoresSemanticasApp copyWith({
    Color? primaria,
    Color? primariaForte,
    Color? sucesso,
    Color? sucessoSuave,
    Color? erro,
    Color? erroSuave,
    Color? alerta,
    Color? alertaSuave,
    Color? info,
    Color? infoSuave,
    Color? textoSuave,
    Color? textoFraco,
    Color? borda,
    Color? bikeLivre,
    Color? bikeOcupada,
    Color? bikeProfessora,
    Color? bikeManutencao,
    Color? bikeMinhaReserva,
  }) {
    return CoresSemanticasApp(
      primaria: primaria ?? this.primaria,
      primariaForte: primariaForte ?? this.primariaForte,
      sucesso: sucesso ?? this.sucesso,
      sucessoSuave: sucessoSuave ?? this.sucessoSuave,
      erro: erro ?? this.erro,
      erroSuave: erroSuave ?? this.erroSuave,
      alerta: alerta ?? this.alerta,
      alertaSuave: alertaSuave ?? this.alertaSuave,
      info: info ?? this.info,
      infoSuave: infoSuave ?? this.infoSuave,
      textoSuave: textoSuave ?? this.textoSuave,
      textoFraco: textoFraco ?? this.textoFraco,
      borda: borda ?? this.borda,
      bikeLivre: bikeLivre ?? this.bikeLivre,
      bikeOcupada: bikeOcupada ?? this.bikeOcupada,
      bikeProfessora: bikeProfessora ?? this.bikeProfessora,
      bikeManutencao: bikeManutencao ?? this.bikeManutencao,
      bikeMinhaReserva: bikeMinhaReserva ?? this.bikeMinhaReserva,
    );
  }

  @override
  CoresSemanticasApp lerp(
    covariant ThemeExtension<CoresSemanticasApp>? other,
    double t,
  ) {
    if (other is! CoresSemanticasApp) return this;

    return CoresSemanticasApp(
      primaria: Color.lerp(primaria, other.primaria, t)!,
      primariaForte: Color.lerp(primariaForte, other.primariaForte, t)!,
      sucesso: Color.lerp(sucesso, other.sucesso, t)!,
      sucessoSuave: Color.lerp(sucessoSuave, other.sucessoSuave, t)!,
      erro: Color.lerp(erro, other.erro, t)!,
      erroSuave: Color.lerp(erroSuave, other.erroSuave, t)!,
      alerta: Color.lerp(alerta, other.alerta, t)!,
      alertaSuave: Color.lerp(alertaSuave, other.alertaSuave, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSuave: Color.lerp(infoSuave, other.infoSuave, t)!,
      textoSuave: Color.lerp(textoSuave, other.textoSuave, t)!,
      textoFraco: Color.lerp(textoFraco, other.textoFraco, t)!,
      borda: Color.lerp(borda, other.borda, t)!,
      bikeLivre: Color.lerp(bikeLivre, other.bikeLivre, t)!,
      bikeOcupada: Color.lerp(bikeOcupada, other.bikeOcupada, t)!,
      bikeProfessora: Color.lerp(bikeProfessora, other.bikeProfessora, t)!,
      bikeManutencao: Color.lerp(bikeManutencao, other.bikeManutencao, t)!,
      bikeMinhaReserva: Color.lerp(
        bikeMinhaReserva,
        other.bikeMinhaReserva,
        t,
      )!,
    );
  }
}
