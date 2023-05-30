import 'package:flutter/material.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:house_wallet/components/tasks/partecipants_list.dart';
import 'package:house_wallet/components/ui/app_bar_fix.dart';
import 'package:house_wallet/components/ui/custom_dialog.dart';
import 'package:house_wallet/data/firestore.dart';
import 'package:house_wallet/data/house_data.dart';
import 'package:house_wallet/data/logged_user.dart';
import 'package:house_wallet/data/tasks/calendar.dart';
import 'package:house_wallet/data/tasks/task.dart';
import 'package:house_wallet/main.dart';
import 'package:house_wallet/pages/tasks/task_details_bottom_sheet.dart';

//TODO live update? / handle edits
class TaskDetailsPage extends StatelessWidget {
  final FirestoreDocument<TaskRef> task;
  final LoggedUser loggedUser;
  final HouseDataRef house;

  const TaskDetailsPage(
    this.task, {
    required this.loggedUser,
    required this.house,
    super.key,
  });

  void _delete(BuildContext context) async {
    final navigator = Navigator.of(context);

    if (!await CustomDialog.confirm(
      context: context,
      title: localizations(context).taskDeleteConfirmDialogTitle,
      content: localizations(context).taskDeleteConfirmDialogContent,
    )) return;

    await task.reference.delete();
    navigator.pop();
  }

  void _edit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => TaskDetailsBottomSheet.edit(task, loggedUser: loggedUser, house: house),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFix(
        title: Text(task.data.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            splashRadius: 24,
            tooltip: localizations(context).taskDeleteConfirmDialogTitle,
            onPressed: () => _delete(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            splashRadius: 24,
            tooltip: localizations(context).taskEditTooltip,
            onPressed: () => _edit(context),
          )
        ],
      ),
      body: ListView(children: [
        const Calendar(),
        Padding(
            padding: const EdgeInsets.all(16),
            // child: Text(task.data.description ?? ""),
            child: SingleChildScrollView(
              child: PadColumn(
                spacing: 16,
                children: [
                  if (task.data.description != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Descrizione: ",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          task.data.description!,
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ParticipantsList(task.data.assignedTo.toSet()),
                ],
              ),
            ))
      ]),
    );
  }
}
