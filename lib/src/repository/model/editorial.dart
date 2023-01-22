import 'package:json_annotation/json_annotation.dart';

part 'editorial.g.dart';


@JsonSerializable()
class CarouselBanner {

  String? id;
  String? title;
  String? imgUrl;
  String? author;

  CarouselBanner(
      {
        this.id,
        this.title,
        this.imgUrl,
        this.author,
      }
  );

  factory CarouselBanner.fromJson(Map<String, dynamic> json) => _carouselBannerFromJson(json);
  Map<String, dynamic> toJson() => _$CarouselBannerToJson(this);
}

CarouselBanner _carouselBannerFromJson(Map<String, dynamic> json) {
  return CarouselBanner(
    id:     json['_id']    as String?,
    title:  json['title']  as String?,
    imgUrl: json['imgUrl'] as String?,
    author: json['author'] as String?,
  );
}


@JsonSerializable()
class Post {

  String? html;
  String? url;

  Post({this.html, this.url});

  factory Post.fromJson(Map<String, dynamic> json) => _postFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

Post _postFromJson(Map<String, dynamic> json) {
  return Post(
      html: json['html'] as String?,
      url:  json['url']  as String?
  );
}