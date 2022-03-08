import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_pantry/data/database_helper.dart';
import 'package:my_pantry/services/api_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_pantry/model/ingredient.dart';

import '../widget/search_widget.dart';

class AddIngredient extends StatefulWidget {
  const AddIngredient({Key? key}) : super(key: key);

  @override
  _AddIngredientState createState() => _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {
  late Ingredients ingredientList;
  String query = '';
  Timer? debouncer;

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  void dispose() {
    debouncer?.cancel();
    super.dispose();
  }

  void debounce(VoidCallback callback, { Duration duration = const Duration(milliseconds: 1000)}) {
    if (debouncer != null) {
      debouncer!.cancel();
    }
    debouncer = Timer(duration, callback);
  }

  Future init() async {
    final ingredients = await IngredientApiService.instance.fetchIngredients('apple');

    setState(() {
      ingredientList = ingredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home').then((_) => setState(() {}));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange[900],
          title: const Text('Choose an ingredient'),
        ),
        body: Column (
          children: <Widget>[
            buildSearch(),
            Expanded(
                child: ListView.builder(
                  itemCount: ingredientList.results.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredientList.results[index];
                    return buildIngredient(ingredient);
                  },
                )
            )
          ],
        ),
      ),
    );
  }

  Widget buildSearch() => SearchWidget(
    text: query,
    hintText: 'Search ingredient',
    onChanged: searchIngredient,
  );

  Future searchIngredient(String query) async => debounce(() async {
    final ingredients = await IngredientApiService.instance.fetchIngredients(query);

    if (!mounted) return;

    setState(() {
      this.query = query;
      ingredientList = ingredients;
    });
  });

  Widget buildIngredient(Result result) => Padding(
    padding: const EdgeInsets.all(4.0),
    child: Card(
      child: ListTile(
        onTap: () {
          showAlertDialogForAddingIngredient(context, result);
        },
        leading: CircleAvatar(
            backgroundImage: NetworkImage(result.image)
        ),
        title: Text(result.name),
        contentPadding: const EdgeInsets.all(8.0),
      ),
    ),
  );

  void showToastMessage(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1, //for iOS only
        textColor: Colors.black,
        fontSize: 16.0
    );
  }

  void showAlertDialogForAddingIngredient(BuildContext context, Result result) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel",
        style: TextStyle(
            color: Color(0xFFE65100)),
      ),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
        child: const Text("Yes",
          style: TextStyle(
              color: Color(0xFFE65100)),
        ),
        onPressed:  () async {
          await DatabaseHelper.instance.add(result);
          Navigator.pop(context);
        }
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Add"),
      content: const Text("Would you like to add this ingredient to Fridge?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
