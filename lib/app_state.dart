import 'package:scoped_model/scoped_model.dart';

class AppState extends Model {
  // members
  bool _bluetoothConnected = false;
  String _test = "";

  // getters
  bool get bluetoothConnected => _bluetoothConnected;
  String get test => _test;

  // setters
  void setBluetoothConnected(bool connected) {
    _bluetoothConnected = connected;
    notifyListeners();
  }

  void setTest(String test) {
    _test = test;
    notifyListeners();
  }
}
