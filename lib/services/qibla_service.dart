import 'dart:math';

class QiblaService {

  static const _makkahLat = 21.4225;
  static const _makkahLng = 39.8262;

  static double calculateQiblaDirection(double lat, double lng) {

    final userLat = _degToRad(lat);
    final userLng = _degToRad(lng);
    final kaabaLat = _degToRad(_makkahLat);
    final kaabaLng = _degToRad(_makkahLng);

    final dLng = kaabaLng - userLng;

    final y = sin(dLng);
    final x = cos(userLat) * tan(kaabaLat) - sin(userLat) * cos(dLng);

    double bearing = atan2(y, x);
    bearing = _radToDeg(bearing);
    return (bearing + 360) % 360;
  }

  static double _degToRad(double deg) => deg * pi / 180.0;

  static double _radToDeg(double rad) => rad * 180.0 / pi;
}
