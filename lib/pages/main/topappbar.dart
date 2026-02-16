import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:mpluslicense/model/userparams.dart';
import '../../theme/styles.dart';
import 'changepassword.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class TopAppBar extends StatefulWidget {
  const TopAppBar(this.userParams, {super.key});

  final UserParams userParams;

  @override
  State<TopAppBar> createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> {
  SampleItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text(
                widget.userParams.userCompanyName,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
          _nameAndProfilePicture(
              context, widget.userParams.userFullName, selectedMenu),
        ],
      ),
    );
  }

  Widget _nameAndProfilePicture(
      BuildContext context, String username, SampleItem? selectedMenu) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        PopupMenuButton<SampleItem>(
          initialValue: selectedMenu,
          icon: Icon(
            Icons.expand_circle_down,
            size: 30,
            color: Styles.defaultWidgetForeColor,
          ),
          onSelected: (SampleItem item) {
            setState(() {
              selectedMenu = item;
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
            PopupMenuItem<SampleItem>(
              value: SampleItem.itemOne,
              child: TextButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChangePassword(widget.userParams)));
                  },
                  icon: const Icon(Icons.account_box),
                  label: const Text(
                    'Şifrə dəyişdir ',
                    textAlign: TextAlign.left,
                  )),
            ),
            PopupMenuItem<SampleItem>(
                value: SampleItem.itemThree,
                child: TextButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      await SessionManager().destroy();
                      if (!context.mounted) return;
                      Navigator.pushNamed(context, '/login');
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Çıxış', textAlign: TextAlign.left))),
          ],
        ),
      ],
    );
  }
}
