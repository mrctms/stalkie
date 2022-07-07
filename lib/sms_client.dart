import 'package:background_sms/background_sms.dart';
import 'package:stalkie/settings.dart';

class SmsClient {
  static Future sendSMS(String msg) async {
    var number = AppSettings.getNumber();
    if (number != null) {
      await BackgroundSms.sendMessage(
          message: msg, phoneNumber: number.toString());
    }
  }
}
