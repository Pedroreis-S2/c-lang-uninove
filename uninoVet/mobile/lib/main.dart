import 'package:flutter/material.dart';

import 'config/tema.dart';
import 'config/textos.dart';
import 'paginas/pagina_login.dart';
import 'paginas/pagina_principal.dart';
import 'servicos/api.dart';
import 'servicos/sessao.dart';

void main() {
  runApp(const UninoVetApp(exigirLogin: true));
}

class UninoVetApp extends StatefulWidget {
  // No app de verdade o login e obrigatorio. Sem ele (padrao) o app abre direto
  // na tela principal, como antes.
  final bool exigirLogin;

  const UninoVetApp({super.key, this.exigirLogin = false});

  @override
  State<UninoVetApp> createState() => _UninoVetAppState();
}

class _UninoVetAppState extends State<UninoVetApp> {
  // Comeca seguindo o tema do aparelho; o menu lateral permite trocar.
  final ValueNotifier<ThemeMode> _modoTema = ValueNotifier<ThemeMode>(ThemeMode.system);

  @override
  void dispose() {
    _modoTema.dispose();
    super.dispose();
  }

  // Chamado depois de entrar ou sair: reconstroi escolhendo login ou principal.
  void _atualizarTela() {
    setState(() {});
  }

  Future<void> _sair() async {
    await Api().sair();
    if (!mounted) {
      return;
    }
    _atualizarTela();
  }

  Widget _paginaInicial() {
    if (widget.exigirLogin && !Sessao.isLogado) {
      return PaginaLogin(aoEntrar: _atualizarTela);
    }
    if (widget.exigirLogin) {
      return PaginaPrincipal(modoTema: _modoTema, aoSair: _sair);
    }
    return PaginaPrincipal(modoTema: _modoTema);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _modoTema,
      builder: (context, modo, filho) {
        return MaterialApp(
          title: Textos.nomeClinica,
          debugShowCheckedModeBanner: false,
          theme: Tema.claro(),
          darkTheme: Tema.escuro(),
          themeMode: modo,
          home: _paginaInicial(),
        );
      },
    );
  }
}
