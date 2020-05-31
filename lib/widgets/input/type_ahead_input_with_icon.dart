import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:project_teachers/widgets/input/base_input_with_icon.dart';

class TypeAheadInputWithIconWidget extends StatefulWidget {
  final TextEditingController ctrl;
  final IconData icon;
  final String hint;
  final String error;
  final TextInputType type;
  final int maxLines;
  final BoxDecoration decoration;
  final ValueChanged<String> onFieldSubmitted;
  final ValueChanged<String> suggestionsCallback;
  final ValueChanged<String> onSuggestionSelected;

  TypeAheadInputWithIconWidget({@required this.ctrl,
    @required this.hint,
    @required this.icon,
    @required this.suggestionsCallback,
    @required this.onSuggestionSelected,
    this.onFieldSubmitted,
    this.error,
    this.type,
    this.maxLines,
    this.decoration});

  @override
  State<StatefulWidget> createState() => _TypeAheadInputWithIconWidgetState();
}

class _TypeAheadInputWithIconWidgetState
    extends BaseInputWithIconWidgetState<TypeAheadInputWithIconWidget> {

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
        child: TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            focusNode: _focusNode,
            onSubmitted: (value) {
              if (widget.onFieldSubmitted != null) {
                widget.onFieldSubmitted(value);
              };
            },
            controller: widget.ctrl,
            decoration: setDecoration(
                widget.hint, (widget.icon != null) ? Icon(widget.icon) : null),
          ),
          suggestionsCallback: widget.suggestionsCallback,
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: widget.onSuggestionSelected,
          validator: (value) =>
          value.isEmpty ? widget.error == null ? null : widget.error : null,
        ));
  }
}
