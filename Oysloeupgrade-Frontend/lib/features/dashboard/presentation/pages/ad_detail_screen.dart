import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:oysloe_mobile/core/common/widgets/app_snackbar.dart';
import 'package:oysloe_mobile/core/common/widgets/appbar.dart';
import 'package:oysloe_mobile/core/constants/api.dart';
import 'package:oysloe_mobile/core/di/dependency_injection.dart';
import 'package:oysloe_mobile/core/routes/routes.dart';
import 'package:oysloe_mobile/core/themes/theme.dart';
import 'package:oysloe_mobile/core/themes/typo.dart';
import 'package:oysloe_mobile/core/utils/formatters.dart';
import 'package:oysloe_mobile/core/utils/rating_utils.dart';
import 'package:oysloe_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/product_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/entities/review_entity.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/get_product_detail_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/get_product_reviews_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/mark_product_as_taken_usecase.dart';
import 'package:oysloe_mobile/features/dashboard/domain/usecases/chat_usecases.dart';
import 'package:oysloe_mobile/core/usecase/usecase.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/products/products_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/bloc/categories/categories_cubit.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/ad_card.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/ads_section.dart';
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/rating_overview.dart'
    as rating_widget;
import 'package:oysloe_mobile/features/dashboard/presentation/widgets/reviews_bottom_sheet.dart'
    as reviews_widget;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class AdDetailScreen extends StatefulWidget {
  final String? adId;
  final AdDealType? adType;
  final String? imageUrl;
  final String? title;
  final String? location;
  final List<String>? prices;
  final ProductEntity? product;

  const AdDetailScreen({
    super.key,
    this.adId,
    this.adType,
    this.imageUrl,
    this.title,
    this.location,
    this.prices,
    this.product,
  });

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _CarouselButton extends StatelessWidget {
  const _CarouselButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  _AdDetailScreenState()
      : _getProductDetailUseCase = sl<GetProductDetailUseCase>(),
        _getProductReviewsUseCase = sl<GetProductReviewsUseCase>(),
        _markProductAsTakenUseCase = sl<MarkProductAsTakenUseCase>(),
        _getOrCreateChatRoomIdUseCase = sl<GetOrCreateChatRoomIdUseCase>(),
        _sendChatMessageUseCase = sl<SendChatMessageUseCase>();

  bool _isExpanded = false;
  late final PageController _imagePageController;
  int _currentImageIndex = 0;
  static final CurrencyFormatter _currencyFormatter = CurrencyFormatter.ghana;
  final TextEditingController _chatController = TextEditingController();
  // Seller cards scroller
  final ScrollController _cardsController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;
  final List<String> _sellerAdImages = const [
    'assets/images/ad1.jpg',
    'assets/images/ad2.jpg',
    'assets/images/ad3.jpg',
    'assets/images/ad4.jpg',
    'assets/images/ad5.jpg',
  ];
  final GetProductDetailUseCase _getProductDetailUseCase;
  final GetProductReviewsUseCase _getProductReviewsUseCase;
  final MarkProductAsTakenUseCase _markProductAsTakenUseCase;
  final GetOrCreateChatRoomIdUseCase _getOrCreateChatRoomIdUseCase;
  final SendChatMessageUseCase _sendChatMessageUseCase;
  bool _isSendingMessage = false;

  ProductEntity? _productOverride;
  bool _isRefreshing = false;
  List<ReviewEntity> _reviews = <ReviewEntity>[];
  RatingSummary _ratingSummary = RatingSummary.empty;
  bool _isReviewsLoading = false;
  bool _isMarkingAsTaken = false;
  String? _currentUserNameKey;
  String? _currentUserEmailKey;
  String? _currentUserId;

  ProductEntity? get _product => _productOverride ?? widget.product;

  // AdDealType get _dealType {
  //   if (widget.adType != null) return widget.adType!;
  //   final String rawType = _product?.type.trim().toLowerCase() ?? '';
  //   switch (rawType) {
  //     case 'rent':
  //       return AdDealType.rent;
  //     case 'high_purchase':
  //     case 'hire_purchase':
  //     case 'hire-purchase':
  //       return AdDealType.highPurchase;
  //     default:
  //       return AdDealType.sale;
  //   }
  // }

  List<String> get _galleryImages {
    final Set<String> urls = <String>{};

    void addUrl(String? candidate) {
      final String? normalized = _normalizeImageUrl(candidate);
      if (normalized != null) {
        urls.add(normalized);
      }
    }

    final ProductEntity? product = _product;
    if (product != null) {
      addUrl(product.image);
      for (final String image in product.images) {
        addUrl(image);
      }
    } else {
      addUrl(widget.imageUrl);
    }

    if (urls.isEmpty) {
      addUrl(widget.imageUrl);
    }

    return urls.toList(growable: false);
  }

  List<String> get _priceLabels {
    if (widget.prices != null && widget.prices!.isNotEmpty) {
      return widget.prices!;
    }

    final ProductEntity? product = _product;
    final String price = product?.price.trim() ?? '';
    if (price.isEmpty) return const <String>[];

    return <String>[_currencyFormatter.formatRaw(price)];
  }

  String get _resolvedTitle => widget.title ?? _product?.name ?? 'Ad details';

  String get _resolvedLocation {
    final String? extraLocation = widget.location?.trim();
    if (extraLocation != null && extraLocation.isNotEmpty) {
      return extraLocation;
    }
    final ProductLocation? productLocation = _product?.location;
    return productLocation?.label ?? 'Accra, Ghana';
  }

  String get _resolvedDescription => _product?.description.trim() ?? '';

  bool get _isAdTaken => _product?.isTaken ?? false;

  // Color _getAdTypeColor() => switch (_dealType) {
  //       AdDealType.rent => const Color(0xFF00FFF2),
  //       AdDealType.sale => const Color(0xFFFF6B6B),
  //       AdDealType.highPurchase => const Color(0xFF74FFA7),
  //     };

  List<Map<String, String>> _getFeatures() {
    final ProductEntity? product = _product;
    if (product == null || product.productFeatures.isEmpty) {
      return const <Map<String, String>>[];
    }

    return product.productFeatures.map((String feature) {
      final int separator = feature.indexOf(':');
      if (separator == -1) {
        final String label = feature.trim();
        return <String, String>{'label': label, 'value': ''};
      }

      final String label = feature.substring(0, separator).trim();
      final String value = feature.substring(separator + 1).trim();
      return <String, String>{'label': label, 'value': value};
    }).toList();
  }

  String? _normalizeImageUrl(String? raw) {
    if (raw == null) return null;
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    
    // If it's already a full URL, validate it
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.hasScheme && uri.hasAuthority) {
        return trimmed;
      }
      // Invalid URL, return null to show placeholder
      return null;
    }

    // Build relative URL
    try {
      final Uri baseUri = Uri.parse(AppStrings.baseUrl);
      final String origin = '${baseUri.scheme}://${baseUri.host}';
      final String fullUrl = trimmed.startsWith('/') 
          ? '$origin$trimmed' 
          : '$origin/$trimmed';
      
      // Validate the constructed URL
      final uri = Uri.tryParse(fullUrl);
      if (uri != null && uri.hasScheme && uri.hasAuthority) {
        return fullUrl;
      }
    } catch (e) {
      // If URL construction fails, return null
    }
    
    return null;
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return SizedBox(
        height: 250,
        child: Shimmer.fromColors(
          baseColor: AppColors.grayE4,
          highlightColor: AppColors.white,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.grayE4,
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imagePageController,
            onPageChanged: (int index) => setState(() {
              _currentImageIndex = index;
            }),
            itemCount: images.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildImageItem(images[index]);
            },
          ),
          if (images.length > 1 && _currentImageIndex > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: _CarouselButton(
                icon: Icons.chevron_left,
                onTap: () {
                  final int previous =
                      (_currentImageIndex - 1).clamp(0, images.length - 1);
                  if (previous != _currentImageIndex) {
                    _imagePageController.animateToPage(
                      previous,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                    setState(() {
                      _currentImageIndex = previous;
                    });
                  }
                },
              ),
            ),
          if (images.length > 1 && _currentImageIndex < images.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: _CarouselButton(
                icon: Icons.chevron_right,
                onTap: () {
                  final int next =
                      (_currentImageIndex + 1).clamp(0, images.length - 1);
                  if (next != _currentImageIndex) {
                    _imagePageController.animateToPage(
                      next,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                    setState(() {
                      _currentImageIndex = next;
                    });
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageItem(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    // Validate URL before using it
    if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
      // Try to parse the URL to validate it
      final uri = Uri.tryParse(trimmedUrl);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        // Invalid URL, show placeholder
        return _buildImagePlaceholder();
      }
      
      return Image.network(
        uri.toString(),
        fit: BoxFit.cover,
        headers: _imageHeaders(),
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: AppColors.grayE4,
            highlightColor: AppColors.white,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColors.grayE4,
            ),
          );
        },
      );
    }

    return Image.asset(
      trimmedUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
    );
  }

  Map<String, String>? _imageHeaders() {
    if (!sl.isRegistered<Dio>()) return null;
    final Map<String, dynamic> rawHeaders = sl<Dio>().options.headers;
    if (rawHeaders.isEmpty) return null;
    final Map<String, String> headers = <String, String>{};
    rawHeaders.forEach((key, value) {
      if (value != null) {
        headers[key.toString()] = value.toString();
      }
    });
    return headers.isEmpty ? null : headers;
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.grayE4,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.gray8B959E,
          size: 28.sp,
        ),
      ),
    );
  }

  List<String> _getSafetyTips() {
    return [
      'Check the item carefully and ask relevant questions.',
      'Always make sure to make good tenancy agreement.',
      'Do not make any payment in advance before visiting.',
      'Report any ad or user seems fake, misleading, right away.',
      'Be sure you’re dealing with the property owner for safety.',
    ];
  }

  List<String> _quickChatSuggestions() {
    return [
      'Is this original?',
      'Do you have delivery?',
      'Can you confirm the condition?',
      'Do you have delivery?'
    ];
  }

  Future<void> _showReviewsBottomSheet(int initialFilter) async {

    final RatingSummary summary = _ratingSummary;
  final List<reviews_widget.ReviewComment> reviewComments =
    _buildReviewComments();
    final List<reviews_widget.RatingBreakdown> breakdown =
        _buildBottomSheetBreakdown(summary);
    final int? productId = _product?.id ?? int.tryParse(widget.adId ?? '');

    final bool? shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) => reviews_widget.ReviewsBottomSheet(
        rating: summary.average,
        reviewCount: summary.totalReviews,
        initialFilter: initialFilter,
        ratingBreakdown: breakdown,
        reviews: reviewComments,
        productId: productId ?? 0,
      ),
    );

    if (shouldRefresh == true) {
      await _refreshReviews();
    }
  }

  List<reviews_widget.ReviewComment> _buildReviewComments() {
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    return _reviews.map((ReviewEntity review) {
      final String? avatar =
          review.userAvatar.trim().isEmpty ? null : review.userAvatar.trim();
      final DateTime createdAt = review.createdAt;
      final String dateLabel = createdAt.millisecondsSinceEpoch == 0
          ? '--'
          : formatter.format(createdAt);
      final String comment = review.comment.trim();
      final bool isMine = _isCurrentUsersReview(review);
      final String displayName = isMine ? 'Me' : review.userName;

      return reviews_widget.ReviewComment(
        id: review.id,
        userName: displayName,
        userImage: avatar,
        rating: review.rating,
        comment: comment.isNotEmpty ? comment : 'No comment provided.',
        date: dateLabel,
        rawComment: comment,
        canEdit: isMine,
      );
    }).toList();
  }

  bool _isCurrentUsersReview(ReviewEntity review) {
    final String? reviewIdKey = _normalizeIdentifier(review.userId);
    if (_currentUserId != null &&
        reviewIdKey != null &&
        reviewIdKey == _currentUserId) {
      return true;
    }

    final String? reviewEmailKey = _normalizeIdentifier(review.userEmail);
    if (_currentUserEmailKey != null &&
        reviewEmailKey != null &&
        reviewEmailKey == _currentUserEmailKey) {
      return true;
    }

    final String? normalizedReviewName =
        _normalizeIdentifier(review.userName);
    if (_currentUserNameKey != null &&
        normalizedReviewName != null &&
        normalizedReviewName == _currentUserNameKey) {
      return true;
    }

    return false;
  }

  String? _normalizeIdentifier(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim().toLowerCase();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<reviews_widget.RatingBreakdown> _buildBottomSheetBreakdown(
      RatingSummary summary) {
    return List<reviews_widget.RatingBreakdown>.generate(5, (int index) {
      final int stars = 5 - index;
      return reviews_widget.RatingBreakdown(
        stars: stars,
        percentage: summary.percentageFor(stars),
      );
    });
  }

  List<rating_widget.RatingBreakdown> _buildOverviewBreakdown(
      RatingSummary summary) {
    return List<rating_widget.RatingBreakdown>.generate(5, (int index) {
      final int stars = 5 - index;
      return rating_widget.RatingBreakdown(
        stars: stars,
        percentage: summary.percentageFor(stars),
      );
    });
  }

  Widget _actionChip({
    required String label,
    String? svgAsset,
    IconData? icon,
    VoidCallback? onTap,
    bool enabled = true,
    bool isLoading = false,
  }) {
    final bool canTap = enabled && !isLoading && onTap != null;
    return InkWell(
      onTap: canTap ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.grayF9.withValues(alpha: enabled ? 1 : 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (svgAsset != null)
              SvgPicture.asset(svgAsset, width: 14, height: 14)
            else if (icon != null)
              Icon(icon, size: 14, color: Colors.black87),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.bodySmall
                  .copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: AppColors.blueGray374957
                          .withValues(alpha: enabled ? 1 : 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return InkWell(
      onTap: () {
        _chatController.text = text;
        _chatController.selection =
            TextSelection.collapsed(offset: text.length);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.grayF9,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: AppTypography.bodySmall,
        ),
      ),
    );
  }

  Future<void> _handleSendQuickChatMessage() async {
    final String messageText = _chatController.text.trim();
    if (messageText.isEmpty || _isSendingMessage) return;

    final ProductEntity? product = _product;
    final int? productId = product?.id ?? int.tryParse(widget.adId ?? '');
    if (productId == null) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Unable to start a chat. Please try again.',
        );
      }
      return;
    }

    setState(() {
      _isSendingMessage = true;
    });

    // Step 1: Get or create chatroom ID
    final chatRoomIdResult = await _getOrCreateChatRoomIdUseCase(
      GetOrCreateChatRoomIdParams(productId: productId),
    );

    if (!mounted) return;

    chatRoomIdResult.fold(
      (failure) {
        setState(() {
          _isSendingMessage = false;
        });
        showErrorSnackBar(
          context,
          failure.message.isNotEmpty
              ? failure.message
              : 'Unable to start a chat. Please try again.',
        );
      },
      (chatRoomId) async {
        // Step 2: Send the message
        final sendResult = await _sendChatMessageUseCase(
          SendChatMessageParams(
            chatRoomId: chatRoomId,
            text: messageText,
          ),
        );

        if (!mounted) return;

        setState(() {
          _isSendingMessage = false;
        });

        sendResult.fold(
          (failure) {
            showErrorSnackBar(
              context,
              failure.message.isNotEmpty
                  ? failure.message
                  : 'Unable to send message. Please try again.',
            );
          },
          (_) {
            // Success! Show confirmation and clear input
            _chatController.clear();
            showSuccessSnackBar(
              context,
              'Chat with seller created! You can continue the conversation in your inbox.',
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _productOverride = widget.product;
    _imagePageController = PageController();
    _cardsController.addListener(() {
      if (!_cardsController.hasClients) return;
      final max = _cardsController.position.maxScrollExtent;
      final offset = _cardsController.offset;
      final canLeft = offset > 0;
      final canRight = offset < max;
      if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
        setState(() {
          _canScrollLeft = canLeft;
          _canScrollRight = canRight;
        });
      }
    });

    if (_productOverride == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshProduct();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshReviews();
    });

    _hydrateCurrentUser();
  }

  void _scrollCards(bool forward) {
    if (!_cardsController.hasClients) return;
    final double cardWidth = 28.w;
    const double spacing = 12.0;
    final double delta = cardWidth + spacing;
    final target = forward
        ? _cardsController.offset + delta
        : _cardsController.offset - delta;
    final clamped = target.clamp(
      0.0,
      _cardsController.position.maxScrollExtent,
    );
    _cardsController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _refreshProduct() async {
    if (_isRefreshing) return;
    final ProductEntity? current = _product;
    final int? productId = current?.id ?? int.tryParse(widget.adId ?? '');

    if (productId == null) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Unable to refresh this ad right now.',
        );
      }
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    final result = await _getProductDetailUseCase(
      GetProductDetailParams(id: productId),
    );

    if (!mounted) {
      return;
    }

    ProductEntity? refreshedProduct;

    result.fold(
      (failure) {
        final String message = failure.message.isNotEmpty
            ? failure.message
            : 'Unable to refresh this ad right now.';
        showErrorSnackBar(context, message);
      },
      (product) => refreshedProduct = product,
    );

    if (refreshedProduct != null) {
      setState(() {
        _productOverride = refreshedProduct;
        _currentImageIndex = 0;
      });

      if (_imagePageController.hasClients) {
        _imagePageController.jumpToPage(0);
      }

      await _refreshReviews();
    }

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _handleMarkAdAsTaken() async {
    final ProductEntity? product = _product;
    if (product == null || _isMarkingAsTaken) {
      if (product == null && mounted) {
        showErrorSnackBar(
          context,
          'Unable to mark this ad as taken right now.',
        );
      }
      return;
    }

    setState(() {
      _isMarkingAsTaken = true;
    });

    final result = await _markProductAsTakenUseCase(
      MarkProductAsTakenParams(productId: product.id),
    );

    if (!mounted) return;

    result.fold(
      (failure) => showErrorSnackBar(context, failure.message),
      (updatedProduct) {
        setState(() {
          _productOverride = updatedProduct;
        });
        showSuccessSnackBar(context, 'Ad marked as taken');
      },
    );

    if (!mounted) return;
    setState(() {
      _isMarkingAsTaken = false;
    });
  }

  Future<void> _refreshReviews() async {
    if (_isReviewsLoading) return;
    final ProductEntity? current = _product;
    final int? productId = current?.id ?? int.tryParse(widget.adId ?? '');

    if (productId == null) {
      return;
    }

    setState(() {
      _isReviewsLoading = true;
    });

    final result = await _getProductReviewsUseCase(
      GetProductReviewsParams(productId: productId),
    );

    if (!mounted) {
      return;
    }

    List<ReviewEntity>? refreshedReviews;
    String? errorMessage;

    result.fold(
      (failure) {
        errorMessage = failure.message.isNotEmpty
            ? failure.message
            : 'Unable to load reviews right now.';
      },
      (reviews) => refreshedReviews = reviews,
    );

    setState(() {
      _isReviewsLoading = false;
      if (refreshedReviews != null) {
        _reviews = refreshedReviews!;
        _ratingSummary = RatingUtils.calculate(refreshedReviews!);
      }
    });

    if (errorMessage != null && _reviews.isEmpty) {
      showErrorSnackBar(context, errorMessage!);
    }
  }

  Future<void> _hydrateCurrentUser() async {
    try {
      final AuthRepository authRepository = sl<AuthRepository>();
      final session = await authRepository.cachedSession();
      if (!mounted) return;
      final user = session?.user;

      final String? normalizedName =
          _normalizeIdentifier(user?.name);
      final String? normalizedEmail =
          _normalizeIdentifier(user?.email);
      final String? normalizedId = _normalizeIdentifier(user?.id);

      if (normalizedName == _currentUserNameKey &&
          normalizedEmail == _currentUserEmailKey &&
          normalizedId == _currentUserId) {
        return;
      }

      setState(() {
        _currentUserNameKey = normalizedName;
        _currentUserEmailKey = normalizedEmail;
        _currentUserId = normalizedId;
      });
    } catch (_) {
      // No-op: session data is optional for reviews rendering.
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _cardsController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> galleryImages = _galleryImages;
    final List<String> priceLabels = _priceLabels;
    final List<Map<String, String>> features = _getFeatures();
    final bool hasMoreThanEightFeatures = features.length > 8;
    final List<Map<String, String>> featuresToShow =
        _isExpanded ? features : features.take(8).toList();
    final String pageIndicator = galleryImages.length > 1
        ? '${_currentImageIndex + 1}/${galleryImages.length}'
        : '';
    final RatingSummary ratingSummary = _ratingSummary;
    final List<rating_widget.RatingBreakdown> overviewBreakdown =
        _buildOverviewBreakdown(ratingSummary);
  // final bool hasReviews = _reviews.isNotEmpty; // no longer used; sheet opens even without reviews

    return Scaffold(
      backgroundColor: AppColors.grayF9,
      appBar: CustomAppBar(
        titleWidget: pageIndicator.isNotEmpty
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pageIndicator,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : const SizedBox.shrink(),
        actions: [
          AppBarAction.svg(
            label: '${_product?.totalReports ?? 0}',
            iconSize: 18,
            onTap: () {
              final int? productId = _product?.id ?? int.tryParse(widget.adId ?? '');
              context.pushNamed(
                AppRouteNames.dashboardReport,
                extra: <String, dynamic>{
                  if (productId != null) 'productId': productId,
                },
              );
            },
            svgAsset: 'assets/icons/flag.svg',
          ),
          AppBarAction.svg(
            label: '${_product?.totalFavourites ?? 0}',
            iconSize: 18,
            onTap: () {},
            svgAsset: 'assets/icons/favorite.svg',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.blueGray374957,
        onRefresh: _refreshProduct,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ad type indicator line
              // Container(
              //   width: double.infinity,
              //   height: 4,
              //   color: _getAdTypeColor(),
              // ),
              _buildImageCarousel(galleryImages),
              // Location, Title and Price container
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/location.svg',
                          width: 10,
                          height: 10,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _resolvedLocation,
                            style: AppTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Title
                    Text(
                      _resolvedTitle,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (priceLabels.isNotEmpty)
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: priceLabels
                            .map(
                              (price) => Text(
                                price,
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            .toList(),
                      )
                    else
                      Text(
                        'Price not provided',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.gray8B959E,
                        ),
                      ),
                  ],
                ),
              ),
              if (_resolvedDescription.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _resolvedDescription,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.blueGray374957,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 3.h),
              // Features Container
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    if (featuresToShow.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No features provided for this ad yet.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gray8B959E,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: featuresToShow.map((feature) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    color: AppColors.blueGray374957,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: '${feature['label']} ',
                                      style: AppTypography.bodySmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blueGray374957),
                                      children: [
                                        TextSpan(
                                          text: feature['value'],
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: AppColors.blueGray374957
                                                .withValues(alpha: 0.85),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    if (!_isExpanded && hasMoreThanEightFeatures)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.grayF9.withValues(alpha: 0.0),
                                AppColors.grayF9.withValues(alpha: 0.8),
                                AppColors.grayF9,
                              ],
                            ),
                          ),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = true;
                                });
                              },
                              icon: Icon(Icons.expand_more,
                                  size: 18, color: Colors.black87),
                              label: Text(
                                'Show all features',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                backgroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              /// [Safety Tips Container]
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety tips',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.grayF9,
                      ),
                      child: Text(
                        'Follow this tips and report anything that feels off',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                    SizedBox(height: 16),
                    ..._getSafetyTips().map((tip) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: AppColors.blueGray374957,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: AppTypography.body.copyWith(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _actionChip(
                                  label: _isAdTaken
                                      ? 'Ad already taken'
                                      : 'Mark Ad as taken',
                                  svgAsset: 'assets/icons/mark_as_taken.svg',
                                  onTap:
                                      _isAdTaken ? null : _handleMarkAdAsTaken,
                                  enabled: !_isAdTaken,
                                  isLoading: _isMarkingAsTaken,
                                ),
                                const SizedBox(width: 12),
                                _actionChip(
                                  label: 'Report Seller',
                                  svgAsset: 'assets/icons/flag.svg',
                                  onTap: () {
                                    final int? productId =
                                        _product?.id ?? int.tryParse(widget.adId ?? '');
                                    context.pushNamed(
                                      AppRouteNames.dashboardReport,
                                      extra: <String, dynamic>{
                                        if (productId != null) 'productId': productId,
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                _actionChip(
                                  label: 'Favorite',
                                  svgAsset: 'assets/icons/unfavorite.svg',
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _actionChip(
                                  label: 'Caller 1',
                                  svgAsset: 'assets/icons/outgoing_call.svg',
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _actionChip(
                                  label: 'Caller 2',
                                  svgAsset: 'assets/icons/outgoing_call.svg',
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _actionChip(
                                  label: 'Make an offer',
                                  svgAsset: 'assets/icons/make_offer.svg',
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      // Quick Chat header
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/quick_chat.svg',
                            width: 15,
                            height: 15,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Chat',
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Quick Chat suggestions
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _quickChatSuggestions()
                            .map(_suggestionChip)
                            .toList(),
                      ),
                      SizedBox(height: 16),
                      // Chat input row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _handleSendQuickChatMessage(),
                              enabled: !_isSendingMessage,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: AppColors.grayBFBF, width: 1.5),
                                ),
                                hintText: 'Start a chat',
                                hintStyle: AppTypography.body,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                filled: true,
                                fillColor: AppColors.white,
                                suffixIcon: _isSendingMessage
                                    ? Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 17,
                                          height: 17,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.blueGray374957,
                                            ),
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: _handleSendQuickChatMessage,
                                        icon: SvgPicture.asset(
                                          'assets/icons/send.svg',
                                          width: 17,
                                          height: 17,
                                        ),
                                      ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.blueGray374957
                                          .withValues(alpha: 0.6),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.blueGray374957
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset('assets/icons/audio.svg',
                                  height: 20, width: 20),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      // Secure chat note
                      Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 18, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Chat is secured',
                                  style: AppTypography.bodySmall
                                      .copyWith(fontSize: 12.sp),
                                ),
                              ),
                              Positioned(
                                top: -3,
                                right: -6,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/lock_on.svg',
                                    height: 14,
                                    width: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 3.w),
                          SvgPicture.asset(
                            'assets/icons/shield.svg',
                            width: 14,
                            height: 14,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              'Always chat here for safety reasons!',
                              style: AppTypography.bodySmall
                                  .copyWith(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
              SizedBox(height: 1.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Elektromart Gh Ltd',
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: AppColors.blueGray374957,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'High Level',
                                      style: AppTypography.labelSmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.grayF9,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Seller Ads',
                            style: AppTypography.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      height: 8.h,
                      child: Stack(
                        children: [
                          ListView.separated(
                            controller: _cardsController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 28, right: 64),
                            itemBuilder: (context, index) {
                              final img = _sellerAdImages[
                                  index % _sellerAdImages.length];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  img,
                                  width: 20.w,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemCount: _sellerAdImages.length,
                          ),
                          if (_canScrollLeft)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () => _scrollCards(false),
                                borderRadius: BorderRadius.circular(28),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.blueGray374957
                                          .withValues(alpha: 0.08),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: const Icon(Icons.chevron_left),
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: _canScrollRight
                                  ? () => _scrollCards(true)
                                  : null,
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.blueGray374957
                                        .withValues(alpha: 0.08),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.chevron_right),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.grayF9,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Avatar with brand logo
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 27,
                                    backgroundImage:
                                        AssetImage('assets/images/man.jpg'),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: -2,
                                    child: Image.asset(
                                      'assets/icons/brand_logo.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jan, 2024',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Color(0xFF646161),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Alexander Kowri',
                                      style: AppTypography.bodySmall.copyWith(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Total ads: 2K',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// [Rating breakdown]
                    SizedBox(height: 1.h),
                    (_isReviewsLoading && _reviews.isEmpty)
                        ? const rating_widget.RatingOverviewShimmer()
                        : rating_widget.RatingOverview(
                            rating: ratingSummary.average,
                            reviewCount: ratingSummary.totalReviews,
                            selectedFilter: 0,
                            ratingBreakdown: overviewBreakdown,
                            onFilterChanged: (filterIndex) {
                              _showReviewsBottomSheet(filterIndex);
                            },
                            onViewReviewsPressed: () => _showReviewsBottomSheet(0),
                          ),
                  ],
                ),
              ),

              /// [Similar Ads]
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.white,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  child: Text(
                    'Similar Ads',
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => sl<CategoriesCubit>()..fetch(),
                      ),
                      BlocProvider(
                        create: (_) => sl<ProductsCubit>()..fetch(),
                      ),
                    ],
                    child: const AdsSection(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
