// class Reaction {
//   Reaction({
//     required this.reactions,
//     required this.reactedUserIds,
//   });
//
//   factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
//         reactions: (json['reactions'] as List<dynamic>).cast<String>(),
//         reactedUserIds: (json['reactedUserIds'] as List<dynamic>).cast<String>(),
//       );
//
//   /// Provides list of reaction in single message.
//   final List<String> reactions;
//
//   /// Provides list of user who reacted on message.
//   final List<String> reactedUserIds;
//
//   Map<String, dynamic> toJson() => {
//         'reactions': reactions,
//         'reactedUserIds': reactedUserIds,
//       };
// }
import 'package:collection/collection.dart';
class Reactions {
  final List<UserReaction> _reactions;
  final String messageID;

  Reactions(this.messageID, this._reactions);

  Map<String, dynamic> get json {
    return {
      for (var reaction in _reactions) reaction.userID: reaction.reactions,
    };
  }

  Reactions.fromJson(this.messageID, Map<String, dynamic> json)
      : _reactions = json.entries
      .map((e) => UserReaction(e.key, (e.value as List<dynamic>).cast<String>()))
      .toList();

  List<UserReactionElement> get reactions => _reactions
      .map((e) => e.reactions.map((r) => UserReactionElement._(e.userID, r)))
      .expand((element) => element)
      .toList();

  int get reactionCount => reactions.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reactions &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(reactions, other.reactions) &&
          messageID == other.messageID;

  @override
  int get hashCode => _reactions.hashCode ^ messageID.hashCode;
}

class UserReactionElement {
  final String userID;
  final String reaction;

  UserReactionElement._(this.userID, this.reaction);

  @override
  String toString() {
    return reaction;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserReactionElement &&
          runtimeType == other.runtimeType &&
          userID == other.userID &&
          reaction == other.reaction;

  @override
  int get hashCode => userID.hashCode ^ reaction.hashCode;
}

class UserReaction {
  final String userID;
  final List<String> reactions;

  UserReaction(this.userID, this.reactions);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserReaction &&
          runtimeType == other.runtimeType &&
          userID == other.userID &&
          const ListEquality().equals(reactions, other.reactions);

  @override
  int get hashCode => userID.hashCode ^ reactions.hashCode;
}
