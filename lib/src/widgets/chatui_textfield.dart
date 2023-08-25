/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'dart:async';
import 'dart:io' show Platform;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatview/src/utils/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hl_image_picker/hl_image_picker.dart';
import '../../chatview.dart';
import '../utils/debounce.dart';
import '../utils/package_strings.dart';

class ChatUITextField extends StatefulWidget {
  const ChatUITextField(
      {Key? key,
      this.sendMessageConfig,
      required this.focusNode,
      required this.textEditingController,
      required this.onPressed,
      required this.onRecordingComplete,
      required this.onMediasSelected,
      this.canNotSend = false})
      : super(key: key);

  /// Provides configuration of default text field in chat.
  final SendMessageConfiguration? sendMessageConfig;

  /// Provides focusNode for focusing text field.
  final FocusNode focusNode;

  /// Provides functions which handles text field.
  final TextEditingController textEditingController;

  /// Provides callback when user tap on text field.
  final VoidCallBack onPressed;

  /// Provides callback once voice is recorded.
  final Function(String?) onRecordingComplete;

  /// Provides callback when user select images from camera/gallery.
  final Function(
    List<(String path, MessageType type)>,
    String error,
  ) onMediasSelected;

  final bool canNotSend;

  @override
  State<ChatUITextField> createState() => _ChatUITextFieldState();
}

class _ChatUITextFieldState extends State<ChatUITextField> {
  final ValueNotifier<String> _inputText = ValueNotifier('');


  RecorderController? controller;

  ValueNotifier<bool> isRecording = ValueNotifier(false);

  SendMessageConfiguration? get sendMessageConfig => widget.sendMessageConfig;

  VoiceRecordingConfiguration? get voiceRecordingConfig =>
      widget.sendMessageConfig?.voiceRecordingConfiguration;

  ImagePickerIconsConfiguration? get imagePickerIconsConfig =>
      sendMessageConfig?.imagePickerIconsConfig;

  TextFieldConfiguration? get textFieldConfig =>
      sendMessageConfig?.textFieldConfig;

