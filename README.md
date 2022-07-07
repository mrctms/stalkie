# Stalkie

Stalkie is an app that can:

- Get current location 
- Take photos 
- Record videos
- Record audio

from a remote phone.

## How it works

You can control the app with a Telegram bot.

In the configuration page you must provide the `bot token`.
Additionally, you can provide a phone number to which the app sends any errors that occur (in case the internet connection is not available).

If the app is configured correctly there is not much to do, if an internet connection is available the service turns on otherwise it turns off.

## Avaiable commands

From the bot you can send these commands:

- `/get_location`, will send the current location (if location is turned on)
- `/get_photos`, will send photos from all avaiable cameras
- `/get_video`, will send the recorded video. You can provide the camera to use and the duration of the video in seconds. Default is first camera and 10 seconds         . E.g `/get_video 1 10`
- `/get_audio`, will send the recorded audio. You can provide the duration in seconds. Default 10 seconds 

## Notes

This app was born for my personal needs, but I think it can be useful for others.

**Beware, although the name might suggest that can be an app for stalking or something like that, it has nothing to do with this, 
rather, the user has the full control over the app, when the service turns on the notification is always on**