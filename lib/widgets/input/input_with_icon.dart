import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:project_teachers/widgets/input/base_input_with_icon.dart';

class InputWithIconWidget extends StatefulWidget {
  final TextEditingController ctrl;
  final IconData icon;
  final String hint;
  final String error;
  final TextInputType type;
  final int maxLines;
  final BoxDecoration decoration;
  final ValueChanged<String> onFieldSubmitted;

  InputWithIconWidget(
      {@required this.ctrl,
      @required this.hint,
      @required this.icon,
      this.onFieldSubmitted,
      this.error,
      this.type,
      this.maxLines,
      this.decoration});

  @override
  State<StatefulWidget> createState() => _InputWithIconWidgetState();
}

class _InputWithIconWidgetState
    extends BaseInputWithIconWidgetState<InputWithIconWidget> {

  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        _focusNode.unfocus();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: widget.decoration,
        child: TextFormField(
          focusNode: _focusNode,
          controller: widget.ctrl,
          textInputAction: widget.maxLines == 1
              ? TextInputAction.done
              : TextInputAction.newline,
          maxLines: widget.maxLines,
          keyboardType: widget.type != null ? widget.type : TextInputType.text,
          autofocus: false,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: setDecoration(
              widget.hint, (widget.icon != null) ? Icon(widget.icon) : null),
          validator: (value) =>
              value.isEmpty ? widget.error == null ? null : widget.error : null,
          obscureText: widget.type == TextInputType.visiblePassword,
        ));
  }
}
