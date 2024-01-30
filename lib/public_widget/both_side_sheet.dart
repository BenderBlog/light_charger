/// Copyright 2024 BenderBlog Rodriguez and Contributors
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import 'package:flutter/material.dart';
import 'package:watermeter_postgraduate/public_widget/public_widget.dart';

class BothSideSheet extends StatefulWidget {
  final Widget child;
  final String title;

  const BothSideSheet({
    super.key,
    required this.child,
    required this.title,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required String title,
  }) =>
      showGeneralDialog<T>(
        barrierDismissible: true,
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return BothSideSheet(
            title: title,
            child: child,
          );
        },
        useRootNavigator: false,
        barrierLabel: title,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween(
              begin: isPhone(context)
                  ? const Offset(0.0, 1.0)
                  : const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
            child: child,
          );
        },
      );

  @override
  State<BothSideSheet> createState() => _BothSideSheetState();
}

class _BothSideSheetState extends State<BothSideSheet> {
  /// We only change the height, to simulate showModalBottomSheet
  late double heightForVertical;

  @override
  void didChangeDependencies() {
    heightForVertical = MediaQuery.of(context).size.height * 0.8;
    super.didChangeDependencies();
  }

  BorderRadius radius(context) => BorderRadius.only(
        topLeft: const Radius.circular(16),
        bottomLeft: !isPhone(context) ? const Radius.circular(16) : Radius.zero,
        topRight: isPhone(context) ? const Radius.circular(16) : Radius.zero,
        bottomRight: Radius.zero,
      );

  double get width => isPhone(context)
      ? MediaQuery.of(context).size.width
      : MediaQuery.of(context).size.width * 0.4 < 360
          ? 360
          : MediaQuery.of(context).size.width * 0.4;

  Widget get onTop => isPhone(context)
      ? GestureDetector(
          onVerticalDragUpdate: (DragUpdateDetails details) {
            setState(() {
              heightForVertical = MediaQuery.of(context).size.height -
                  details.globalPosition.dy;
              if (heightForVertical <
                  MediaQuery.of(context).size.height * 0.4) {
                Navigator.pop(context);
              }
            });
          },
          child: Container(
            height: 30,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surface,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  color: Colors.transparent,
                  width: double.infinity,
                ),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
                  ),
                )
              ],
            ),
          ),
        )
      : Container(
          height: kToolbarHeight,
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isPhone(context) ? Alignment.bottomCenter : Alignment.centerRight,
      child: Container(
        width: width,
        height: isPhone(context) ? heightForVertical : double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: radius(context),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isPhone(context) ? 15 : 10,
            vertical: isPhone(context) ? 0 : 10,
          ),
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: isPhone(context)
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(20),
                    child: onTop,
                  )
                : PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: onTop,
                  ),
            body: widget.child,
          ),
        ),
      ),
    );
  }
}
