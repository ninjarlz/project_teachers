import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:project_teachers/themes/search.dart';
import 'package:project_teachers/widgets/input/base_input_search.dart';

class InputSearchWidget extends StatefulWidget {
  final TextEditingController ctrl;
  final Function submitChange;

  InputSearchWidget({@required this.ctrl, this.submitChange});

  @override
  State<StatefulWidget> createState() => _InputSearchWidgetState();
}

class _InputSearchWidgetState extends BaseInputSearchWidgetState<InputSearchWidget> {

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
        decoration: ThemeSearch().searchContainer,
        child: TextFormField(
          focusNode: _focusNode,
          controller: widget.ctrl,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: setDecoration(),
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
            if (widget.submitChange != null) widget.submitChange();
          },
        ));
  }
}
