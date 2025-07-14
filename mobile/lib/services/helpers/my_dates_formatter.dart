import 'package:intl/intl.dart';

class MyDates {
  final String? birthDate;
  final String? createdAt;
  final DateTime? date;
  MyDates({this.birthDate, this.createdAt, this.date});

  Map<String, String> getNameOfMonth = {
    '01': 'Janeiro',
    '02': 'Fevereiro',
    '03': 'Março',
    '04': 'Abril',
    '05': 'Maio',
    '06': 'Junho',
    '07': 'Julho',
    '08': 'Agosto',
    '09': 'Setembro',
    '10': 'Outubro',
    '11': 'Novembro',
    '12': 'Dezembro',
  };

  Map<String, String> getAbreviattedNameOfMonth = {
    '01': 'Jan',
    '02': 'Fev',
    '03': 'Mar',
    '04': 'Abr',
    '05': 'Mai',
    '06': 'Jun',
    '07': 'Jul',
    '08': 'Ago',
    '09': 'Set',
    '10': 'Out',
    '11': 'Nov',
    '12': 'Dez',
  };

  dynamic get calcularIdade {
    if (birthDate == null || birthDate!.trim().isEmpty) {
      return "?"; // idade desconhecida
    }
    try {
      final d = DateFormat('dd/MM/yyyy').parse(birthDate!);
      final hoje = DateTime.now();
      int idade = hoje.year - d.year;
      if (hoje.month < d.month || (hoje.month == d.month && hoje.day < d.day)) {
        idade--;
      }
      return idade;
    } catch (_) {
      return -1;
    }
  }

  String get formatDate {
    DateTime dateTime = DateTime.parse(createdAt!);
    if (date != null) {
      dateTime = date!;
    }

    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    String finalDate =
        "${formattedDate.substring(0, 2)} ${getNameOfMonth[formattedDate.substring(3, 5)]} ${formattedDate.substring(6)}";
    return finalDate;
  }
}
