class ApiErrorHandler {
  static String _lastError = '';

  static String get lastError => _lastError;

  static void setError(String error) {
    _lastError = error;
  }

  static void clearError() {
    _lastError = '';
  }

  static String extractErrorMessage(String response) {
    try {
      // Try to extract error from JSON response format:
      // {"message":{"error":["User doesn't exists!"]},"data":[],"type":"error"}
      if (response.contains('"error"')) {
        final startIndex = response.indexOf('"error"');
        final bracketIndex = response.indexOf('[', startIndex);
        final quoteIndex = response.indexOf('"', bracketIndex);
        final endQuoteIndex = response.indexOf('"', quoteIndex + 1);
        if (quoteIndex > 0 && endQuoteIndex > quoteIndex) {
          return response.substring(quoteIndex + 1, endQuoteIndex);
        }
      }
      // Fallback to the whole response
      return response;
    } catch (e) {
      return response;
    }
  }
}
