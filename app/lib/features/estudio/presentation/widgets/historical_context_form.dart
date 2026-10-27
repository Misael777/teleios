import 'package:flutter/material.dart';

import '../../../../shared/domain/catalogs/historical_catalog.dart';
import '../../../../shared/domain/entities/historical_context.dart';

/// Formulario cronológico estructurado: alimenta la línea de tiempo.
class HistoricalContextForm extends StatefulWidget {
  const HistoricalContextForm({super.key, required this.value, required this.onChanged});

  final HistoricalContext value;
  final ValueChanged<HistoricalContext> onChanged;

  @override
  State<HistoricalContextForm> createState() => _HistoricalContextFormState();
}

class _HistoricalContextFormState extends State<HistoricalContextForm> {
  late final _author = TextEditingController(text: widget.value.author ?? '');
  late final _year = TextEditingController(text: widget.value.approxYear?.abs().toString() ?? '');
  late bool _bc = (widget.value.approxYear ?? -1) < 0;

  @override
  void didUpdateWidget(HistoricalContextForm old) {
    super.didUpdateWidget(old);
    // Refleja pre-llenados externos (p. ej. al elegir el pasaje).
    if (widget.value.author != old.value.author && widget.value.author != _author.text) {
      _author.text = widget.value.author ?? '';
    }
    if (widget.value.approxYear != old.value.approxYear) {
      final y = widget.value.approxYear;
      if (y?.abs().toString() != _year.text) _year.text = y?.abs().toString() ?? '';
      if (y != null) _bc = y < 0;
    }
  }

  @override
  void dispose() {
    _author.dispose();
    _year.dispose();
    super.dispose();
  }

  void _emitYear() {
    final parsed = int.tryParse(_year.text.trim());
    widget.onChanged(
      widget.value.copyWith(approxYear: () => parsed == null || parsed == 0 ? null : (_bc ? -parsed : parsed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Dropdown(
          label: 'Época',
          value: v.periodId,
          items: HistoricalCatalog.periods,
          onChanged: (id) => widget.onChanged(v.copyWith(periodId: () => id)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Dropdown(
                label: 'Imperio / poder',
                value: v.empireId,
                items: HistoricalCatalog.empires,
                onChanged: (id) => widget.onChanged(v.copyWith(empireId: () => id)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Dropdown(
                label: 'Región',
                value: v.regionId,
                items: HistoricalCatalog.regions,
                onChanged: (id) => widget.onChanged(v.copyWith(regionId: () => id)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _author,
          decoration: const InputDecoration(labelText: 'Autor', isDense: true),
          textCapitalization: TextCapitalization.words,
          onChanged: (text) => widget.onChanged(v.copyWith(author: () => text.trim().isEmpty ? null : text)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _year,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año aproximado (opcional)',
                  helperText: 'Si lo dejas vacío, se usa la mitad de la época.',
                  isDense: true,
                ),
                onChanged: (_) => _emitYear(),
              ),
            ),
            const SizedBox(width: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('a.C.')),
                ButtonSegment(value: false, label: Text('d.C.')),
              ],
              selected: {_bc},
              onSelectionChanged: (s) {
                setState(() => _bc = s.first);
                _emitYear();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _Dropdown<T extends CatalogItem> extends StatelessWidget {
  const _Dropdown({required this.label, required this.value, required this.items, required this.onChanged});

  final String label;
  final String? value;
  final List<T> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String?>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label, isDense: true),
    items: [
      const DropdownMenuItem(value: null, child: Text('—')),
      for (final item in items) DropdownMenuItem(value: item.id, child: Text(item.name)),
    ],
    onChanged: onChanged,
  );
}
