import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';
import '../servicos/api.dart';
import '../widgets/logo.dart';

// Entrar ou criar conta de tutor. O cadastro publico cria so CLIENTE;
// veterinario, secretario e gerente sao criados pelo gerente na clinica.
class PaginaLogin extends StatefulWidget {
  final VoidCallback aoEntrar;

  const PaginaLogin({super.key, required this.aoEntrar});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final Api _api = Api();
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _telefone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();

  bool _cadastrando = false;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _alternarModo() {
    setState(() {
      _cadastrando = !_cadastrando;
      _erro = null;
    });
  }

  String? _validar() {
    final email = _email.text.trim();
    final senha = _senha.text;
    if (email.isEmpty || senha.isEmpty) {
      return Textos.preenchaTudo;
    }
    if (_cadastrando) {
      if (_nome.text.trim().isEmpty || _telefone.text.trim().isEmpty) {
        return Textos.preenchaTudo;
      }
      if (senha.length < 6) {
        return Textos.senhaCurta;
      }
    }
    return null;
  }

  Future<void> _enviar() async {
    final problema = _validar();
    if (problema != null) {
      setState(() {
        _erro = problema;
      });
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      if (_cadastrando) {
        await _api.cadastrar(
          nome: _nome.text.trim(),
          telefone: _telefone.text.trim(),
          email: _email.text.trim(),
          senha: _senha.text,
        );
      } else {
        await _api.entrar(_email.text.trim(), _senha.text);
      }
      if (!mounted) {
        return;
      }
      widget.aoEntrar();
    } on ErroApi catch (erro) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erro = erro.mensagem;
        _enviando = false;
      });
    } catch (erro) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erro = Textos.semConexao;
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final campos = <Widget>[];
    if (_cadastrando) {
      campos.add(_campo(_nome, Textos.rotuloNome, Icons.person_outline));
      campos.add(_campo(_telefone, Textos.rotuloTelefone, Icons.phone_outlined,
          tipo: TextInputType.phone));
    }
    campos.add(_campo(_email, Textos.rotuloEmail, Icons.mail_outline,
        tipo: TextInputType.emailAddress));
    campos.add(_campo(_senha, Textos.rotuloSenha, Icons.lock_outline,
        escondido: true, aoEnviar: _enviar));

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Tema.espaco),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: LogoUninoVet(tamanho: 56)),
                      const SizedBox(height: 16),
                      Text(
                        _cadastrando ? Textos.cadastroTitulo : Textos.loginTitulo,
                        textAlign: TextAlign.center,
                        style: texto.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Textos.loginSubtitulo,
                        textAlign: TextAlign.center,
                        style: texto.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                      ...campos,
                      if (_erro != null) _mensagemDeErro(_erro!),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _enviando ? null : _enviar,
                        child: _enviando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_cadastrando ? Textos.botaoCadastrar : Textos.botaoEntrar),
                      ),
                      TextButton(
                        onPressed: _enviando ? null : _alternarModo,
                        child: Text(_cadastrando ? Textos.irParaLogin : Textos.irParaCadastro),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controlador,
    String rotulo,
    IconData icone, {
    TextInputType? tipo,
    bool escondido = false,
    VoidCallback? aoEnviar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controlador,
        keyboardType: tipo,
        obscureText: escondido,
        onSubmitted: aoEnviar == null ? null : (_) => aoEnviar(),
        decoration: InputDecoration(labelText: rotulo, prefixIcon: Icon(icone)),
      ),
    );
  }

  Widget _mensagemDeErro(String mensagem) {
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(mensagem, style: TextStyle(color: esquema.error)),
    );
  }
}
