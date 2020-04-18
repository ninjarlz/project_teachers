import 'package:flutter/material.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/input/base_input_with_icon.dart';

class InputWithIconWidget extends StatefulWidget {
  final TextEditingController ctrl;
  final IconData icon;
  final String hint;
  final String error;
  final TextInputType type;
  final int maxLines;

  InputWithIconWidget(
      {@required this.ctrl,
      @required this.hint,
      @required this.icon,
      this.error,
      this.type,
      this.maxLines});

  @override
  State<StatefulWidget> createState() => _InputWithIconWidgetState();
}

class _InputWithIconWidgetState
    extends BaseInputWithIconWidgetState<InputWithIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          controller: widget.ctrl,
          maxLines: widget.maxLines,
          keyboardType: widget.type != null ? widget.type : TextInputType.text,
          autofocus: false,
          decoration: setDecoration(
              widget.hint, (widget.icon != null) ? Icon(widget.icon) : null),
          validator: (value) => value.isEmpty
              ? widget.error == null
                  ? Translations.of(context).text("error_unknown")
                  : widget.error
              : null,
          obscureText: widget.type == TextInputType.visiblePassword,
        ));
  }
}
