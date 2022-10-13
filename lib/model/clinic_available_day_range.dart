import 'clinic_available_time_range_with_document_id.dart';

class ClinicAvailableDayRange {
  int dayNumber;
  String? dayName;
  Set<ClinicAvailableTimeRangeWithDocumentId>?
      clinicAvailableTimeRangeWithDocumentId;

  ClinicAvailableDayRange(this.dayNumber, this.dayName,
      this.clinicAvailableTimeRangeWithDocumentId);
}
