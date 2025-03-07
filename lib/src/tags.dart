List<String> parseTags(String text) {
  if (text == "") {
    return List.empty();
  }
  var tags =List<String>.empty(growable: true);
  for (var el in text.split(",")) {
    if (el.isEmpty) {
      continue;
    }
    var tagValue = el;
    if (el.startsWith("[") || el.endsWith("]")) {
      tagValue = el.replaceAll("[", "").replaceAll("]","");
    }
    tags.add(tagValue.trim());
  }
  return tags;
}