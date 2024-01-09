import 'package:perfect_freehand/src/types.dart';

@Deprecated("Use 'PointVector' instead")
class Point extends PointVector {
  const Point(
    super.x,
    super.y, [
    super.pressure,
  ]);
}
