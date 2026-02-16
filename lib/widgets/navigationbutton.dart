import 'package:flutter/material.dart';
import '../theme/styles.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isActive = false,
    this.isVisible = true,
    required this.title,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final bool isActive;
  final String title;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return isVisible
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
            width: 200,
            decoration: BoxDecoration(
              color: isActive
                  ? Styles.defaultWidgetForeColor
                  : Styles.defaultWidgetBackColorMode,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 55),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      alignment: Alignment.centerLeft,
                      shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  icon: Icon(
                    icon,
                    size: 20,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                  label: Text(
                    title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
