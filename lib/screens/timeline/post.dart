import 'package:flutter/material.dart';
import 'package:project_teachers/translations/translations.dart';

import '../../widgets/index.dart';

class TimelinePost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TimelinePostState();
  }
}

class _TimelinePostState extends State<TimelinePost> {
  String _errorMessage = "";
  Color _errorColor;
  int _selectedReceiver = 0;
  List<DropdownMenuItem<int>> _receiverList = [];
  TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addReceiver(0, "tag1");
    _addReceiver(1, "tag2");
  }

  void _addReceiver(int id, String text) {
    setState(() {
      _receiverList.add(DropdownMenuItem(
        child: Text(text),
        value: id,
      ));
    });
  }

  void _changeReceiver(String key, int val) {
    setState(() {
      _selectedReceiver = val;
    });
  }

  void _changeErrorMessage(String message, Color color) {
    if (!mounted) return;
    setState(() {
      _errorMessage = Translations.of(context).text(message);
      _errorColor = color;
    });
  }

  void _postArticle() {}

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Card(elevation: 2, child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: <Widget>[
                ArticleUserWidget(userName: "Firstname Lastname", onPressedFunction: null),
                SizedBox(height: 10),
                InputWithIconWidget(
                    ctrl: _ctrl,
                    hint: Translations.of(context).text("timeline_content"),
                    icon: Icons.edit,
                    type: TextInputType.multiline,
                    error: Translations.of(context).text("timeline_content_empty")),
            Container(
              padding: EdgeInsets.all(10),
              child: InputDropDownButton("receiver", _receiverList, "global.receiver", _changeReceiver, _selectedReceiver)),
              ],
            ),
          ),),
          ButtonPrimaryWidget(text: Translations.of(context).text("timeline_post"), submit: _postArticle),
          Container(
            margin: EdgeInsets.all(15.0),
            child: Text(
              _errorMessage,
              style: TextStyle(color: _errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        child: _buildForm(context),
      ),
    );
  }
}
