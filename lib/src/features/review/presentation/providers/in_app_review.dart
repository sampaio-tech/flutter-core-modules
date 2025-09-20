import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

final inAppReviewProvider =
    Provider<InAppReview>((ref) => InAppReview.instance);
