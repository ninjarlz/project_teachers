import 'package:flutter/material.dart';
import 'package:project_teachers/repositories/valid_email_address_repository.dart';
import 'package:project_teachers/services/index.dart';

// ignore: must_be_immutable
class InputWithIconWidget extends StatefulWidget {
  String val;
  final IconData icon;
  final String hint;
  final String error;
  final TextInputType type;

  InputWithIconWidget({@required this.val, @required this.hint, @required this.icon, this.error, this.type});

  @override
  State<StatefulWidget> createState() => _InputWithIconWidgetState();

}

class _InputWithIconWidgetState extends State<InputWithIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
            maxLines: 1,
            keyboardType: widget.type != null ? widget.type : TextInputType.text,
            autofocus: false,
            decoration: InputDecoration(
                hintText: widget.hint,
                icon:  Icon(widget.icon, color: Colors.grey)
            ),
            validator: (value) => value.isEmpty ? widget.error == null ? 'Error unknown, please retry' : widget.error : null,
            onSaved: (value) => widget.val = value.trim()
        )
    );
  }
}