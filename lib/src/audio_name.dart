// Flutter imports:
import 'package:flutter/material.dart';

class StringChangedNotif extends Notification {
  final String name;
  const StringChangedNotif(this.name);
}

class AskName extends StatefulWidget {
  const AskName({super.key});
  @override
  _AskNameState createState() => _AskNameState();
}

class _AskNameState extends State<AskName> {
  final _name = TextEditingController();
  final scrollController = ScrollController();
  final focus = FocusNode();

  @override
  void dispose() {
    // commentController.dispose();
    // focus.dispose();
    _name.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nom'),
      content: DialogFrameWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              autofocus: true,
              scrollPadding: const EdgeInsets.all(20.0),
              keyboardType: TextInputType.multiline,
              onChanged: (value) => setState(() {
                _name.text = value;
              }),
              decoration: InputDecoration(
                labelText: 'Nom',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _name.text = '';
                    });
                  },
                ),
              ),
              controller: _name,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  StringChangedNotif(value).dispatch(context);
                  Navigator.of(context).pop(_name.text);
                }
              },
            ),
            const Spacer(),
            if (_name.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  StringChangedNotif(_name.text).dispatch(context);
                  Navigator.of(context).pop(_name.text);
                },
                icon: const Icon(Icons.done),
              ),
          ],
        ),
      ),
    );
  }
}

class DialogFrameWidget extends StatelessWidget {
  final Widget child;
  const DialogFrameWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    return SingleChildScrollView(
      controller: controller,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width * 0.6,
        child: child,
      ),
    );
  }
}
