/// The three supported study modes
enum StudyMode {
  manual,
  faceUpOnFaceDownOff,
  flipToOnScreenOff;

  String get displayName {
    switch (this) {
      case StudyMode.manual:
        return 'Manual Mode';
      case StudyMode.faceUpOnFaceDownOff:
        return 'Flip to OFF (When Straight)';
      case StudyMode.flipToOnScreenOff:
        return 'Flip to ON (Screen Down)';
    }
  }

  String get compactLabel {
    switch (this) {
      case StudyMode.manual:
        return 'Manual';
      case StudyMode.faceUpOnFaceDownOff:
        return 'Face-up ON / Face-down OFF';
      case StudyMode.flipToOnScreenOff:
        return 'Flip to ON / Screen OFF';
    }
  }

  String get shortDescription {
    switch (this) {
      case StudyMode.manual:
        return 'Start and stop manually';
      case StudyMode.faceUpOnFaceDownOff:
        return 'Screen UP = ON • Flip DOWN = OFF (Screen stays awake)';
      case StudyMode.flipToOnScreenOff:
        return 'Flip DOWN = ON • Screen UP = OFF (Screen can turn off)';
    }
  }

  String get bengaliTitle {
    switch (this) {
      case StudyMode.manual:
        return 'ম্যানুয়াল মোড';
      case StudyMode.faceUpOnFaceDownOff:
        return 'সোজা রাখলে চালু / ফ্লিপে বন্ধ';
      case StudyMode.flipToOnScreenOff:
        return 'ফ্লিপ করলে চালু / স্ক্রিন অফ';
    }
  }

  String get bengaliSubtitle {
    switch (this) {
      case StudyMode.manual:
        return 'নিজে হাতে Start / Stop করুন।';
      case StudyMode.faceUpOnFaceDownOff:
        return 'স্ক্রিন উপরে থাকলে চালু, ফ্লিপ করলে বন্ধ। স্ক্রিন আলো নিভবে না।';
      case StudyMode.flipToOnScreenOff:
        return 'স্ক্রিন নিচে রাখলে চালু, সোজা করলে বন্ধ। স্ক্রিনের আলো নিভে থাকবে।';
    }
  }

  static StudyMode fromString(String value) {
    switch (value) {
      case 'faceUpOnFaceDownOff':
      case 'FACE_UP_ON':
        return StudyMode.faceUpOnFaceDownOff;
      case 'flipToOnScreenOff':
      case 'FLIP_TO_ON_SCREEN_OFF':
        return StudyMode.flipToOnScreenOff;
      case 'manual':
      case 'MANUAL':
      default:
        return StudyMode.manual;
    }
  }

  String toStorageString() {
    switch (this) {
      case StudyMode.manual:
        return 'MANUAL';
      case StudyMode.faceUpOnFaceDownOff:
        return 'FACE_UP_ON';
      case StudyMode.flipToOnScreenOff:
        return 'FLIP_TO_ON_SCREEN_OFF';
    }
  }
}
