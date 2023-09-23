import 'package:flutter/material.dart';

class HideableFloatingAction extends StatelessWidget {
  const HideableFloatingAction({
    super.key,
    required this.floatingActionNotifier,
  });

  final ValueNotifier<HideableFloatingActionData> floatingActionNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HideableFloatingActionData>(
        valueListenable: floatingActionNotifier,
        builder: (context, data, _) {
          //setPress();
          if (data.action == null) {
            data.visible = false;
          }
          return Visibility(
            visible: data.visible,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.grey,
              onPressed: data.action,
              child: data.child,
            ),
          );
        });
  }
}

class HideableFloatingActionData {
  HideableFloatingActionData(this.visible, [this.action, this.child]);

  bool visible;
  void Function()? action;
  Widget? child;
}
