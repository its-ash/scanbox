import 'package:flutter/material.dart';
import 'package:snappdf/core/constants/app_constants.dart';

class FilterSelector extends StatelessWidget {
  const FilterSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final ScanFilter selected;
  final ValueChanged<ScanFilter> onSelected;
  final bool enabled;

  String _label(ScanFilter filter) => switch (filter) {
    ScanFilter.original => 'Original',
    ScanFilter.magicColor => 'Magic Color',
    ScanFilter.blackAndWhite => 'B & W',
    ScanFilter.grayscale => 'Grayscale',
    ScanFilter.strongContrast => 'Contrast',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ScanFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = ScanFilter.values[i];
          return ChoiceChip(
            label: Text(_label(filter)),
            selected: selected == filter,
            onSelected: enabled ? (_) => onSelected(filter) : null,
          );
        },
      ),
    );
  }
}
