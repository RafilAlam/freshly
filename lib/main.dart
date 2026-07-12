import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(DevicePreview(builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Freshly',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 53, 62, 74),
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(),
      ),
      home: const MyHomePage(title: 'Freshly'),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final itemsState = useState<List<Item>>([]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 86, 66),

        title: Text(title, style: GoogleFonts.geom(fontSize: 24.0)),
        centerTitle: false,
      ),
      body: Center(
        child: SlidableAutoCloseBehavior(
          closeWhenOpened: true,
          closeWhenTapped: true,
          child: ListView.separated(
            padding: EdgeInsets.all(5.0),
            itemCount: itemsState.value.length,
            itemBuilder: (context, index) {
              return Slidable(
                endActionPane: ActionPane(
                  extentRatio: 0.2,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        itemsState.value = List.from(itemsState.value)..removeAt(index);
                      },
                      backgroundColor: const Color.fromARGB(255, 138, 53, 47),
                      borderRadius: BorderRadius.horizontal(left: Radius.zero, right: Radius.circular(8.0)),
                      icon: Icons.delete,
                      label: 'Delete'
                    )
                  ]
                ),
          
                child: ListTile(
                  title: Text(itemsState.value[index].name, style: GoogleFonts.lexend(fontSize: 15.0, color: const Color.fromARGB(203, 255, 255, 255))),
                  tileColor: const Color.fromARGB(10, 189, 236, 185),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  trailing: Text(itemsState.value[index].expiry),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: 8.0);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddItemDialog(
              onItemAdded: (name, expiry) {
                itemsState.value = [
                  ...itemsState.value,
                  Item(name: name, expiry: expiry),
                ];
              },
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 54, 94, 55),
        tooltip: 'Add new Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddItemDialog extends HookWidget {
  final Function(String name, String expiry) onItemAdded;
  const AddItemDialog({super.key, required this.onItemAdded});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = useTextEditingController();
    final TextEditingController expiryController = useTextEditingController();
    Future<void> _selectDate() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        expiryController.text = DateFormat('dd/MM/yy').format(pickedDate);
      }
    }

    return AlertDialog(
      title: Text('Add new item'),
      content: SizedBox(
        height: 170.0,
        child: Column(
          spacing: 10.0,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Item name'),
            ),
            TextField(
              readOnly: true,
              onTap: _selectDate,
              controller: expiryController,
              decoration: const InputDecoration(hintText: 'Expiration Date'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton(
                child: Text('Submit'),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    onItemAdded(nameController.text, expiryController.text);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final String expiry;

  const Item({required this.name, required this.expiry});
}
