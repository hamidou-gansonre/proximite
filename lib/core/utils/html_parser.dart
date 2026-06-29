class HtmlParser {
  /// Nettoie les chaînes de caractères contenant des balises HTML renvoyées par Google Maps API
  /// pour les rendre lisibles par le moteur Text-To-Speech (TTS).
  static String cleanInstruction(String htmlInput) {
    if (htmlInput.isEmpty) return "";

    // 1. Supprime toutes les balises HTML (ex: <b>, </div>, <div ...>)
    // La regex cherche un '<', suivi de n'importe quel caractère sauf '>', et se termine par '>'

    final RegExp expression = RegExp(
      r'<[^>]*>',
      multiLine: true,
      caseSensitive: true,
    );
    String cleanedText = htmlInput.replaceAll(expression, '');

    // 2. Remplace les entités HTML courantes par du texte brut lisible ou des espaces
    cleanedText = cleanedText
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', 'et')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // 3. Nettoie les espaces multiples consécutifs pour une diction fluide du TTS
    final RegExp spaceExpression = RegExp(r'\s+');
    cleanedText = cleanedText.replaceAll(spaceExpression, '').trim();

    return cleanedText;
  }
}
