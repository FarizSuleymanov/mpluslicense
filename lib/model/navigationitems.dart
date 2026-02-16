import 'package:flutter/material.dart';

enum NavigationItems { users, firms, applications, connections }

extension NavigationItemsExtensions on NavigationItems {
  IconData get icon {
    switch (this) {
      case NavigationItems.firms:
        return Icons.assured_workload;
      case NavigationItems.applications:
        return Icons.android;
      case NavigationItems.connections:
        return Icons.share;
      case NavigationItems.users:
        return Icons.person;
    }
  }
}

extension NavigationItemsExtensions2 on NavigationItems {
  String get title {
    switch (this) {
      case NavigationItems.firms:
        return 'Firmalar';
      case NavigationItems.applications:
        return 'Proqramlar';
      case NavigationItems.connections:
        return 'Bağlantılar';
      case NavigationItems.users:
        return 'İstifadəçilər';
    }
  }
}

enum NavigationItemsFirms { users }

extension NavigationItemsExtensionsFirms on NavigationItemsFirms {
  IconData get icon {
    switch (this) {
      case NavigationItemsFirms.users:
        return Icons.person;
    }
  }
}

extension NavigationItemsExtensions2Firms on NavigationItemsFirms {
  String get title {
    switch (this) {
      case NavigationItemsFirms.users:
        return 'İstifadəçilər';
    }
  }
}
