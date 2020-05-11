import 'package:flutter/material.dart';

class InputDropDownButton extends StatelessWidget {
  final String inputKey;
  final IconData icon;
  final int selected;
  final List<DropdownMenuItem<dynamic>> list;
  final String hint;
  final Function change;

  InputDropDownButton(this.inputKey, this.list, this.hint, this.change, this.selected, [this.icon]);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45, style: BorderStyle.solid, width: 1),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: ListTile(
        leading: (icon != null) ? Icon(icon) : null,
        title: DropdownButton(
            isExpanded: true,
            value: selected,
            items: list,
            hint: Text(hint),
            onChanged: (val) {
              change(inputKey, val);
            }),
      ),
    );
  }
}