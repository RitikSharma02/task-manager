import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class OpenContainerWrapper extends StatelessWidget {
  final Widget Function(BuildContext, void Function()) openBuilder;
  final Widget child;

  const OpenContainerWrapper({
    super.key,
    required this.openBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      closedColor: AppColors.accent,
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: openBuilder,
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: openContainer,
          child: child,
        );
      },
      tappable: false, // Handle tap manually
    );
  }
}
