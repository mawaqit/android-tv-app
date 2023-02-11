import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/pages/developer/widgets/number_input_widget.dart';

class SelectorOption<T> {
  final String title;
  final T? value;
  final void Function()? onSelect;
  final List<SelectorOption>? subOptions;

  SelectorOption({
    required this.title,
    this.value,
    this.onSelect,
    this.subOptions,
  });
}

class SelectorWidget<T> extends StatefulWidget {
  const SelectorWidget({
    Key? key,
    required this.options,
    this.title,
    this.onSelected,
  }) : super(key: key);

  final List<SelectorOption> options;
  final String? title;
  final void Function(T? value)? onSelected;

  @override
  State<SelectorWidget<T>> createState() => _SelectorWidgetState<T>();
}

class _SelectorWidgetState<T> extends State<SelectorWidget<T>> {
  bool showMenu = true;
  SelectorOption? _selectedOption;

  List<SelectorOption> get activeOptions =>
      _selectedOption?.subOptions ?? widget.options;

  /// select option from the menu
  void selectOption(SelectorOption? value) {
    setState(() => _selectedOption = null);
    widget.onSelected?.call(value?.value);
    value?.onSelect?.call();
  }

  /// activate sub menu
  activateOption(SelectorOption option) {
    setState(() => _selectedOption = option);

    EasyDebounce.debounce(
      'Selector-Clear-Option',
      const Duration(seconds: 8),
      () => setState(() => _selectedOption = null),
    );
  }

  handleValue(int value) {
    if (value >= activeOptions.length) return;

    final option = activeOptions[value];

    if (option.subOptions != null) {
      activateOption(option);
    } else {
      selectOption(option);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NumberInputScreen(
      onNumberInput: handleValue,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: EdgeInsets.all(10),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null) ...[
                    Text(
                      widget.title!,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                  for (var i = 0; i < activeOptions.length; i++)
                    InkWell(
                      focusColor: Colors.purple,
                      onTap: () => handleValue(i),
                      child: Text(
                        "$i - ${activeOptions[i].title}",
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                ],
              ),
            ),
          ).animate().slideY(
                begin: -1,
                duration: Duration(milliseconds: 500),
              ),
        ),
      ],
    );
  }
}
