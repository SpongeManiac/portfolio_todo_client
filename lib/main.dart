import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:todo_client/todo_api.dart';
import 'package:todo_client/crud_page.dart';
import 'package:todo/todo.dart';
import 'base_page.dart';
import 'hideable_floating_action.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Fullstack Todo'),
    );
  }
}

class MyHomePage extends BasePage {
  const MyHomePage({super.key, required super.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends CRUDState<Todo> {
  TodoAPI api = TodoAPI('https://spiretown.fun');
  ValueNotifier<HideableFloatingActionData> floatingActionNotifierRight =
      ValueNotifier(HideableFloatingActionData(false));

  ValueNotifier<HideableFloatingActionData> floatingActionNotifierLeft =
      ValueNotifier(HideableFloatingActionData(false));

  TextEditingController titleField = TextEditingController();
  TextEditingController descriptionField = TextEditingController();
  bool completed = false;

  Future<List<Todo>> getTodos() async {
    return await api.getTodos(context);
  }

  final GlobalKey formKey = GlobalKey<FormState>();

  Widget get todoForm => Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                controller: titleField,
                validator: (value) => validateTitle(value),
                maxLength: 128,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                controller: descriptionField,
                validator: (value) => validateDesc(value),
                maxLength: 1024,
              ),
              CheckboxListTile(
                title: const Text('Completed'),
                value: completed,
                onChanged: (value) {
                  setState(() {
                    completed = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      );
  @override
  void initState() {
    super.initState();
    floatingActionNotifierRight.value = HideableFloatingActionData(
      true,
      () async {
        await setCreate();
      },
      const Icon(
        Icons.add_rounded,
        color: Colors.white,
      ),
    );
  }

  String? validateTitle(String? val) {
    val = val ?? '';
    if (val.isEmpty || val.trim().isEmpty) return 'Please enter some text.';
    return null;
  }

  String? validateDesc(String? val) {
    val = val ?? '';
    return null;
  }

  String? validateHost(String? val) {
    val = val ?? '';
    if (val.isEmpty || !val.contains('http://') || !val.contains('https://'))
      return 'Enter valid Protocol';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: super.build(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HideableFloatingAction(
                floatingActionNotifier:
                    floatingActionNotifierLeft), // This trailing comma makes auto-formatting nicer for build methods.
            HideableFloatingAction(
                floatingActionNotifier: floatingActionNotifierRight),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> setCreate() async {
    floatingActionNotifierLeft.value = HideableFloatingActionData(
      true,
      () async {
        await cancel();
      },
      const Icon(
        Icons.arrow_back_rounded,
        color: Colors.white,
      ),
    );
    floatingActionNotifierRight.value = HideableFloatingActionData(
      true,
      () async {
        await create();
        await setRead();
      },
      const Icon(
        Icons.send_rounded,
        color: Colors.white,
      ),
    );
    titleField.text = '';
    descriptionField.text = '';
    completed = false;
    await super.setCreate();
  }

  @override
  Future<void> setRead() async {
    floatingActionNotifierRight.value = HideableFloatingActionData(
      true,
      () async {
        await setCreate();
      },
      const Icon(
        Icons.add_rounded,
        color: Colors.white,
      ),
    );
    floatingActionNotifierLeft.value = HideableFloatingActionData(
      false,
    );
    titleField.text = '';
    descriptionField.text = '';
    completed = false;
    await super.setRead();
  }

  @override
  Future<void> setUpdate(Todo todo) async {
    floatingActionNotifierLeft.value = HideableFloatingActionData(
      true,
      () async {
        await setRead();
      },
      const Icon(
        Icons.arrow_back_rounded,
        color: Colors.white,
      ),
    );
    floatingActionNotifierRight.value = HideableFloatingActionData(
      true,
      () async {
        itemToEdit!.update(titleField.text, descriptionField.text, completed);
        await update(itemToEdit!);
        await setRead();
      },
      const Icon(
        Icons.send_rounded,
        color: Colors.white,
      ),
    );
    titleField.text = todo.title;
    descriptionField.text = todo.description;
    completed = todo.completed;
    super.setUpdate(todo);
  }

  @override
  Future<Todo> create() async {
    FormState formState = formKey.currentState as FormState;
    if (formState.validate()) {
      Todo todo =
          Todo(titleField.text, descriptionField.text, completed, id: -1);
      if (!await api.createTodo(todo)) {
        return Todo.empty;
      } else {
        return todo;
      }
    }
    return Todo.empty;
  }

  @override
  Future<Todo> update(Todo item) async {
    FormState formState = formKey.currentState as FormState;
    if (formState.validate()) {
      if (!await api.updateTodo(item)) {
        //show snackbar
        return Todo.empty;
      } else {
        return await api.readTodo(item.id);
      }
    }
    return Todo.empty;
  }

  @override
  Future<void> delete(Todo item) async {
    await api.delTodo(item);
    setState(() {});
  }

  @override
  Widget createView(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: todoForm,
          ),
        ],
      ),
    );
  }

  @override
  Widget readView(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // uncomment to edit Todo serve URI at runtime
          // Container(
          //   color: Colors.grey[400],
          //   child: TextFormField(
          //     initialValue: api.host,
          //     onChanged: (value) => api.host = value,
          //   ),
          // ),
          Expanded(
            child: FutureBuilder<List<Todo>>(
              future: getTodos(),
              builder: (context, snapshot) {
                List<Todo> list = snapshot.data ?? [];
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: list.length,
                      itemBuilder: ((context, index) {
                        Todo item = list[index];
                        return ListTile(
                          onTap: () async {
                            item.completed = !item.completed;
                            await api.updateTodo(item);
                            setState(() {});
                          },
                          onLongPress: () async {
                            await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Todo Options'),
                                    actions: [
                                      ListTile(
                                        onTap: () async {
                                          setUpdate(item);
                                          Navigator.of(context).pop();
                                        },
                                        title: const Text('Edit Todo'),
                                        trailing: const Icon(
                                          Icons.edit_rounded,
                                          color: Colors.green,
                                        ),
                                      ),
                                      ListTile(
                                        onTap: () async {
                                          setDelete(item);
                                          Navigator.of(context).pop();
                                        },
                                        leading: const Icon(
                                          Icons.warning_rounded,
                                          color: Colors.red,
                                        ),
                                        title: const Text(
                                          'Delete Todo',
                                          textAlign: TextAlign.center,
                                        ),
                                        trailing: const Icon(
                                          Icons.delete_rounded,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                          title: Text(item.title),
                          subtitle: Text(item.description),
                          trailing: Checkbox(
                            value: item.completed,
                            onChanged: (value) async {
                              item.completed = value ?? false;
                              await api.updateTodo(item);
                              setState(() {});
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget updateView(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: todoForm,
          ),
        ],
      ),
    );
  }

  @override
  Widget deleteView(BuildContext context) {
    if (itemToEdit != null) {
      delete(itemToEdit!);
    }
    setRead();
    return readView(context);
  }
}
