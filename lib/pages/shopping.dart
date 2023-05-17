import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/shopping_item.dart';
import 'package:house_wallet/main.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  static CollectionReference<ShoppingItem> get firestoreRef => FirebaseFirestore.instance.collection("/groups/${LoggedUser.houseId}/shopping").withConverter(fromFirestore: ShoppingItem.fromFirestore, toFirestore: ShoppingItem.toFirestore);

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(title: Text(localizations(context).shoppingPage)),
      body: StreamBuilder(
        stream: Shopping.firestoreRef.snapshots(),
        builder: (context, snapshot) {
          final docs = parseFirestoreDocs(snapshot);

          if (docs == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("Loading..."));
            } else {
              return Center(child: Text("Error (${snapshot.error})"));
            }
          }

          if (docs.isEmpty) {
            return const Center(child: Text("No data"));
          }

          return ListView(children: docs.map(ExampleShoppingItem.new).toList());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Shopping.firestoreRef.add(const ShoppingItem(number: 0)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

//TODO remove
class ExampleShoppingItem extends StatelessWidget {
  final FirestoreDocument<ShoppingItem> doc;

  const ExampleShoppingItem(this.doc, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${doc.data.number}"),
      subtitle: Text(doc.id),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.plus_one),
            onPressed: () {
              doc.reference.update({
                "number": doc.data.number + 1
              });
            },
            splashRadius: 24,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: doc.reference.delete,
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}
