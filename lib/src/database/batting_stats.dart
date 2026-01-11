import 'package:objectbox/objectbox.dart';

@Entity()
class BattingStats {
  @Id()
  int id = 0; // Auto-increment

  /// Batting innings identifier (e.g., I001)
  String batID;

  /// Type of innings (First, Second, SuperOver, etc.)
  String inningsType;

  /// Team & player identifiers
  String teamId;
  String playerId;

  /// Batting stats
  int runs;
  int ballsPlayed;
  int fours;
  int sixes;
  int dotBalls;

  double strikeRate;

  BattingStats({
    required this.batID,
    required this.inningsType,
    required this.teamId,
    required this.playerId,
    this.runs = 0,
    this.ballsPlayed = 0,
    this.fours = 0,
    this.sixes = 0,
    this.dotBalls = 0,
    this.strikeRate = 0.0,
  });

  /// Call after every legal delivery
  void updateStrikeRate() {
    strikeRate =
    ballsPlayed == 0 ? 0.0 : (runs / ballsPlayed) * 100;
  }
}
