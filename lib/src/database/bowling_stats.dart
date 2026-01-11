import 'package:objectbox/objectbox.dart';

@Entity()
class BowlingStats {
  @Id()
  int id = 0; // Auto-increment

  /// Bowling innings identifier (e.g., B001)
  String bowlID;

  /// Type of innings (First, Second, SuperOver, etc.)
  String inningsType;

  /// Team & player identifiers
  String teamId;
  String playerId;

  /// Bowling stats
  double oversBowled;
  int runsGiven;
  int wicketsConceded;
  int extras;
  int maidens;

  double economyRate;

  BowlingStats({
    required this.bowlID,
    required this.inningsType,
    this.teamId = 'T001',
    this.playerId = 'P001',
    this.oversBowled = 0.0,
    this.runsGiven = 0,
    this.wicketsConceded = 0,
    this.extras = 0,
    this.maidens = 0,
    this.economyRate = 0.0,
  });

  /// Call after each delivery / over
  void updateEconomy() {
    economyRate =
    oversBowled == 0 ? 0.0 : runsGiven / oversBowled;
  }
}
