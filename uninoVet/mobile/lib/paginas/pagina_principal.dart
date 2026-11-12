import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';
import '../modelos/agendamento.dart';
import '../servicos/api.dart';
import '../widgets/aviso.dart';
import '../widgets/barra_app.dart';
import 'pagina_agendamentos.dart';
import 'pagina_inicio.dart';
import 'pagina_pets.dart';

// Casca do app: carrega os agendamentos uma vez e escolhe o menu pela largura.
// Tela larga (web) usa menu lateral; tela estreita (celular) usa menu de baixo.
class PaginaPrincipal extends StatefulWidget {
  final ValueNotifier<ThemeMode> modoTema;

  const PaginaPrincipal({super.key, required this.modoTema});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  final Api _api = Api();

  List<Agendamento> _agendamentos = <Agendamento>[];
  bool _carregando = true;
  bool _erro = false;
  int _aba = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });
    try {
      final lista = await _api.buscarAgendamentos();
      if (!mounted) {
        return;
      }
      setState(() {
        _agendamentos = lista;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erro = true;
        _carregando = false;
      });
    }
  }

  void _mudarAba(int aba) {
    setState(() {
      _aba = aba;
    });
  }

  void _alternarTema() {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    if (escuro) {
      widget.modoTema.value = ThemeMode.light;
      return;
    }
    widget.modoTema.value = ThemeMode.dark;
  }

  // Sem isso o AnimatedSwitcher centraliza a pagina em vez de esticar.
  Widget _ocuparTudo(Widget? atual, List<Widget> anteriores) {
    final camadas = <Widget>[...anteriores];
    if (atual != null) {
      camadas.add(atual);
    }
    return Stack(fit: StackFit.expand, children: camadas);
  }

  Widget _conteudo(bool larga) {
    if (_carregando) {
      return const Aviso(
        icone: Icons.pets,
        titulo: Textos.carregando,
        mostrarProgresso: true,
      );
    }
    if (_erro) {
      return Aviso(
        icone: Icons.wifi_off,
        titulo: Textos.erroTitulo,
        texto: Textos.erroTexto,
        aoTentar: _carregar,
      );
    }
    final paginas = <Widget>[
      PaginaInicio(agendamentos: _agendamentos, larga: larga),
      PaginaAgendamentos(agendamentos: _agendamentos, larga: larga),
      PaginaPets(agendamentos: _agendamentos),
    ];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      layoutBuilder: _ocuparTudo,
      child: KeyedSubtree(key: ValueKey<int>(_aba), child: paginas[_aba]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final larga = MediaQuery.of(context).size.width >= Tema.larguraTela;
    if (larga) {
      return _montarLarga();
    }
    return _montarEstreita();
  }

  Widget _montarEstreita() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _barra(),
            Expanded(child: _conteudo(false)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: _mudarAba,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Textos.menuInicio,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: Textos.menuAgenda,
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: Textos.menuPets,
          ),
        ],
      ),
    );
  }

  Widget _barra() {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return BarraApp(
      escuro: escuro,
      aoAtualizar: _carregar,
      aoAlternarTema: _alternarTema,
    );
  }

  Widget _montarLarga() {
    return Scaffold(
      body: Column(
        children: [
          _barra(),
          Expanded(child: _corpoLargo()),
        ],
      ),
    );
  }

  Widget _corpoLargo() {
    return Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: _aba,
            onDestinationSelected: _mudarAba,
            leading: const SizedBox(height: 12),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text(Textos.menuInicio),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: Text(Textos.menuAgenda),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pets_outlined),
                selectedIcon: Icon(Icons.pets),
                label: Text(Textos.menuPets),
              ),
            ],
          ),
          Expanded(child: _conteudo(true)),
        ],
    );
  }
}
