enum OnboardingIllustrationType {
  orderReceived,
  productShowcase,
  orderReview,
  deliveryReady,
}

enum OnboardingAnimationStyle {
  fadeSlide,
  staggeredEntrance,
  scaleFade,
  slideUp,
}

class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.animation,
    this.features,
  });

  final String title;
  final String subtitle;
  final OnboardingIllustrationType illustration;
  final OnboardingAnimationStyle animation;
  final List<String>? features;
}
