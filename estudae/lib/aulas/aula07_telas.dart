import 'package:flutter/material.dart';

import '../config/strings.dart';
import '../config/tema.dart';
import '../widgets/conteudo.dart';
import 'aula08_estados.dart';
import 'aula09_formulario.dart';
import 'aula10_lista.dart';

// Aula 7: tres interfaces com StatelessWidget (TelaInicio, TelaDisciplina e
// AvisoModal) e navegacao entre elas. Tambem e o menu para as outras aulas.
class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key});

  Widget _paginaDisciplina(BuildContext context) {
    return const TelaDisciplina();
  }

  Widget _paginaEstudos(BuildContext context) {
    return const TelaEstudos();
  }

  Widget _paginaUltimaSessao(BuildContext context) {
    return const TelaUltimaSessao();
  }

  Widget _paginaLista(BuildContext context) {
    return const TelaLista();
  }

  void _abrirAviso(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: _construirAviso,
    );
  }

  Widget _construirAviso(BuildContext context) {
    return const AvisoModal();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(Textos.nomeApp)),
      body: Conteudo(
        child: ListView(
          padding: const EdgeInsets.all(Tema.espaco),
          children: [
            Text(Textos.saudacao, style: texto.headlineMedium),
            const SizedBox(height: 4),
            Text(
              Textos.perguntaInicio,
              style: texto.bodyLarge?.copyWith(color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: Tema.espaco),
            Card(
              color: cores.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(Tema.espaco),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 32,
                      color: cores.onPrimaryContainer,
                    ),
                    const SizedBox(width: Tema.espaco),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Textos.destaqueRotulo,
                            style: texto.labelLarge?.copyWith(
                              color: cores.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Textos.destaqueTitulo,
                            style: texto.titleMedium?.copyWith(
                              color: cores.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            Textos.destaqueDetalhe,
                            style: texto.bodyMedium?.copyWith(
                              color: cores.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Tema.espaco),
            _BotaoAbrirPagina(
              rotulo: Textos.verDisciplina,
              icone: Icons.menu_book_outlined,
              destino: _paginaDisciplina,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _abrirAviso(context),
              icon: const Icon(Icons.notifications_none),
              label: const Text(Textos.verAviso),
            ),
            const SizedBox(height: 24),
            _ItemMenu(
              icone: Icons.checklist,
              titulo: Textos.tituloEstudos,
              subtitulo: Textos.aula08Nome,
              destino: _paginaEstudos,
            ),
            const SizedBox(height: 8),
            _ItemMenu(
              icone: Icons.edit_note,
              titulo: Textos.cadastrarSessao,
              subtitulo: Textos.aula09Nome,
              destino: _paginaUltimaSessao,
            ),
            const SizedBox(height: 8),
            _ItemMenu(
              icone: Icons.inventory_2_outlined,
              titulo: Textos.tituloLista,
              subtitulo: Textos.aula10Nome,
              destino: _paginaLista,
            ),
          ],
        ),
      ),
    );
  }
}

class TelaDisciplina extends StatelessWidget {
  const TelaDisciplina({super.key});

  void _voltar(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text(Textos.tituloDisciplina)),
      body: Conteudo(
        child: ListView(
          padding: const EdgeInsets.all(Tema.espaco),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Tema.espaco),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Textos.nomeDisciplina, style: texto.titleLarge),
                    const SizedBox(height: 4),
                    const Text(Textos.descricaoDisciplina),
                    const Divider(height: 32),
                    const Text(Textos.professorDisciplina),
                    const SizedBox(height: 8),
                    const Text(Textos.diaDisciplina),
                    const Text(Textos.horarioDisciplina),
                    const Text(Textos.salaDisciplina),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Tema.espaco),
            FilledButton(
              onPressed: () => _voltar(context),
              child: const Text(Textos.voltarInicio),
            ),
          ],
        ),
      ),
    );
  }
}

class AvisoModal extends StatelessWidget {
  const AvisoModal({super.key});

  void _fechar(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Tema.espaco * 1.5,
          0,
          Tema.espaco * 1.5,
          Tema.espaco * 1.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Textos.tituloAviso, style: texto.titleLarge),
            const SizedBox(height: 8),
            const Text(Textos.textoAviso),
            const SizedBox(height: Tema.espaco),
            FilledButton(
              onPressed: () => _fechar(context),
              child: const Text(Textos.fechar),
            ),
          ],
        ),
      ),
    );
  }
}

// Botao que abre uma pagina. Quem usa informa so a pagina de destino.
class _BotaoAbrirPagina extends StatelessWidget {
  final String rotulo;
  final IconData icone;
  final WidgetBuilder destino;

  const _BotaoAbrirPagina({
    required this.rotulo,
    required this.icone,
    required this.destino,
  });

  void _abrir(BuildContext context) {
    final navegador = Navigator.of(context);
    final rota = MaterialPageRoute<void>(builder: destino);
    navegador.push(rota);
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _abrir(context),
      icon: Icon(icone),
      label: Text(rotulo),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final WidgetBuilder destino;

  const _ItemMenu({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.destino,
  });

  void _abrir(BuildContext context) {
    final navegador = Navigator.of(context);
    final rota = MaterialPageRoute<void>(builder: destino);
    navegador.push(rota);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Tema.espaco,
          vertical: 4,
        ),
        leading: Icon(icone),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _abrir(context),
      ),
    );
  }
}
