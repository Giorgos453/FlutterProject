/// A Madrid city district with its centroid coordinates.
class District {
  const District({
    required this.name,
    required this.lat,
    required this.lng,
  });

  final String name;
  final double lat;
  final double lng;
}
