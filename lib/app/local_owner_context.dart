import 'package:flutter/widgets.dart';

import 'local_owner.dart';

final class LissomOwnerContext extends InheritedWidget {
  const LissomOwnerContext({required this.owner, required super.child, super.key});

  final LissomLocalOwner owner;

  static LissomLocalOwner? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LissomOwnerContext>()?.owner;

  @override
  bool updateShouldNotify(LissomOwnerContext oldWidget) =>
      !identical(owner, oldWidget.owner);
}
