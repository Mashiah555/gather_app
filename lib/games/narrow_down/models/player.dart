class Player {
  final int id;
  final String name;
  final int teamId;
  int score;

  // Constructor
  Player({
    required this.id,
    required this.name,
    required this.teamId,
    this.score = 0, // Default value
  });
}
