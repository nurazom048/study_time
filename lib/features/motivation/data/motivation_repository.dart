import '../domain/models/motivation_item.dart';

class MotivationRepository {
  static const List<MotivationItem> authenticList = [
    MotivationItem(
      id: 'hadith_muslim_2699',
      type: MotivationType.hadith,
      text: 'যে ব্যক্তি জ্ঞান অর্জনের পথে চলে, আল্লাহ তার জন্য জান্নাতের পথ সহজ করে দেন।',
      source: 'সহিহ মুসলিম',
      reference: 'হাদীস নং ২৬৯৯',
    ),
    MotivationItem(
      id: 'quran_taha_114',
      type: MotivationType.quran,
      text: 'বলুন: হে আমার পালনকর্তা! আমার জ্ঞান বৃদ্ধি করে দিন।',
      source: 'সূরা ত্ব-হা',
      reference: 'আয়াত ১১৪',
    ),
    MotivationItem(
      id: 'hadith_tirmidhi_2646',
      type: MotivationType.hadith,
      text: 'জ্ঞানের অন্বেষণে যে বের হয়, সে ফিরে না আসা পর্যন্ত আল্লাহর রাস্তায় থাকে।',
      source: 'জামে আত-তিরমিযী',
      reference: 'হাদীস নং ২৬৪৬',
    ),
    MotivationItem(
      id: 'hadith_bukhari_6412',
      type: MotivationType.discipline,
      text: 'দুটি নেয়ামতের ব্যাপারে অধিকাংশ মানুষ ক্ষতিগ্রস্ত: সুস্থতা এবং অবসর সময়।',
      source: 'সহিহ বুখারী',
      reference: 'হাদীস নং ৬৪১২',
    ),
    MotivationItem(
      id: 'quran_zumar_9',
      type: MotivationType.quran,
      text: 'বলুন: যারা জানে এবং যারা জানে না, তারা কি সমান হতে পারে?',
      source: 'সূরা আয-যুমার',
      reference: 'আয়াত ৯',
    ),
    MotivationItem(
      id: 'hadith_ibn_majah_224',
      type: MotivationType.study,
      text: 'জ্ঞান অর্জন করা প্রত্যেক মুসলমানের ওপর ফরজ।',
      source: 'সুনান ইবনে মাজাহ',
      reference: 'হাদীস নং ২২৪',
    ),
    MotivationItem(
      id: 'hadith_muslim_1631',
      type: MotivationType.study,
      text: 'মানুষ যখন মারা যায় তখন তিনটি বিষয় ছাড়া তার সকল আমল বন্ধ হয়ে যায়: তার মধ্যে একটি হলো উপকারী জ্ঞান।',
      source: 'সহিহ মুসলিম',
      reference: 'হাদীস নং ১৬৩১',
    ),
    MotivationItem(
      id: 'discipline_time_1',
      type: MotivationType.discipline,
      text: 'প্রতিটি মুহূর্ত মহামূল্যবান। লক্ষ্য স্থির রেখে প্রতিদিনের ছোট ছোট অগ্রগতিই একদিন বড় সাফল্য বয়ে আনে।',
      source: 'জ্ঞান ও অধ্যবসায়',
      reference: 'মনোযোগ ও শৃঙ্খলা',
    ),
  ];

  /// Returns today's motivation deterministically based on today's calendar date
  MotivationItem getTodayMotivation({DateTime? date}) {
    final now = date ?? DateTime.now();
    // Deterministic day index
    final dayIndex = (now.year * 365 + now.month * 31 + now.day) % authenticList.length;
    return authenticList[dayIndex];
  }
}
