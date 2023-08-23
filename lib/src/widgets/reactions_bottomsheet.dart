import 'package:chatview/src/controller/chat_controller.dart';
import 'package:chatview/src/models/models.dart';
import 'package:chatview/src/utils/constants/constants.dart';
import 'package:flutter/material.dart';

class ReactionsBottomSheet {
  Future<void> show({
    required BuildContext context,

    /// Provides reaction instance of message.
    required Reactions reaction,

    /// Provides controller for accessing few function for running chat.
    required ChatController chatController,

    /// Provides configuration of reaction bottom sheet appearance.
    required ReactionsBottomSheetConfiguration? reactionsBottomSheetConfig,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            color: reactionsBottomSheetConfig?.backgroundColor,
            child: ListView.builder(
              padding: reactionsBottomSheetConfig?.bottomSheetPadding ??
                  const EdgeInsets.only(
                    right: 12,
                    left: 12,
                    top: 18,
                  ),
              itemCount: reaction.reactions.length,
              itemBuilder: (_, index) {
                final reactedUser = chatController.getUserFromId(reaction.reactions[index].userID);
                return InkWell(
                  onTap: () {
                    chatController.onRemoveReact(
                      reaction.reactions[index].reaction,
                      reaction.messageID,
                      reaction.reactions[index].userID,
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: reactionsBottomSheetConfig?.reactionWidgetMargin ??
                        const EdgeInsets.only(bottom: 8),
                    padding: reactionsBottomSheetConfig?.reactionWidgetPadding ??
                        const EdgeInsets.all(8),
                    decoration:
                        reactionsBottomSheetConfig?.reactionWidgetDecoration ??
                            BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  offset: const Offset(0, 20),
                                  blurRadius: 40,
                                )
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: reactionsBottomSheetConfig
                                            ?.profileCircleRadius ??
                                        16,
                                    backgroundImage: NetworkImage(
                                      reactedUser.profilePhoto ?? profileImage,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    reactedUser.name,
                                    style: reactionsBottomSheetConfig
                                        ?.reactedUserTextStyle,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              reaction.reactions[index].reaction,
                              style: TextStyle(
                                fontSize:
                                    reactionsBottomSheetConfig?.reactionSize ?? 14,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 8,),
                        Text('Tap to remove', style: Theme.of(context).textTheme.bodySmall,),
                      ],
                    ),
                  ),
                );
              },
            ),

        );
      },
    );
  }
}
