class Memory {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String imageAsset; // for dummy images
  final String? imagePath; // for camera/gallery images
  final String? caption;
  final double lat;
  final double lng;

  Memory({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.imageAsset,
    required this.lat,
    required this.lng,
    this.imagePath,
    this.caption,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      imageAsset: json['imageAsset'],
      imagePath: json['imagePath'],
      caption: json['caption'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'location': location,
    'imageAsset': imageAsset,
    'imagePath': imagePath,
    'caption': caption,
    'lat': lat,
    'lng': lng,
  };
}
