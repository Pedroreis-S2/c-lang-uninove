import 'package:flutter/material.dart';

import '../config/campos.dart';
import '../config/strings.dart';
import '../config/tema.dart';
import '../dados/sessoes_dao.dart';
import '../widgets/conteudo.dart';
import 'aula09_formulario.dart';

// Aulas 11 e 12: as sessoes de estudo ficam gravadas no SQLite (sessoes.db).
// Cadastrar, consultar, editar e excluir passam pelo banco, entao os dados
// continuam la depois de fechar e reabrir o aplicativo.
class TelaSessoesSalvas extends StatefulWidget {
  const TelaSessoesSalvas({super.key});

  @override
  State<TelaSessoesSalvas> createState() => _TelaSessoesSalvasState();
}

class _TelaSessoesSalvasState extends State<TelaSessoesSalvas> {
  final SessoesDao _dao = SessoesDao();

  List<Map<String, Object?>> _sessoes = <Map<String, Object?>>[];
  bool _carregando = true;
  bool _erro = false;

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
      final sessoes = await _dao.listar();
      if (!mounted) {
        return;
      }
      setState(() {
        _sessoes = sessoes;
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

  void _avisar(String mensagem) {
    final mensageiro = ScaffoldMessenger.of(context);
    mensageiro.hideCurrentSnackBar();
    mensageiro.showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<Map<String, Object>?> _abrirFormulario(WidgetBuilder pagina) {
    final navegador = Navigator.of(context);
    final rota = MaterialPageRoute<Map<String, Object>>(builder: pagina);
    return navegador.push(rota);
  }

  Widget _paginaCadastro(BuildContext context) {
    return const TelaFormulario();
  }

  Future<void> _cadastrar() async {
    final resultado = await _abrirFormulario(_paginaCadastro);
    if (!mounted || resultado == null) {
      return;
    }
    await _dao.inserir(resultado);
    await _carregar();
    _avisar(Textos.sessaoCadastrada);
  }

  Future<void> _editar(Map<String, Object?> sessao) async {
    final id = sessao[Campos.id] as int;
    final inicial = <String, Object>{
      Campos.tema: sessao[Campos.tema] as String,
      Campos.duracao: sessao[Campos.duracao] as int,
      Campos.observacao: sessao[Campos.observacao] as String,
    };
    Widget paginaEdicao(BuildContext context) {
      return TelaFormulario(inicial: inicial);
    }

    final resultado = await _abrirFormulario(paginaEdicao);
    if (!mounted || resultado == null) {
      return;
    }
    await _dao.atualizar(id, resultado);
    await _carregar();
    _avisar(Textos.sessaoAtualizada);
  }

  Future<void> _excluir(Map<String, Object?> sessao) async {
    final id = sessao[Campos.id] as int;
    Widget dialogo(BuildContext context) {
      return _ConfirmarExclusao(nome: sessao[Campos.tema] as String);
    }

    final confirmou = await showDialog<bool>(context: context, builder: dialogo);
    if (!mounted || confirmou != true) {
      return;
    }
    await _dao.excluir(id);
    await _carregar();
    _avisar(Textos.sessaoRemovida);
  }

  Widget _construirCartao(BuildContext context, int index) {
    final sessao = _sessoes[index];
    return _CartaoSessaoSalva(
      sessao: sessao,
      aoEditar: _editar,
      aoExcluir: _excluir,
    );
  }

  Widget _construirSeparador(BuildContext context, int index) {
    return const SizedBox(height: 12);
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(
        key: Key('carregandoSalvas'),
        child: CircularProgressIndicator(),
      );
    }
    if (_erro) {
      return _MensagemErro(aoTentar: _carregar);
    }
    if (_sessoes.isEmpty) {
      return _Vazio(aoCadastrar: _cadastrar);
    }
    final texto = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Tema.espaco, Tema.espaco, Tema.espaco, 8),
          child: Text(
            Textos.contagemSalvas(_sessoes.length),
            key: const Key('contagemSalvas'),
            style: texto.titleSmall,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(Tema.espaco, 0, Tema.espaco, 96),
            itemCount: _sessoes.length,
            itemBuilder: _construirCartao,
            separatorBuilder: _construirSeparador,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final temSessoes = !_carregando && !_erro && _sessoes.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text(Textos.tituloSalvas)),
      floatingActionButton: temSessoes
          ? FloatingActionButton.extended(
              key: const Key('cadastrarSalva'),
              onPressed: _cadastrar,
              icon: const Icon(Icons.add),
              label: const Text(Textos.cadastrarSessao),
            )
          : null,
      body: Conteudo(child: _corpo()),
    );
  }
}

