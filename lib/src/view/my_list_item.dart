import 'package:flutter/material.dart';
import 'package:rice/src/repository/model/profile.dart';

class MyListItem extends StatelessWidget {
  final ListMetadata metadata;

  MyListItem({required this.metadata});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.white,
      ),
      child: Container(
        width: 160,
        height: 140,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Text(
                        this.metadata.name!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline5
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '${this.metadata.items!.length}',
                      style: TextStyle(color: Colors.black),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
              Text(
                this.metadata.shortDescription!,
                style: Theme.of(context).textTheme.headline3
              ),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(.9),
                Colors.black.withOpacity(.4),
              ],
            ),
          ),
        ),
        decoration: BoxDecoration(
          image: this.metadata.photo == null
              ? null
              : DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(this.metadata.photo!),
                ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
