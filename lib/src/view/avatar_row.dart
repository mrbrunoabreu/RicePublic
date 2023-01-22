import 'package:flutter/material.dart';

typedef Widget WidgetWrapper(int index, Widget child);

List<Widget> buildAvatarRow({
  required List<String?> photos,
  required int limit,
  WidgetWrapper? buildWrapper,
  BuildContext? context
}) {
  final length = photos.length;

  final isOverLimit = length > limit;

  final indexes = List.generate(
    photos.take(isOverLimit ? limit : length).length,
    (index) => index,
  );

  final avatars = indexes.map<Widget>(
    (index) {
      final child = Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(color: Theme.of(context!).backgroundColor, shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(
            photos[index]!,
          ),
        ),
      );

      if (buildWrapper == null) {
        return child;
      }

      return buildWrapper(
        index,
        child,
      );
    },
  ).toList();

  if (isOverLimit) {
    final overLimitWidget = Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: 15,
        child: Text(
          '+${length - 3}',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
    );

    if (buildWrapper == null) {
      avatars.add(overLimitWidget);
    } else {
      avatars.add(buildWrapper(limit, overLimitWidget));
    }
  }

  return avatars;
}