class _Vazio extends StatelessWidget {
  final Future<void> Function() aoCadastrar;

  const _Vazio({required this.aoCadastrar});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tema.espaco * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.save_outlined, size: 64, color: cores.outline),
            const SizedBox(height: Tema.espaco),
            Text(
              Textos.salvasVazioTitulo,
              key: const Key('salvasVazia'),
              style: texto.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              Textos.salvasVazioTexto,
              textAlign: TextAlign.center,
              style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: Tema.espaco),
            FilledButton.icon(
              key: const Key('cadastrarSalvaVazio'),
              onPressed: aoCadastrar,
              icon: const Icon(Icons.add),
              label: const Text(Textos.cadastrarSessao),
            ),
          ],
        ),
      ),
    );
  }
}

class _MensagemErro extends StatelessWidget {
  final Future<void> Function() aoTentar;

  const _MensagemErro({required this.aoTentar});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tema.espaco * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: cores.error),
            const SizedBox(height: Tema.espaco),
            Text(Textos.erroBanco, style: texto.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: Tema.espaco),
            FilledButton.icon(
              onPressed: aoTentar,
              icon: const Icon(Icons.refresh),
              label: const Text(Textos.tentarNovamente),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoSessaoSalva extends StatelessWidget {
  final Map<String, Object?> sessao;
  final void Function(Map<String, Object?> sessao) aoEditar;
  final void Function(Map<String, Object?> sessao) aoExcluir;

  const _CartaoSessaoSalva({
    required this.sessao,
    required this.aoEditar,
    required this.aoExcluir,
  });

  void _editar() {
    aoEditar(sessao);
  }

  void _excluir() {
    aoExcluir(sessao);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    final id = sessao[Campos.id] as int;
    final observacao = sessao[Campos.observacao] as String;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Tema.espaco),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: cores.primaryContainer,
                  foregroundColor: cores.onPrimaryContainer,
                  child: Text('$id'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sessao[Campos.tema] as String,
                    style: texto.titleMedium,
                  ),
                ),
                Text(
                  Textos.duracao(sessao[Campos.duracao] as int),
                  style: texto.titleMedium?.copyWith(color: cores.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              observacao.isEmpty ? Textos.semObservacao : observacao,
              style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  key: Key('editarSalva_$id'),
                  onPressed: _editar,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(Textos.editar),
                ),
                TextButton.icon(
                  key: Key('excluirSalva_$id'),
                  onPressed: _excluir,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(Textos.excluir),
                  style: TextButton.styleFrom(foregroundColor: cores.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmarExclusao extends StatelessWidget {
  final String nome;

  const _ConfirmarExclusao({required this.nome});

  void _cancelar(BuildContext context) {
    Navigator.of(context).pop(false);
  }

  void _confirmar(BuildContext context) {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(Textos.tituloExcluir),
      content: Text(Textos.textoExcluir(nome)),
      actions: [
        TextButton(
          onPressed: () => _cancelar(context),
          child: const Text(Textos.cancelar),
        ),
        FilledButton(
          onPressed: () => _confirmar(context),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          child: const Text(Textos.excluir),
        ),
      ],
    );
  }
}
