import 'package:flutter/material.dart';

import '../config/campos.dart';
import '../config/strings.dart';
import '../config/tema.dart';
import '../widgets/conteudo.dart';
import 'aula09_formulario.dart';

// Aula 10: List<Map<String, Object>> em memoria. Cadastrar, editar e excluir
// (com confirmacao). Os registros somem ao reiniciar o aplicativo.
class TelaLista extends StatefulWidget {
  const TelaLista({super.key});

  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista> {
  final List<Map<String, Object>> sessoes = <Map<String, Object>>[];
  int proximoId = 1;

  Widget _paginaCadastro(BuildContext context) {
    return const TelaFormulario();
  }

  Future<Map<String, Object>?> _abrirFormulario(
    WidgetBuilder pagina,
  ) {
    final navegador = Navigator.of(context);
    final rota = MaterialPageRoute<Map<String, Object>>(builder: pagina);
    return navegador.push(rota);
  }

  void _avisar(String mensagem) {
    final mensageiro = ScaffoldMessenger.of(context);
    mensageiro.hideCurrentSnackBar();
    mensageiro.showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _cadastrar() async {
    final resultado = await _abrirFormulario(_paginaCadastro);
    if (!mounted || resultado == null) {
      return;
    }
    final novo = <String, Object>{Campos.id: proximoId, ...resultado};
    setState(() {
      sessoes.add(novo);
      proximoId++;
    });
    _avisar(Textos.sessaoCadastrada);
  }

  Future<void> _editar(Map<String, Object> sessao) async {
    final id = sessao[Campos.id] as int;
    Widget paginaEdicao(BuildContext context) {
      return TelaFormulario(inicial: sessao);
    }

    final resultado = await _abrirFormulario(paginaEdicao);
    if (!mounted || resultado == null) {
      return;
    }
    final index = sessoes.indexWhere((item) => item[Campos.id] == id);
    if (index == -1) {
      return;
    }
    setState(() {
      sessoes[index] = <String, Object>{Campos.id: id, ...resultado};
    });
    _avisar(Textos.sessaoAtualizada);
  }

  Future<void> _excluir(Map<String, Object> sessao) async {
    final id = sessao[Campos.id] as int;
    Widget dialogo(BuildContext context) {
      return _ConfirmarExclusao(nome: sessao[Campos.tema] as String);
    }

    final confirmou = await showDialog<bool>(context: context, builder: dialogo);
    if (!mounted || confirmou != true) {
      return;
    }
    setState(() {
      sessoes.removeWhere((item) => item[Campos.id] == id);
    });
    _avisar(Textos.sessaoRemovida);
  }

  Widget _construirCartao(BuildContext context, int index) {
    final sessao = sessoes[index];
    return _CartaoSessao(
      sessao: sessao,
      aoEditar: _editar,
      aoExcluir: _excluir,
    );
  }

  Widget _construirVazio(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tema.espaco * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: cores.outline),
            const SizedBox(height: Tema.espaco),
            Text(
              Textos.vazioTitulo,
              key: const Key('listaVazia'),
              style: texto.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              Textos.vazioTexto,
              textAlign: TextAlign.center,
              style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: Tema.espaco),
            FilledButton.icon(
              key: const Key('cadastrarVazio'),
              onPressed: _cadastrar,
              icon: const Icon(Icons.add),
              label: const Text(Textos.cadastrarSessao),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLista(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Tema.espaco,
            Tema.espaco,
            Tema.espaco,
            8,
          ),
          child: Text(
            Textos.contagemLista(sessoes.length),
            key: const Key('contagem'),
            style: texto.titleSmall,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              Tema.espaco,
              0,
              Tema.espaco,
              96,
            ),
            itemCount: sessoes.length,
            itemBuilder: _construirCartao,
            separatorBuilder: _construirSeparador,
          ),
        ),
      ],
    );
  }

  Widget _construirSeparador(BuildContext context, int index) {
    return const SizedBox(height: 12);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Textos.tituloLista)),
      floatingActionButton: sessoes.isEmpty
          ? null
          : FloatingActionButton.extended(
              key: const Key('cadastrar'),
              onPressed: _cadastrar,
              icon: const Icon(Icons.add),
              label: const Text(Textos.cadastrarSessao),
            ),
      body: Conteudo(
        child: sessoes.isEmpty
            ? _construirVazio(context)
            : _construirLista(context),
      ),
    );
  }
}

class _CartaoSessao extends StatelessWidget {
  final Map<String, Object> sessao;
  final void Function(Map<String, Object> sessao) aoEditar;
  final void Function(Map<String, Object> sessao) aoExcluir;

  const _CartaoSessao({
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
                  key: Key('editar_$id'),
                  onPressed: _editar,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(Textos.editar),
                ),
                TextButton.icon(
                  key: Key('excluir_$id'),
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
          key: const Key('cancelarExclusao'),
          onPressed: () => _cancelar(context),
          child: const Text(Textos.cancelar),
        ),
        FilledButton(
          key: const Key('confirmarExclusao'),
          onPressed: () => _confirmar(context),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          child: const Text(Textos.excluir),
        ),
      ],
    );
  }
}
