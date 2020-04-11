import 'package:flutter/material.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/themes/index.dart';

class InputWithIconWidget extends StatefulWidget {
  final TextEditingController ctrl;
  final IconData icon;
  final String hint;
  final String error;
  final TextInputType type;

  InputWithIconWidget({@required this.ctrl, @required this.hint, @required this.icon, this.error, this.type});

  @override
  State<StatefulWidget> createState() => _InputWithIconWidgetState();

}

class _InputWithIconWidgetState extends State<InputWithIconWidget> {
  InputDecoration setDecoration(String hint, [Icon icon]) {
    return InputDecoration(
      labelText: hint,
      prefixIcon: icon,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          gapPadding: 3,
          borderSide: BorderSide(color: ThemeGlobalColor().textColor, style: BorderStyle.solid, width: 10.0)),
      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
            controller: widget.ctrl,
            maxLines: 1,
            keyboardType: widget.type != null ? widget.type : TextInputType.text,
            autofocus: false,
            decoration: setDecoration(widget.hint, (widget.icon != null) ? Icon(widget.icon) : null),
            validator: (value) => value.isEmpty ? widget.error == null ? Translations.of(context).text("error_unknown") : widget.error : null,
            obscureText: widget.type == TextInputType.visiblePassword,
        )
    );
  }
}