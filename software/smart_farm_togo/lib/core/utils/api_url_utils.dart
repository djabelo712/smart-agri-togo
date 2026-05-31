/// Normalise l'URL de base FastAPI (sans slash final).
String normalizeApiBaseUrl(String url) {
  var u = url.trim();
  if (u.isEmpty) return u;
  if (!u.startsWith('http://') && !u.startsWith('https://')) {
    u = 'https://$u';
  }
  while (u.endsWith('/')) {
    u = u.substring(0, u.length - 1);
  }
  return u;
}
