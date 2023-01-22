// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editorial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarouselBanner _$CarouselBannerFromJson(Map<String, dynamic> json) {
  return CarouselBanner(
    id: json['id'] as String?,
    title: json['title'] as String?,
    imgUrl: json['imgUrl'] as String?,
    author: json['author'] as String?,
  );
}

Map<String, dynamic> _$CarouselBannerToJson(CarouselBanner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'imgUrl': instance.imgUrl,
      'author': instance.author,
    };

Post _$PostFromJson(Map<String, dynamic> json) {
  return Post(
    html: json['html'] as String?,
    url: json['url'] as String?,
  );
}

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'html': instance.html,
      'url': instance.url,
    };

// **************************************************************************
// ToStringGenerator
// **************************************************************************

String _$CarouselBannerToString(CarouselBanner o) {
  return """CarouselBanner{id: ${o.id}, title: ${o.title}, imgUrl: ${o.imgUrl}, author: ${o.author}}""";
}

String _$PostToString(Post o) {
  return """Post{html: ${o.html}, url: ${o.url}}""";
}
