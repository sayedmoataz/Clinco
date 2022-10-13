class ClinicAvailableTimeSlot {
  DateTime timeSlot;
  String? timeRangeDocumentId;
  int durationInMinutes;

  ClinicAvailableTimeSlot(
      this.timeSlot, this.timeRangeDocumentId, this.durationInMinutes);

  String get minuteText => (durationInMinutes < 11) ? 'دقائق' : 'دقيقة';
}
