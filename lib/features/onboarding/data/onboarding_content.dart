import '../domain/entities/onboarding_page.dart';

abstract final class OnboardingContent {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Porositë vijnë direkt te ti',
      subtitle:
          'Prano dhe menaxho porositë shpejt, qartë dhe pa komplikime.',
      illustration: OnboardingIllustrationType.orderReceived,
      animation: OnboardingAnimationStyle.fadeSlide,
    ),
    OnboardingPage(
      title: 'Produktet gjithmonë në fokus',
      subtitle:
          'Shfaq produktet me pamje të pastër, kategori të qarta dhe eksperiencë premium.',
      illustration: OnboardingIllustrationType.productShowcase,
      animation: OnboardingAnimationStyle.staggeredEntrance,
      features: [
        'Përzgjedhje premium',
        'Kategori të qarta',
        'Eksperiencë e besueshme',
      ],
    ),
    OnboardingPage(
      title: 'Kontroll i lehtë i çdo porosie',
      subtitle:
          'Shiko detajet e porosisë para përgatitjes dhe konfirmimit.',
      illustration: OnboardingIllustrationType.orderReview,
      animation: OnboardingAnimationStyle.scaleFade,
    ),
    OnboardingPage(
      title: 'Nga porosia te dorëzimi',
      subtitle:
          'Përgatit, konfirmo dhe përmbyll porositë me një rrjedhë të thjeshtë.',
      illustration: OnboardingIllustrationType.deliveryReady,
      animation: OnboardingAnimationStyle.slideUp,
    ),
  ];
}
