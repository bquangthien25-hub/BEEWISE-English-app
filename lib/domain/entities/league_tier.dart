/// Hạng giải đấu theo XP (Đồng → Cao thủ).
enum LeagueTier {
  bronze,
  gold,
  platinum,
  diamond,
  master,
}

extension LeagueTierX on LeagueTier {
  String get labelVi {
    switch (this) {
      case LeagueTier.bronze:
        return 'Đồng';
      case LeagueTier.gold:
        return 'Vàng';
      case LeagueTier.platinum:
        return 'Bạch kim';
      case LeagueTier.diamond:
        return 'Kim cương';
      case LeagueTier.master:
        return 'Cao thủ';
    }
  }

  int get minXp {
    switch (this) {
      case LeagueTier.bronze:
        return 0;
      case LeagueTier.gold:
        return 500;
      case LeagueTier.platinum:
        return 1500;
      case LeagueTier.diamond:
        return 3000;
      case LeagueTier.master:
        return 5000;
    }
  }
}

LeagueTier leagueTierFromXp(int xp) {
  if (xp >= LeagueTier.master.minXp) return LeagueTier.master;
  if (xp >= LeagueTier.diamond.minXp) return LeagueTier.diamond;
  if (xp >= LeagueTier.platinum.minXp) return LeagueTier.platinum;
  if (xp >= LeagueTier.gold.minXp) return LeagueTier.gold;
  return LeagueTier.bronze;
}
