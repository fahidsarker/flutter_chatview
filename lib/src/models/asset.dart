import 'package:chatview/chatview.dart';

class RawAsset {
  final String url;
  final MessageType type;
  Duration? voiceMessageDuration;

  RawAsset({required this.url, required this.type, this.voiceMessageDuration});
}

class AssetModel extends RawAsset {
  final String id;
  final bool assetDownloadRequired;
  final bool pickedFromFile;
  final bool isDownloading;
  final bool isUploading;

  AssetModel(
      {required super.url,
      required super.type,
      required this.id,
      super.voiceMessageDuration,
      this.assetDownloadRequired = false,
      this.pickedFromFile = false,
      this.isDownloading = false,
      this.isUploading = false});

  AssetModel.fromRaw({
    required RawAsset rawAsset,
    required this.id,
    this.assetDownloadRequired = false,
    this.pickedFromFile = false,
    this.isDownloading = false,
    this.isUploading = false,
  }) : super(
          url: rawAsset.url,
          type: rawAsset.type,
          voiceMessageDuration: rawAsset.voiceMessageDuration,
        );

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      url: json['url'],
      type: MessageType.values
          .where((element) => element.name == json['type'])
          .first,
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

  @override
  String toString() {
    return 'AssetModel{id: $id, assetDownloadRequired: $assetDownloadRequired}';
  }

  AssetModel copyWith({
    String? url,
    MessageType? type,
    String? id,
    bool? assetDownloadRequired,
    Duration? voiceMessageDuration,
    bool? pickedFromFile,
    bool? isDownloading,
    bool? isUploading,
  }) {
    return AssetModel(
      url: url ?? this.url,
      type: type ?? this.type,
      id: id ?? this.id,
      assetDownloadRequired:
          assetDownloadRequired ?? this.assetDownloadRequired,
      voiceMessageDuration: voiceMessageDuration ?? this.voiceMessageDuration,
      pickedFromFile: pickedFromFile ?? this.pickedFromFile,
      isDownloading: isDownloading ?? this.isDownloading,
      isUploading: isUploading ?? this.isUploading,
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          assetDownloadRequired == other.assetDownloadRequired &&
          pickedFromFile == other.pickedFromFile &&
          isDownloading == other.isDownloading &&
          isUploading == other.isUploading;

  @override
  int get hashCode =>
      id.hashCode ^
      assetDownloadRequired.hashCode ^
      pickedFromFile.hashCode ^
      isDownloading.hashCode ^
      isUploading.hashCode;

  String get signature => '$id${type.name}$voiceMessageDuration$assetDownloadRequired$pickedFromFile$isDownloading$isUploading';
}


