import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:vitalink/services/models/donation_model.dart';

class CalendarHelper {
  static void addDonationToCalendar(DonationModel donation) {
    // Parse time string 'HH:mm'
    final timeParts = donation.donationTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final startDate = DateTime(
      donation.donationDate.year,
      donation.donationDate.month,
      donation.donationDate.day,
      hour,
      minute,
    );

    final event = Event(
      title: 'Doação de Sangue - Vitalink',
      description:
          'Doação de sangue agendada no hemocentro ${donation.bloodcenter?.name}. Não se esqueça de levar um documento com foto e se alimentar bem antes!',
      location: donation.bloodcenter?.address ?? 'Endereço não informado',
      startDate: startDate,
      endDate: startDate.add(const Duration(hours: 1)), // Assumes 1 hour duration
      allDay: false,
    );
    Add2Calendar.addEvent2Cal(event);
  }
}
