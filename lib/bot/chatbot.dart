// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'package:aig/bot/algorithm.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ChatbotModel {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  final String _listeningMessage = 'Listening...';
  final String _errorMessage = "Cannot recognize your speech, Please try again";
  Timer? _timer;
  final Algorithm _algorithm = Algorithm();
  final String userId;

  ChatbotModel(this.userId) {
    _speech = stt.SpeechToText();
  }

  String get text => _text;
  bool get isListening => _isListening;

  Future<void> listen(BuildContext context, Function(String) updateText,
      Function(bool) updateListeningState) async {
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      if (!_isListening) {
        try {
          bool available = await _speech.initialize(
            onStatus: (val) {
              print('onStatus: $val');
              if (val == 'done' || val == 'notListening') {
                stopListening(updateText, updateListeningState,
                    forceErrorMessage: true);
              }
            },
            onError: (val) {
              print('onError: $val');
              stopListening(updateText, updateListeningState,
                  forceErrorMessage: true);
            },
          );
          if (available) {
            _isListening = true;
            _text = _listeningMessage;
            updateListeningState(_isListening);
            updateText(_text);
            _startListeningWithTimeout(context, updateText, updateListeningState);
          } else {
            _text = 'Speech recognition is not available on this device.';
            updateText(_text);
          }
        } catch (e) {
          _text = 'Speech recognition is not available on this device.';
          updateText(_text);
        }
      } else {
        stopListening(updateText, updateListeningState,
            forceErrorMessage: true);
      }
    } else if (status.isDenied) {
      await Permission.microphone.request();
    }
  }

  void _startListeningWithTimeout(BuildContext context,
      Function(String) updateText, Function(bool) updateListeningState) {
    _speech.listen(
      onResult: (val) {
        _timer?.cancel();
        _text = val.recognizedWords;
        if (val.finalResult) {
          stopListening(updateText, updateListeningState);
          int status = _algorithm.processInput(_text);
          if (status == 0) {
            _text = "Invalid command, please try again";
            updateText(_text);
          } else {
            _text = 'Press the button and start speaking';
            Navigator.of(context).pop(status);
          }
        } else {
          updateText(_text);
        }
      },
    );

    _timer = Timer(Duration(seconds: 5), () {
      if (_isListening) {
        stopListening(updateText, updateListeningState,
            forceErrorMessage: true);
      }
    });
  }

  void stopListening(
      Function(String) updateText, Function(bool) updateListeningState,
      {bool forceErrorMessage = false}) {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      if (_text == _listeningMessage || forceErrorMessage) {
        _text = _errorMessage;
      }
      _timer?.cancel();
      updateListeningState(_isListening);
      updateText(_text);
    }
  }
}

class ChatbotDialog extends StatefulWidget {
  final String userId;

  const ChatbotDialog({super.key, required this.userId});

  @override
  _ChatbotDialogState createState() => _ChatbotDialogState();
}

class _ChatbotDialogState extends State<ChatbotDialog> {
  late ChatbotModel _chatbotModel;
  String _text = 'Press the button and start speaking';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _chatbotModel = ChatbotModel(widget.userId);
  }

  void _updateText(String text) {
    setState(() {
      _text = text;
    });
  }

  void _updateListeningState(bool isListening) {
    setState(() {
      _isListening = isListening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'How can I help you?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _text = 'Press the button and start speaking';
                      _isListening = false;
                    });
                    Navigator.of(context).pop(0);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(_text),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              onPressed: () {
                if (_isListening) {
                  _chatbotModel.stopListening(
                      _updateText, _updateListeningState,
                      forceErrorMessage: true);
                } else {
                  _chatbotModel.listen(
                      context, _updateText, _updateListeningState);
                }
              },
              iconSize: 36,
              color: _isListening ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
