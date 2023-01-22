import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rice/src/view/gallery_photo_view.dart';

import '../screen_arguments.dart';

class PhotoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PhotoListPageArguments? args =
        ModalRoute.of(context)!.settings.arguments as PhotoListPageArguments?;

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          reverse: true,
          itemBuilder: (context, index) {
            // const url = args.photos[index].ur
            return _ImageTile(
              args!.photos![index],
              onTapCallback: () => open(
                          context,
                          index,
                          args.photos!
                              .map((url) =>
                                  GalleryItem(id: '$index', resource: url))
                              .toList()),
            );
          },
        ),
      );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile(this.gridImage, {this.onTapCallback = defaultCallback});

  final VoidCallback onTapCallback;
  final String gridImage;

  static void defaultCallback() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Card(
        color: const Color(0x00000000),
        elevation: 0,
        child: GestureDetector(
            onTap: onTapCallback,
            child: Container(
                // padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(gridImage),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ))),
      ),
    );
  }
}
