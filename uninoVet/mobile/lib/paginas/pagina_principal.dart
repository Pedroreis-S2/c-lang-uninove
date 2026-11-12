import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';
import '../modelos/agendamento.dart';
import '../modelos/opcoes.dart';
import '../servicos/api.dart';
import '../servicos/sessao.dart';
import '../widgets/aviso.dart';
import '../widgets/barra_app.dart';
import 'pagina_agendamentos.dart';
import 'pagina_inicio.dart';
import 'pagina_pets.dart';
import 'pagina_solicitar.dart';

// Casca do app: carrega os agendamentos uma vez e escolhe o menu pela largura.
// Tela larga (web) usa menu lateral; tela estreita (celular) usa menu de baixo.
class PaginaPrincipal extends StatefulWidget {
  final ValueNotifier<ThemeMode> modoTema;

  // Sair da conta. Fica nulo quando o app nao exige login.
  final VoidCallback? aoSair;

  const PaginaPrincipal({super.key, required this.modoTema, this.aoSair});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  final Api _api = Api();

  List<Agendamento> _agendamentos = <Agendamento>[];
  List<Pet> _pets = <Pet>[];
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
      final pets = await _buscarPetsDoTutor();
      if (!mounted) {
        return;
      }
      setState(() {
        _agendamentos = lista;
        _pets = pets;
        _carregando = false;
      });
    } on ErroApi catch (erro) {
      if (!mounted) {
        return;
      }
      // Sessao expirada: volta para o login.
      final sair = widget.aoSair;
      if (erro.status == 401 && sair != null) {
        sair();
        return;
      }
      setState(() {
        _erro = true;
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

  // So o tutor tem pets proprios; falhar aqui nao derruba o resto da tela.
  Future<List<Pet>> _buscarPetsDoTutor() async {
    if (!Sessao.isCliente) {
      return <Pet>[];
    }
    try {
      return await _api.buscarPets();
    } catch (e) {
      return <Pet>[];
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _solicitar() async {
    final enviou = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (contexto) => PaginaSolicitar(pets: _pets)),
    );
    if (enviou == true) {
      _mostrarMensagem(Textos.pedidoEnviado);
      await _carregar();
    }
  }

  Future<void> _cancelar(Agendamento agendamento) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text(Textos.confirmarCancelar),
        content: Text('${agendamento.animal} · ${agendamento.dataFormatada}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text(Textos.naoCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text(Textos.cancelarConsulta),
          ),
        ],
      ),
    );
    if (confirmou != true) {
      return;
    }
    try {
      await _api.cancelar(agendamento.id);
      if (!mounted) {
        return;
      }
      _mostrarMensagem(Textos.consultaCancelada);
      await _carregar();
    } on ErroApi catch (erro) {
      if (!mounted) {
        return;
      }
      _mostrarMensagem(erro.mensagem);
      await _carregar();
    } catch (e) {
      if (!mounted) {
        return;
      }
      _mostrarMensagem(Textos.semConexao);
    }
  }

  Future<void> _novoPet() async {
    final nome = TextEditingController();
    final especie = TextEditingController();
    final raca = TextEditingController();
    final salvar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text(Textos.novoPet),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nome, decoration: const InputDecoration(labelText: Textos.rotuloNomePet)),
            TextField(controller: especie, decoration: const InputDecoration(labelText: Textos.rotuloEspeciePet)),
            TextField(controller: raca, decoration: const InputDecoration(labelText: Textos.rotuloRacaPet)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text(Textos.naoCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text(Textos.salvar),
          ),
        ],
      ),
    );
    final nomeDigitado = nome.text.trim();
    final especieDigitada = especie.text.trim();
    final racaDigitada = raca.text.trim();
    nome.dispose();
    especie.dispose();
    raca.dispose();
    if (salvar != true) {
      return;
    }
    try {
      await _api.cadastrarPet(nome: nomeDigitado, especie: especieDigitada, raca: racaDigitada);
      if (!mounted) {
        return;
      }
      _mostrarMensagem(Textos.petCadastrado);
      await _carregar();
    } on ErroApi catch (erro) {
      if (!mounted) {
        return;
      }
      _mostrarMensagem(erro.mensagem);
    } catch (e) {
      if (!mounted) {
        return;
      }
      _mostrarMensagem(Textos.semConexao);
    }
  }

  // Botao de acao do tutor: solicitar (Inicio e Agenda) ou cadastrar pet (Pets).
  Widget? _botaoFlutuante() {
    if (!Sessao.isCliente || _carregando || _erro) {
      return null;
    }
    if (_aba == 2) {
      return FloatingActionButton.extended(
        onPressed: _novoPet,
        icon: const Icon(Icons.add),
        label: const Text(Textos.novoPet),
      );
    }
    return FloatingActionButton.extended(
      onPressed: _solicitar,
      icon: const Icon(Icons.add),
      label: const Text(Textos.solicitarBotao),
    );
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
      PaginaAgendamentos(
        agendamentos: _agendamentos,
        larga: larga,
        aoCancelar: Sessao.isCliente ? _cancelar : null,
      ),
      PaginaPets(agendamentos: _agendamentos, petsCadastrados: _pets),
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
      floatingActionButton: _botaoFlutuante(),
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
      aoSair: widget.aoSair,
    );
  }

  Widget _montarLarga() {
    return Scaffold(
      floatingActionButton: _botaoFlutuante(),
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
