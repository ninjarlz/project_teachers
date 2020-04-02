import 'package:flutter/material.dart';
import 'package:project_teachers/translations/translations.dart';

// ignore: must_be_immutable
class InputWithIconWidget extends StatefulWidget {
  TextEditingController ctrl;
  final IconData icon;
  final String hint;
  final String error;
  final TextInputType type;

  InputWithIconWidget({@required this.ctrl, @required this.hint, @required this.icon, this.error, this.type});

  @override
  State<StatefulWidget> createState() => _InputWithIconWidgetState();

}

class _InputWithIconWidgetState extends State<InputWithIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
            controller: widget.ctrl,
            maxLines: 1,
            keyboardType: widget.type != null ? widget.type : TextInputType.text,
            autofocus: false,
            decoration: InputDecoration(
                hintText: widget.hint,
                icon:  Icon(widget.icon, color: Colors.grey)
            ),
            validator: (value) => value.isEmpty ? widget.error == null ? Translations.of(context).text("error_unknown") : widget.error : null,
        )
    );
  }
}