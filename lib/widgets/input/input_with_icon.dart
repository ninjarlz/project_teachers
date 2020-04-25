import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: ThemeSearch().searchContainer,
        child: TextFormField(
          controller: widget.ctrl,
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
