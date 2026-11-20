import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/validators.dart';
import 'auth_decoration.dart';

/// A controller that holds the REAL password in [text] but DRAWS it as dots.
/// The last typed character stays visible for 1 second, then turns into a dot.
/// Reading `controller.text` always gives the real password.
class PasswordEditingController extends TextEditingController {
  PasswordEditingController() {
    addListener(_handleChange);
  }

  static const _revealDuration = Duration(seconds: 1);

  Timer? _timer;
  bool _revealLast = false;
  bool _showAll = false;
  int _previousLength = 0;

  /// True when the user pressed the eye icon to see the whole password.
  bool get showAll => _showAll;
  set showAll(bool value) {
    _showAll = value;
    notifyListeners();
  }

  void _handleChange() {
    final length = text.length;
    if (length > _previousLength) {
      // User typed (or pasted): show the last character for 1 second.
      _revealLast = true;
      _timer?.cancel();
      _timer = Timer(_revealDuration, () {
        _revealLast = false;
        notifyListeners(); // redraw with the dot
      });
    } else if (length < _previousLength) {
      // User deleted: hide immediately.
      _revealLast = false;
      _timer?.cancel();
    }
    _previousLength = length;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_showAll) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final last = text.length - 1;
    final masked = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      masked.write(_revealLast && i == last ? text[i] : '\u2022');
    }
    return TextSpan(style: style, text: masked.toString());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.fieldKey,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
  });

  final PasswordEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final GlobalKey<FormFieldState<String>>? fieldKey;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  @override
  Widget build(BuildContext context) {
    final showAll = widget.controller.showAll;
    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.visiblePassword,
      autocorrect: false,
      enableSuggestions: false,
      // Stops copy/cut of the real password out of the field.
      enableInteractiveSelection: false,
      inputFormatters: [
        LengthLimitingTextInputFormatter(64),
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ],
      decoration: authInputDecoration(
        context,
        label: widget.label,
        icon: Icons.lock_outline,
        suffix: IconButton(
          tooltip: showAll ? 'Hide password' : 'Show password',
          icon: Icon(showAll ? Icons.visibility_off : Icons.visibility),
          onPressed: () =>
              setState(() => widget.controller.showAll = !showAll),
        ),
      ),
    );
  }
}

/// Live list of password requirements that tick off as the user types.
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final text = controller.text;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final rule in Validators.passwordRules)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      rule.test(text)
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 16,
                      color: rule.test(text) ? Colors.green : scheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(rule.label, style: style),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
