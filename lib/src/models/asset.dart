import 'package:chatview/chatview.dart';

class RawAsset {
  final String url;
  final MessageType type;
  Duration? voiceMessageDuration;

  RawAsset({required this.url, required this.type, this.voiceMessageDuration});
}

class AssetModel extends RawAsset{
  final String id;
  final bool assetDownloadRequired;

  AssetModel({required super.url, required super.type, required this.id, super.voiceMessageDuration, this.assetDownloadRequired = false});

  AssetModel.fromRaw({
    required RawAsset rawAsset,
    required this.id,
    this.assetDownloadRequired = false,
  }) : super(
    url: rawAsset.url,
    type: rawAsset.type,
    voiceMessageDuration: rawAsset.voiceMessageDuration,
  );

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      url: json['url'],
      type: MessageType.values.where((element) => element.name == json['type']).first,
      id: json['id'],
      voiceMessageDuration: json['voiceMessageDuration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type.name,
      'id': id,
      'voiceMessageDuration': voiceMessageDuration,
    };
  }

  AssetModel copyWith({String? url, MessageType? type, String? id, bool? assetDownloadRequired, Duration? voiceMessageDuration}) {
    return AssetModel(
      url: url ?? this.url,
      type: type ?? this.type,
      id: id ?? this.id,
      assetDownloadRequired: assetDownloadRequired ?? this.assetDownloadRequired,
      voiceMessageDuration: voiceMessageDuration ?? this.voiceMessageDuration,
    );
  }


}