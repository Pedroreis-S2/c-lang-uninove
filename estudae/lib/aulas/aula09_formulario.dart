import 'package:flutter/material.dart';

import '../config/campos.dart';
import '../config/regras.dart';
import '../config/strings.dart';
import '../config/tema.dart';
import '../widgets/conteudo.dart';

// Aula 9: Form, validacao, controladores e retorno de dados.
// Confirmar devolve um Map (nome, preco, observacao); cancelar devolve null.

// Origem: abre o formulario e guarda somente o ultimo cadastro confirmado.
class TelaUltimaSessao extends StatefulWidget {
  const TelaUltimaSessao({super.key});

  @override
  State<TelaUltimaSessao> createState() => _TelaUltimaSessaoState();
}

class _TelaUltimaSessaoState extends State<TelaUltimaSessao> {
  Map<String, Object>? ultimo;

  Widget _paginaFormulario(BuildContext context) {
    return const TelaFormulario();
  }

  Future<void> _abrirFormulario() async {
    final navegador = Navigator.of(context);
    final rota = MaterialPageRoute<Map<String, Object>>(
      builder: _paginaFormulario,
    );
    final resultado = await navegador.push(rota);
    if (!mounted || resultado == null) {
      return;
    }
    setState(() {
      ultimo = resultado;
    });
  }

  Widget _construirUltimo(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final registro = ultimo;
    if (registro == null) {
      return const Text(Textos.nenhumaSessao, key: Key('semCadastro'));
    }
    final observacao = registro[Campos.observacao] as String;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(registro[Campos.tema] as String, style: texto.titleMedium),
        Text(Textos.duracao(registro[Campos.duracao] as int)),
        Text(observacao.isEmpty ? Textos.semObservacao : observacao),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Textos.tituloUltima)),
      body: Conteudo(
        child: ListView(
          padding: const EdgeInsets.all(Tema.espaco),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Tema.espaco),
                child: _construirUltimo(context),
              ),
            ),
            const SizedBox(height: Tema.espaco),
            FilledButton.icon(
              key: const Key('cadastrarSessao'),
              onPressed: _abrirFormulario,
              icon: const Icon(Icons.add),
              label: const Text(Textos.cadastrarSessao),
            ),
          ],
        ),
      ),
    );
  }
}

// Formulario reutilizado pela Aula 10 para cadastrar e para editar.
class TelaFormulario extends StatefulWidget {
  final Map<String, Object>? inicial;

  const TelaFormulario({super.key, this.inicial});

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {
  final GlobalKey<FormState> _chave = GlobalKey<FormState>();
  late final TextEditingController _tema;
  late final TextEditingController _duracao;
  late final TextEditingController _observacao;

  @override
  void initState() {
    super.initState();
    final inicial = widget.inicial;
    _tema = TextEditingController(text: inicial?[Campos.tema] as String? ?? '');
    _duracao = TextEditingController(
      text: inicial == null ? '' : '${inicial[Campos.duracao]}',
    );
    _observacao = TextEditingController(
      text: inicial?[Campos.observacao] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _tema.dispose();
    _duracao.dispose();
    _observacao.dispose();
    super.dispose();
  }

  String? _validarTema(String? valor) {
    final nome = (valor ?? '').trim();
    if (nome.isEmpty) {
      return Textos.erroTemaObrigatorio;
    }
    if (nome.length < Regras.temaMinimo) {
      return Textos.erroTemaCurto(Regras.temaMinimo);
    }
    return null;
  }

  String? _validarDuracao(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) {
      return Textos.erroDuracaoObrigatoria;
    }
    final numero = int.tryParse(texto);
    if (numero == null ||
        numero < Regras.duracaoMinima ||
        numero > Regras.duracaoMaxima) {
      return Textos.erroDuracaoInvalida(Regras.duracaoMinima, Regras.duracaoMaxima);
    }
    return null;
  }

  void _confirmar() {
    final estado = _chave.currentState;
    if (estado == null || !estado.validate()) {
      return;
    }
    final registro = <String, Object>{
      Campos.tema: _tema.text.trim(),
      Campos.duracao: int.parse(_duracao.text.trim()),
      Campos.observacao: _observacao.text.trim(),
    };
    Navigator.of(context).pop(registro);
  }

  void _cancelar() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.inicial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? Textos.tituloEditar : Textos.tituloNovo),
      ),
      body: Conteudo(
        child: Form(
          key: _chave,
          child: ListView(
            padding: const EdgeInsets.all(Tema.espaco),
            children: [
              TextFormField(
                key: const Key('campoTema'),
                controller: _tema,
                validator: _validarTema,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: Textos.rotuloTema,
                ),
              ),
              const SizedBox(height: Tema.espaco),
              TextFormField(
                key: const Key('campoDuracao'),
                controller: _duracao,
                validator: _validarDuracao,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: Textos.rotuloDuracao(
                    Regras.duracaoMinima,
                    Regras.duracaoMaxima,
                  ),
                  suffixText: Textos.sufixoDuracao,
                ),
              ),
              const SizedBox(height: Tema.espaco),
              TextFormField(
                key: const Key('campoObservacao'),
                controller: _observacao,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: Textos.rotuloObservacao,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('confirmar'),
                onPressed: _confirmar,
                child: const Text(Textos.confirmar),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('cancelar'),
                onPressed: _cancelar,
                child: const Text(Textos.cancelar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
