class EndSessionPayloadDto {
  final String contentCovered;
  final String? homeworkAssigned;
  final String? attitudeRating;
  final String? workEffortRating;
  final String? observations;

  const EndSessionPayloadDto({
    required this.contentCovered,
    this.homeworkAssigned,
    this.attitudeRating,
    this.workEffortRating,
    this.observations,
  });

  Map<String, dynamic> toJson() {
    return {
      'contentCovered': contentCovered,
      if (homeworkAssigned != null && homeworkAssigned!.isNotEmpty)
        'homeworkAssigned': homeworkAssigned,
      if (attitudeRating != null) 'attitudeRating': attitudeRating,
      if (workEffortRating != null) 'workEffortRating': workEffortRating,
      if (observations != null && observations!.isNotEmpty)
        'observations': observations,
    };
  }
}
