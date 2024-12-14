// ignore_for_file: file_names

List<String> generateSearchKeywords(String text) {
  final List<String> keywords = [];
  final String lowerText = text.toLowerCase();

  // Tách theo từ và tạo các đoạn nhỏ
  List<String> words = lowerText.split(' ');
  for (String word in words) {
    for (int i = 1; i <= word.length; i++) {
      keywords.add(word.substring(0, i));
    }
  }

  // Tạo các đoạn nhỏ kết hợp toàn chuỗi
  for (int i = 1; i <= lowerText.length; i++) {
    keywords.add(lowerText.substring(0, i));
  }

  return keywords.toSet().toList(); // Loại bỏ trùng lặp
}
