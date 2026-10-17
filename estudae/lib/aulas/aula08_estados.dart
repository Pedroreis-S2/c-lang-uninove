import 'package:flutter/material.dart';

import '../config/strings.dart';
import '../config/tema.dart';
import '../widgets/conteudo.dart';

// Aula 8: StatefulWidget. A tela guarda um contador (sem ficar negativo), o
// nome digitado e uma preferencia, e envia esses dados para outra pagina.
class TelaEstudos extends StatefulWidget {
  const TelaEstudos({super.key});

  @override
  State<TelaEstudos> createState() => _TelaEstudosState();
}

class _TelaEstudosState extends State<TelaEstudos> {
  int sessoes = 0;
  String nome = '';
  bool foco = false;

  void _adicionar() {
    setState(() {
      sessoes++;
    });
  }

  void _remover() {
    if (sessoes == 0) {
      return;
    }
    setState(() {
      sessoes--;
    });
  }

  void _mudarNome(String valor) {
    setState(() {
      nome = valor.trim();
    });
  }

  void _mudarExpressa(bool valor) {
    setState(() {
      foco = valor;
    });
  }

  Widget _paginaResumo(BuildContext context) {
    return TelaResumo(sessoes: sessoes, nome: nome, foco: foco);
  }

  void _verResumo() {
    final navegador = Navigator.of(context);
    final rota = MaterialPageRoute<void>(builder: _paginaResumo);
    navegador.push(rota);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    final saudacao = nome.isEmpty
        ? Textos.saudacao
        : Textos.saudacaoNome(nome);
    return Scaffold(
      appBar: AppBar(title: const Text(Textos.tituloEstudos)),
      body: Conteudo(
        child: ListView(
          padding: const EdgeInsets.all(Tema.espaco),
          children: [
            Text(saudacao, style: texto.headlineSmall),
            const SizedBox(height: Tema.espaco),
            Card(
              color: foco
                  ? cores.tertiaryContainer
                  : cores.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(Tema.espaco),
                child: Column(
                  children: [
                    Text(
                      '$sessoes',
                      key: const Key('contador'),
                      style: texto.displayMedium,
                    ),
                    Text(Textos.sessoesConcluidas(sessoes)),
                    const SizedBox(height: Tema.espaco),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('remover'),
                            onPressed: sessoes == 0 ? null : _remover,
                            icon: const Icon(Icons.remove),
                            label: const Text(Textos.desfazerSessao),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('adicionar'),
                            onPressed: _adicionar,
                            icon: const Icon(Icons.add),
                            label: const Text(Textos.concluirSessao),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Tema.espaco),
            TextField(
              key: const Key('campoNomeEstudante'),
              onChanged: _mudarNome,
              decoration: const InputDecoration(
                labelText: Textos.rotuloNome,
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key('modoFoco'),
              value: foco,
              onChanged: _mudarExpressa,
              title: const Text(Textos.modoFoco),
              secondary: const Icon(Icons.local_shipping_outlined),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('verResumo'),
              onPressed: _verResumo,
              child: const Text(Textos.verResumo),
            ),
          ],
        ),
      ),
    );
  }
}

// Recebe os dados pelo construtor; nao guarda estado proprio.
class TelaResumo extends StatelessWidget {
  final int sessoes;
  final String nome;
  final bool foco;

  const TelaResumo({
    super.key,
    required this.sessoes,
    required this.nome,
    required this.foco,
  });

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cliente = nome.isEmpty ? Textos.nomePadrao : nome;
    final textoFoco = foco
        ? Textos.focoAtivoValor
        : Textos.focoInativoValor;
    return Scaffold(
      appBar: AppBar(title: const Text(Textos.tituloResumo)),
      body: Conteudo(
        child: Padding(
          padding: const EdgeInsets.all(Tema.espaco),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(Tema.espaco),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(Textos.resumoSessoes(sessoes), style: texto.titleMedium),
                  const SizedBox(height: 8),
                  Text(Textos.resumoNome(cliente)),
                  Text(Textos.resumoFoco(textoFoco)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
