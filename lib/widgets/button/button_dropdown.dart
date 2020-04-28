import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_teachers/themes/index.dart';

// TODO: container for prittified dropdown
class ButtonDropdown extends StatefulWidget {
  final String initValue;
  final List<String> items;
  final ValueChanged<String> onChanged;

  ButtonDropdown(
      {@required this.initValue, @required this.items, @required this.onChanged});

  @override
  State<StatefulWidget> createState() => _ButtonDropdownState();
}

class _ButtonDropdownState extends State<ButtonDropdown> {

  String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: widget.items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String newValue) {
        setState(() {
          _value = newValue;
        });
        widget.onChanged(newValue);
      },
      value: _value,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      underline: Container(
        height: 2,
        color: ThemeGlobalColor().secondaryColorDark,
      ),
    );
  }
}
