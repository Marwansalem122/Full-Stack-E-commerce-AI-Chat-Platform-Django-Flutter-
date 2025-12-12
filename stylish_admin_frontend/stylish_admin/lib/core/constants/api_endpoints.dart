class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Auth endpoints
  // static const String login = '/api/auth/login/';
  static const String login = '/auth/login/';
  // static const String register = '/api/auth/register/';
  static const String register = '/auth/register/';
  // static const String profile = '/api/auth/profile/';
  static const String profile = '/auth/profile/';
  // static const String passwordReset = '/api/auth/password-reset/';
  static const String passwordReset = '/auth/password-reset/';
  // static const String refreshToken = '/api/auth/token/refresh/';
  static const String refreshToken = '/auth/token/refresh/';
  // static const String validateToken = '/api/auth/token/validate/';
  static const String validateToken = '/auth/token/validate/';
  // static const String logout = '/api/auth/logout/';
  static const String logout = '/auth/logout/';

  // Product management endpoints
  static const String productList = '/api/admin/products/';
  static const String productDetail = '/api/admin/products/{id}/';
  static const String manageProductVariants =
      '/api/admin/products/{id}/manage_variants/';
  static const String productVariants = '/api/admin/products/{id}/variants/';
  static const String distributeStock =
      '/api/admin/products/{id}/distribute_stock/';
  static const String stockAdjustment =
      '/api/admin/products/{id}/stock_adjustment/';

  static const String manageImages = '/api/admin/products/{id}/manage_images';
  static const String deleteImage = '/api/admin/products/{id}/delete_image';
  static const String bulkDelete = '/api/admin/products/bulk_delete/';
  static const String productFilters = '/api/admin/products/filters/';

  static const String categories = '/api/admin/categories/';

  // Chat Endpoints
  static const String chatQuery = '/api/agents/query/query/';
  static const String chatStreamQuery = '/api/agents/query/stream_query/';
  static const String chatIntents = '/api/agents/query/intents/';
  static const String chatSessions = '/api/agents/sessions/';
  static String chatSessionDetail(String sessionId) =>
      '/api/agents/sessions/$sessionId/';
  static String chatSessionMessages(String sessionId) =>
      '/api/agents/sessions/$sessionId/messages';
  static String clearChatSessionMessages(String sessionId) =>
      '/api/agents/sessions/$sessionId/clear_messages';
  static const String chatFeedback = '/api/agents/feedback';
  static const String chatAnalyticsDashboard =
      '/api/agents/analytics/dashboard';
  static const String chatHealthStatus = '/api/agents/health/status';
  static const String chatMetrics = '/api/agents/health/metrics';

  // Helper method
  static String formatUrl(String url, String id) {
    return url.replaceAll('{id}', id);
  }
}
