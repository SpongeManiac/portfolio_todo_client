library todo;

class Todo {
  int id;
  String title;
  String description;
  bool completed;

  static Todo get empty => Todo('', '', false, id: -1);

  Todo(this.title, this.description, this.completed, {this.id = -1});

  void update(String title, String description, bool completed) {
    this.title = title;
    this.description = description;
    this.completed = completed;
  }

  Todo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        completed = json['completed'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'completed': completed.toString(),
      };
}
