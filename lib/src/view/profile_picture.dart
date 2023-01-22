import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? pictureUrl;

  const ProfilePicture({Key? key, this.pictureUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    try {
      if (pictureUrl == null || pictureUrl == '' || pictureUrl == '-') {
        return Container(
          child: Icon(Icons.person,
              size: 50, color: Theme.of(context).highlightColor),
        );
      }

      return Container(
        width: 50,
        height: 50,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(pictureUrl!),
            ),
          ),
        ),
      );
    } catch (err) {
      return Container(
        child: Icon(Icons.person, size: 50, color: Colors.black26),
      );
    }
  }
}
