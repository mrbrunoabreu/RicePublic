import 'package:flutter/material.dart';
import '../repository/model/profile.dart';
import '../repository/rice_repository.dart';

class UserAvatar extends StatefulWidget {
  final String? user;
  final Profile? profile;
  final double? radius;
  final RiceRepository repository = RiceRepositoryImpl();

  UserAvatar({this.radius, this.user, this.profile = null});

  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Future<Profile>? avatarFuture;

  @override
  void initState() {
    this.avatarFuture = (this.widget.profile == null)
        ? this.widget.repository.findProfile(
              userId: this.widget.user,
            )
        : Future.value(this.widget.profile);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.avatarFuture,
      builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String? avatarUrl =
              'https://user-images.githubusercontent.com/194400/49531010-48dad180-f8b1-11e8-8d89-1e61320e1d82.png';

          if (snapshot.data?.picture?.url?.isNotEmpty == true &&
              snapshot.data?.picture?.url != '-') {
            avatarUrl = snapshot.data?.picture?.url;
          }

          return CircleAvatar(
            radius: this.widget.radius,
            backgroundImage: NetworkImage(
              avatarUrl!,
            ),
          );
        }

        return Container(
          width: this.widget.radius! * 2,
          height: this.widget.radius! * 2,
        );
      },
    );
  }
}
