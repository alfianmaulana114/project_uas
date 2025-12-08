/// Mapping nama aplikasi ke package name
/// Digunakan untuk blocking aplikasi
class AppPackageMapping {
  static const Map<String, String> _packageMap = {
    // Social Media Apps - DIPERKUAT: Package names yang benar untuk blocking efektif
    'TikTok': 'com.zhiliaoapp.musically',
    'Instagram': 'com.instagram.android',
    'Facebook': 'com.facebook.katana',
    'Snapchat': 'com.snapchat.android',
    'Twitter': 'com.twitter.android',
    'X (Twitter)': 'com.twitter.android',
    'X': 'com.twitter.android', // Alias untuk X (Twitter baru)
    'WhatsApp': 'com.whatsapp',
    'Telegram': 'org.telegram.messenger',
    'LinkedIn': 'com.linkedin.android',
    'Pinterest': 'com.pinterest',
    'Reddit': 'com.reddit.frontpage',
    'Discord': 'com.discord',
    'YouTube': 'com.google.android.youtube',
    'YouTube Shorts': 'com.google.android.youtube',
    'Tumblr': 'com.tumblr',
    'VK': 'com.vk.android',
    'WeChat': 'com.tencent.mm',
    'Line': 'jp.naver.line.android',
    'KakaoTalk': 'com.kakao.talk',
    
    // Video Apps
    'Netflix': 'com.netflix.mediaclient',
    'Disney+': 'com.disney.disneyplus',
    'Prime Video': 'com.amazon.avod.thirdpartyclient',
    'HBO Max': 'com.hbo.hbonow',
    'Spotify': 'com.spotify.music',
    
    // Gaming Apps
    'PUBG Mobile': 'com.tencent.ig',
    'Free Fire': 'com.dts.freefireth',
    'Mobile Legends': 'com.mobile.legends',
    'Clash of Clans': 'com.supercell.clashofclans',
    'Clash Royale': 'com.supercell.clashroyale',
  };

  /// Dapatkan package name dari nama aplikasi
  static String? getPackageName(String appName) {
    return _packageMap[appName];
  }

  /// Dapatkan semua nama aplikasi yang didukung
  static List<String> getSupportedApps() {
    return _packageMap.keys.toList();
  }

  /// Cek apakah aplikasi didukung
  static bool isSupported(String appName) {
    return _packageMap.containsKey(appName);
  }
}

