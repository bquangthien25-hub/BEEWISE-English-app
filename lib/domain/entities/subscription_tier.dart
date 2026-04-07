enum SubscriptionTier {
  basic,
  premium,
}

extension SubscriptionTierX on SubscriptionTier {
  String get labelVi {
    switch (this) {
      case SubscriptionTier.basic:
        return 'Basic';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }
}
