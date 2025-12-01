import '../../features/dashboard/domain/entities/review_entity.dart';

class RatingSummary {
  const RatingSummary({
    required this.average,
    required this.totalReviews,
    required this.counts,
  });

  final double average;
  final int totalReviews;
  final Map<int, int> counts;

  double percentageFor(int stars) {
    if (totalReviews == 0) return 0;
    final int count = counts[stars] ?? 0;
    return (count / totalReviews) * 100;
  }

  int countFor(int stars) => counts[stars] ?? 0;

  static const RatingSummary empty = RatingSummary(
    average: 0.0,
    totalReviews: 0,
    counts: <int, int>{
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    },
  );
}

class RatingUtils {
  const RatingUtils._();

  static RatingSummary calculate(List<ReviewEntity> reviews) {
    if (reviews.isEmpty) {
      return RatingSummary.empty;
    }

    final Map<int, int> counts = <int, int>{
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };
    int totalScore = 0;

    for (final ReviewEntity review in reviews) {
      final int rating = review.rating.clamp(1, 5);
      counts[rating] = (counts[rating] ?? 0) + 1;
      totalScore += rating;
    }

    final int totalReviews = reviews.length;
    final double averageRaw = totalScore / totalReviews;
    final double average = double.parse(averageRaw.toStringAsFixed(1));

    return RatingSummary(
      average: average,
      totalReviews: totalReviews,
      counts: counts,
    );
  }
}
