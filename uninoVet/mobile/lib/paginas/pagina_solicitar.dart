import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../config/textos.dart';
import '../modelos/opcoes.dart';
import '../servicos/api.dart';

// Formulario para o tutor solicitar consulta ou servico. Mostra so os horarios
// livres que o servidor devolve; quem decide a reserva e a clinica, ao aceitar.
class PaginaSolicitar extends StatefulWidget {
  final List<Pet> pets;

  const PaginaSolicitar({super.key, required this.pets});

  @override
  State<PaginaSolicitar> createState() => _PaginaSolicitarState();
}

class _PaginaSolicitarState extends State<PaginaSolicitar> {
  final Api _api = Api();
  final TextEditingController _motivo = TextEditingController();

  List<Servico> _servicos = <Servico>[];
  List<VeterinarioOpcao> _veterinarios = <VeterinarioOpcao>[];
  List<String> _horarios = <String>[];

  Pet? _pet;
  Servico? _servico;
  VeterinarioOpcao? _veterinario;
  DateTime? _dia;
  String? _horario;

  bool _carregando = true;
  bool _buscandoHorarios = false;
  bool _enviando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    if (widget.pets.isNotEmpty) {
      _pet = widget.pets.first;
    }
    _carregarOpcoes();
  }

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _carregarOpcoes() async {
    try {
      final servicos = await _api.buscarServicos();
      final veterinarios = await _api.buscarVeterinarios();
      if (!mounted) {
        return;
      }
      setState(() {
        _servicos = servicos;
        _veterinarios = veterinarios;
        _carregando = false;
        if (servicos.isNotEmpty) {
          _servico = servicos.first;
        }
        if (veterinarios.isNotEmpty) {
          _veterinario = veterinarios.first;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erro = Textos.semConexao;
        _carregando = false;
      });
    }
  }

  String _diaTexto(DateTime dia) {
    final mes = dia.month.toString().padLeft(2, '0');
    final diaDoMes = dia.day.toString().padLeft(2, '0');
    return '${dia.year}-$mes-$diaDoMes';
  }

  String _diaBonito(DateTime dia) {
    final mes = dia.month.toString().padLeft(2, '0');
    final diaDoMes = dia.day.toString().padLeft(2, '0');
    return '$diaDoMes/$mes/${dia.year}';
  }

  Future<void> _escolherDia() async {
    final hoje = DateTime.now();
    final escolhido = await showDatePicker(
      context: context,
      initialDate: _dia ?? hoje,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 120)),
    );
    if (escolhido == null) {
      return;
    }
    setState(() {
      _dia = escolhido;
    });
    await _buscarHorarios();
  }

  // Sempre que pet, servico, veterinario ou dia mudam, os horarios livres mudam.
  Future<void> _buscarHorarios() async {
    final dia = _dia;
    final servico = _servico;
    final veterinario = _veterinario;
    if (dia == null || servico == null || veterinario == null) {
      return;
    }
    setState(() {
      _buscandoHorarios = true;
      _horario = null;
      _erro = null;
    });
    try {
      final horarios = await _api.buscarHorarios(
        veterinarioId: veterinario.id,
        servicoId: servico.id,
        dia: _diaTexto(dia),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _horarios = horarios;
        _buscandoHorarios = false;
      });
    } on ErroApi catch (erro) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erro = erro.mensagem;
        _horarios = <String>[];
        _buscandoHorarios = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erro = Textos.semConexao;
        _buscandoHorarios = false;
      });
    }
  }

  bool get _podeEnviar {
    final temMotivo = _motivo.text.trim().isNotEmpty;
    return _pet != null && _servico != null && _veterinario != null && _dia != null && _horario != null && temMotivo;
  }

  Future<void> _enviar() async {
    final pet = _pet;
    final servico = _servico;
    final veterinario = _veterinario;
    final dia = _dia;
    final horario = _horario;
    if (pet == null || servico == null || veterinario == null || dia == null || horario == null) {
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await _api.solicitar(
        animalId: pet.id,
        veterinarioId: veterinario.id,
        servicoId: servico.id,
        dataHora: '${_diaTexto(dia)} $horario',
        motivo: _motivo.text.trim(),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on ErroApi catch (erro) {
      if (!mounted) {
        return;
      }
      setState(() {
        _erro = erro.mensagem;
        _enviando = false;
      });
      await _buscarHorarios();
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(title: const Text(Textos.solicitarTitulo)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _corpo(),
          ),
        ),
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.pets.isEmpty) {
      return const Center(child: Text(Textos.cadastreUmPet));
    }
    final esquema = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(Tema.espaco),
      children: [
        Text(
          Textos.solicitarAviso,
          style: TextStyle(color: esquema.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        _seletorDePet(),
        const SizedBox(height: 12),
        _seletorDeServico(),
        const SizedBox(height: 12),
        _seletorDeVeterinario(),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _escolherDia,
          icon: const Icon(Icons.calendar_today),
          label: Text(_dia == null ? Textos.escolhaDia : '${Textos.rotuloDia}: ${_diaBonito(_dia!)}'),
        ),
        const SizedBox(height: 12),
        _blocoDeHorarios(),
        const SizedBox(height: 12),
        TextField(
          controller: _motivo,
          maxLength: 160,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: Textos.rotuloMotivo),
        ),
        if (_erro != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_erro!, style: TextStyle(color: esquema.error)),
          ),
        FilledButton(
          onPressed: (_podeEnviar && !_enviando) ? _enviar : null,
          child: _enviando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(Textos.enviarPedido),
        ),
      ],
    );
  }

  Widget _seletorDePet() {
    final itens = <DropdownMenuItem<Pet>>[];
    for (final pet in widget.pets) {
      itens.add(DropdownMenuItem<Pet>(value: pet, child: Text('${pet.nome} (${pet.especie})')));
    }
    return DropdownButtonFormField<Pet>(
      value: _pet,
      items: itens,
      decoration: const InputDecoration(labelText: Textos.rotuloPet),
      onChanged: (pet) {
        setState(() {
          _pet = pet;
        });
      },
    );
  }

  Widget _seletorDeServico() {
    final itens = <DropdownMenuItem<Servico>>[];
    for (final servico in _servicos) {
      itens.add(DropdownMenuItem<Servico>(
        value: servico,
        child: Text('${servico.nome} (${servico.duracaoMinutos} min)'),
      ));
    }
    return DropdownButtonFormField<Servico>(
      value: _servico,
      items: itens,
      decoration: const InputDecoration(labelText: Textos.rotuloServico),
      onChanged: (servico) {
        setState(() {
          _servico = servico;
        });
        _buscarHorarios();
      },
    );
  }

  Widget _seletorDeVeterinario() {
    final itens = <DropdownMenuItem<VeterinarioOpcao>>[];
    for (final veterinario in _veterinarios) {
      itens.add(DropdownMenuItem<VeterinarioOpcao>(
        value: veterinario,
        child: Text('${veterinario.nome} · ${veterinario.especialidade}'),
      ));
    }
    return DropdownButtonFormField<VeterinarioOpcao>(
      value: _veterinario,
      isExpanded: true,
      items: itens,
      decoration: const InputDecoration(labelText: Textos.rotuloVeterinario),
      onChanged: (veterinario) {
        setState(() {
          _veterinario = veterinario;
        });
        _buscarHorarios();
      },
    );
  }

  Widget _blocoDeHorarios() {
    if (_dia == null) {
      return const SizedBox.shrink();
    }
    if (_buscandoHorarios) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_horarios.isEmpty) {
      return const Text(Textos.semHorarios);
    }
    final chips = <Widget>[];
    for (final horario in _horarios) {
      chips.add(
        ChoiceChip(
          label: Text(horario),
          selected: _horario == horario,
          onSelected: (_) {
            setState(() {
              _horario = horario;
            });
          },
        ),
      );
    }
    return Wrap(spacing: 8, runSpacing: 4, children: chips);
  }
}
