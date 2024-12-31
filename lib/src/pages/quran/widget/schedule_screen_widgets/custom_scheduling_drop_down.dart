import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String hint;
  final String Function(T) getLabel;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    required this.getLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool valueExists = items.any((item) => item == value);

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<T>(
            value: valueExists ? value : null,
            hint: Text(hint),
            isExpanded: true,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<T>>((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(getLabel(item)),
              );
            }).toList(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
          ),
        ),
      ],
    );
  }
}