  OutlineInputBorder get _outLineBorder => OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: textFieldConfig?.borderRadius ??
            BorderRadius.circular(textFieldBorderRadius),
      );


  ValueNotifier<TypeWriterStatus> composingStatus =
      ValueNotifier(TypeWriterStatus.typed);

  late Debouncer debouncer;

  void onFocusChange(){
    composingStatus.value = widget.focusNode.hasFocus ? TypeWriterStatus.typing : TypeWriterStatus.typed;
  }

  @override
  void initState() {
    attachListeners();
    widget.focusNode.addListener(onFocusChange);
    debouncer = Debouncer(
        sendMessageConfig?.textFieldConfig?.compositionThresholdTime ??
            const Duration(seconds: 10));
    super.initState();

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      controller = RecorderController();
    }
  }

  @override
  void dispose() {
    debouncer.dispose();
    composingStatus.dispose();
    isRecording.dispose();
    _inputText.dispose();
    widget.focusNode.removeListener(onFocusChange);
    super.dispose();
  }

  void attachListeners() {
    composingStatus.addListener(() {
      widget.sendMessageConfig?.textFieldConfig?.onMessageTyping
          ?.call(composingStatus.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          textFieldConfig?.padding ?? const EdgeInsets.symmetric(horizontal: 6),
      margin: textFieldConfig?.margin,
      decoration: BoxDecoration(
        borderRadius: textFieldConfig?.borderRadius ??
            BorderRadius.circular(textFieldBorderRadius),
        color: sendMessageConfig?.textFieldBackgroundColor ?? Colors.white,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: isRecording,
        builder: (_, isRecordingValue, child) {
          return Row(
            children: [
              if (isRecordingValue && controller != null && !kIsWeb)
                AudioWaveforms(
                  size: Size(MediaQuery.sizeOf(context).width * 0.75, 50),
                  recorderController: controller!,
                  margin: voiceRecordingConfig?.margin,
                  padding: voiceRecordingConfig?.padding ??
                      const EdgeInsets.symmetric(horizontal: 8),
                  decoration: voiceRecordingConfig?.decoration ??
                      BoxDecoration(
                        color: voiceRecordingConfig?.backgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                  waveStyle: voiceRecordingConfig?.waveStyle ??
                      WaveStyle(
                        extendWaveform: true,
                        showMiddleLine: false,
                        waveColor: voiceRecordingConfig?.waveStyle?.waveColor ??
                            Colors.black,
                      ),
                )
              else
                Expanded(
                  child: TextField(
                    focusNode: widget.focusNode,
                    controller: widget.textEditingController,
                    style: textFieldConfig?.textStyle ??
                        const TextStyle(color: Colors.white),
                    maxLines: textFieldConfig?.maxLines ?? 5,
                    minLines: textFieldConfig?.minLines ?? 1,
                    maxLength: 5000,
                    keyboardType: textFieldConfig?.textInputType,
                    inputFormatters: textFieldConfig?.inputFormatters,
                    onChanged: _onChanged,
                    buildCounter: (context,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    textCapitalization: textFieldConfig?.textCapitalization ??
                        TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText:
                          textFieldConfig?.hintText ?? PackageStrings.message,
                      fillColor: sendMessageConfig?.textFieldBackgroundColor ??
                          Colors.white,
                      filled: true,
                      hintStyle: textFieldConfig?.hintStyle ??
                          TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.25,
                          ),
                      contentPadding: textFieldConfig?.contentPadding ??
                          const EdgeInsets.symmetric(horizontal: 6),
                      border: _outLineBorder,
                      focusedBorder: _outLineBorder,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: textFieldConfig?.borderRadius ??
                            BorderRadius.circular(textFieldBorderRadius),
                      ),
                    ),
                  ),
                ),
              ValueListenableBuilder<String>(
                valueListenable: _inputText,
                builder: (_, inputTextValue, child) {
                  if (inputTextValue.isNotEmpty) {
                    return IconButton(
                      color: sendMessageConfig?.defaultSendButtonColor ??
                          Colors.green,
                      onPressed: widget.canNotSend
                          ? null
                          : () {
                              widget.onPressed();
                              _inputText.value = '';
                            },
                      icon: widget.canNotSend
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color:
                                    sendMessageConfig?.defaultSendButtonColor ??
                                        Colors.green,
                              ),
                            )
                          : sendMessageConfig?.sendButtonIcon ??
                              const Icon(Icons.send),
                    );
                  } else {
                    return Row(
                      children: [
                        if (!isRecordingValue) ...[
                          IconButton(
                            constraints: const BoxConstraints(),
                            // onPressed: () => _onIconPressed(
                            //   config: widget
                            //       .sendMessageConfig?.imagePickerConfiguration,
                            // ),
                            onPressed: _pickMedia,
                            icon:
                                imagePickerIconsConfig?.cameraImagePickerIcon ??
                                    Icon(
                                      Icons.image,
                                      color: imagePickerIconsConfig
                                          ?.cameraIconColor,
                                    ),
                          ),
                        ],
                        if (widget.sendMessageConfig?.allowRecordingVoice ??
                            true &&
                                Platform.isIOS &&
                                Platform.isAndroid &&
                                !kIsWeb)
                          IconButton(
                            onPressed: _recordOrStop,
                            icon: (isRecordingValue
                                    ? voiceRecordingConfig?.micIcon
                                    : voiceRecordingConfig?.stopIcon) ??
                                Icon(isRecordingValue ? Icons.stop : Icons.mic),
                            color: voiceRecordingConfig?.recorderIconColor,
                          )
                      ],
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _pickMedia() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      final medias = await HLImagePicker()
          .openPicker(pickerOptions: HLPickerOptions(maxSelectedAssets: 5));

      widget.onMediasSelected(
          medias
              .map((e) => (
                    e.path,
                    e.type == 'image' ? MessageType.image : MessageType.video
                  ))
              .toList(),
          '');
    } catch (e) {
      widget.onMediasSelected([], e.toString());
    }
  }

  Future<void> _recordOrStop() async {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android,
      "Voice messages are only supported with android and ios platform",
    );
    if (!isRecording.value) {
      await controller?.record();
      isRecording.value = true;
    } else {
      final path = await controller?.stop();
      isRecording.value = false;
      widget.onRecordingComplete(path);
    }
  }

  void _onChanged(String inputText) {
    // debouncer.run(() {
    //   composingStatus.value = TypeWriterStatus.typed;
    // }, () {
    //   composingStatus.value = TypeWriterStatus.typing;
    // });
    _inputText.value = inputText;
  }
}
