// This file contains API endpoint constants for the Oysloe Mobile app.
class AppStrings {
  static const String baseUrl = 'https://api.oysloe.com';
  static const String apiBasePath = '$baseUrl/api-v1';

  // Auth
  static const String registerURL = '$apiBasePath/register/';
  static const String loginURL = '$apiBasePath/login/';
  static const String resetPasswordURL = '$apiBasePath/resetpassword/';
  static const String otpURL = '$apiBasePath/verifyotp/';
  static const String otpLoginURL = '$apiBasePath/otplogin/';

  // Profile
  static const String userProfileURL = '$apiBasePath/userprofile/';

  // Catalog
  static const String productsURL = '$apiBasePath/products/';
  static const String categoriesURL = '$apiBasePath/categories/';
  static const String subcategoriesURL = '$apiBasePath/subcategories/';
  static const String featuresURL = '$apiBasePath/features/';
  static const String featureValuesURL = '$apiBasePath/feature-values/';
  static const String productFeaturesURL = '$apiBasePath/product-features/';
  static const String productImagesURL = '$apiBasePath/product-images/';
  static const String relatedProductsURL = '$apiBasePath/products/related/';
  static String productDetailURL(String id) => '$apiBasePath/products/$id/';
  static String markProductAsTakenURL(String id) =>
      '$apiBasePath/products/$id/mark-as-taken/';
  static String confirmMarkProductAsTakenURL(String id) =>
      '$apiBasePath/products/$id/confirm-mark-as-taken/';
  static String setProductStatusURL(String id) =>
      '$apiBasePath/products/$id/set-status/';
  static String productReportURL(String id) =>
      '$apiBasePath/products/$id/report/';
  static String productFavouriteURL(String id) =>
      '$apiBasePath/products/$id/favourite/';
  static const String favouritesURL = '$apiBasePath/products/favourites/';
  static String repostProductURL(String id) =>
      '$apiBasePath/products/$id/repost-ad/';

  // Reviews
  static const String reviewsURL = '$apiBasePath/reviews/';
  static String reviewDetailURL(String reviewId) =>
      '$apiBasePath/reviews/$reviewId/';

  // Alerts
  static const String alertsURL = '$apiBasePath/alerts/';
  static String alertDetailURL(String alertId) =>
      '$apiBasePath/alerts/$alertId/';
  static String alertMarkReadURL(String alertId) =>
      '$apiBasePath/alerts/$alertId/mark-read/';
  static String alertDeleteURL(String alertId) =>
      '$apiBasePath/alerts/$alertId/delete/';

  // Subscriptions
  static const String subscriptionsURL = '$apiBasePath/subscriptions/';
  static const String userSubscriptionsURL = '$apiBasePath/user-subscriptions/';
  static const String paymentsURL = '$apiBasePath/payments/';
  static const String paystackURL = '$apiBasePath/paystack/';

  // Account delete requests
  static const String accountDeleteRequestsURL =
      '$apiBasePath/account-delete-requests/';
  static String accountDeleteRequestDetailURL(String id) =>
      '$apiBasePath/account-delete-requests/$id/';
  static String accountDeleteRequestApproveURL(String id) =>
      '$apiBasePath/account-delete-requests/$id/approve/';
  static String accountDeleteRequestRejectURL(String id) =>
      '$apiBasePath/account-delete-requests/$id/reject/';

  // Chat
  static const String chatRoomIdURL = '$apiBasePath/chatroomid/';
  static const String chatRoomsURL = '$apiBasePath/chatrooms/';
  static String chatRoomDetailURL(String id) => '$apiBasePath/chatrooms/$id/';
  static String chatRoomMarkReadURL(String id) =>
      '$apiBasePath/chatrooms/$id/mark-read/';
  static String chatRoomMessagesURL(String id) =>
      '$apiBasePath/chatrooms/$id/messages/';
  static String chatRoomSendMessageURL(String id) =>
      '$apiBasePath/chatrooms/$id/send/';

  // Feedback
  static const String feedbackURL = '$apiBasePath/feedback/';

  // Referral & Points
  static const String referralURL = '$apiBasePath/referrals/';
  static const String referralTransactionsURL =
      '$apiBasePath/referrals/transactions/';
  static const String redeemCouponURL = '$apiBasePath/referrals/redeem/';

  // Static pages
  static const String privacyPoliciesLatestURL =
      '$apiBasePath/privacy-policies/latest/';
  static const String privacyPoliciesURL = '$apiBasePath/privacy-policies/';
  static const String termsConditionsURL = '$apiBasePath/terms-conditions/';
  static const String termsConditionsLatestURL =
      '$apiBasePath/terms-and-conditions/latest/';
  static const String termsConditionsListURL =
      '$apiBasePath/terms-and-conditions/';

  // Locations
  static const String locationsURL = '$apiBasePath/locations/';

  // TODO: add the remaining endpoints from the schema as they are implemented.
}
