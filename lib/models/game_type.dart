enum GameType {
  Racing,
  Shooter,
  Flying,
  Farming,
}

extension GameTypeExtension on GameType {
  String get name {
    switch (this) {
      case GameType.Racing: return "Racing";
      case GameType.Shooter: return "Shooter";
      case GameType.Flying: return "Flying";
      case GameType.Farming: return "Farming";
    }
  }
}
