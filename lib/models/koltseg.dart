class Koltseg {
  final int? id;
  final String userId;
  final String megnevezes;
  final int osszeg;
  final String datum;
  final int mennyiseg;
  final String? kategoria;

  Koltseg({
    this.id,
    required this.userId,
    required this.megnevezes,
    required this.osszeg,
    required this.datum,
    this.mennyiseg = 1,
    this.kategoria,
  });

  factory Koltseg.fromMap(Map<String, dynamic> map) {
    return Koltseg(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      megnevezes: map['megnevezes'] as String,
      osszeg: map['osszeg'] as int,
      datum: map['datum'] as String,
      mennyiseg: map['mennyiseg'] ?? 1,
      kategoria: map['kategoria'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'megnevezes': megnevezes,
      'osszeg': osszeg,
      'datum': datum,
      'mennyiseg': mennyiseg,
      'kategoria': kategoria,
    };
  }

   Koltseg copyWith({
    int? mennyiseg,
    String? megnevezes,
    int? osszeg,
    String? datum,
    String? kategoria,
  }) {
    return Koltseg(
      id: id,
      userId: userId,
      megnevezes: megnevezes ?? this.megnevezes,
      osszeg: osszeg ?? this.osszeg,
      datum: datum ?? this.datum,
      mennyiseg: mennyiseg ?? this.mennyiseg,
      kategoria: kategoria ?? this.kategoria,
    );
  }
}