class NavigationState {
  final bool isNavigating;
  final String currentInstruction;
  final String distanceLeft;
  final String timeLeft;
  final int indexNextStep;

  NavigationState({
    this.isNavigating = false,
    this.currentInstruction = "En attente du démarrage..",
    this.distanceLeft = "",
    this.timeLeft = "",
    this.indexNextStep = 0,
  });

  NavigationState copyWith({
    bool? isNavigating,
    String? currentInstruction,
    String? distanceLeft,
    String? timeLeft,
    int? indexcurrentStep,
  }) {
    return NavigationState(
      isNavigating: isNavigating ?? this.isNavigating,
      currentInstruction: currentInstruction ?? this.currentInstruction,
      distanceLeft: distanceLeft ?? this.distanceLeft,
      timeLeft: timeLeft ?? this.timeLeft,
      indexNextStep: indexcurrentStep ?? this.indexNextStep,
    );
  }
}
