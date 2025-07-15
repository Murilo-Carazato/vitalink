// lib/services/models/donation_model.dart
import 'package:flutter/material.dart';
import 'package:vitalink/services/models/blood_center_model.dart';

class DonationModel {
  final int? id;
  final String donationToken;
  final String bloodType;
  final DateTime donationDate;
  final String donationTime;
  final String status;
  final int bloodcenterId;
  final String? donorAgeRange;
  final String? donorGender;
  final bool isFirstTimeDonor;
  final String? medicalNotes;
  final String? staffNotes;
  final bool reminderSent;
  final DateTime? reminderSentAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BloodCenterModel? bloodcenter;

  DonationModel({
    this.id,
    required this.donationToken,
    required this.bloodType,
    required this.donationDate,
    required this.donationTime,
    required this.status,
    required this.bloodcenterId,
    this.donorAgeRange,
    this.donorGender,
    required this.isFirstTimeDonor,
    this.medicalNotes,
    this.staffNotes,
    this.reminderSent = false,
    this.reminderSentAt,
    this.createdAt,
    this.updatedAt,
    this.bloodcenter,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as int?,
      donationToken: json['donation_token'] as String? ?? '',
      bloodType: json['blood_type'] as String? ?? '',
      donationDate: DateTime.parse(json['donation_date'] as String),
      donationTime: json['donation_time'] as String? ?? '',
      status: json['status'] as String? ?? '',
      bloodcenterId: json['bloodcenter_id'] is int ? json['bloodcenter_id'] as int : int.parse(json['bloodcenter_id'].toString()),
      donorAgeRange: json['donor_age_range'] as String?,
      donorGender: json['donor_gender'] as String?,
      isFirstTimeDonor: json['is_first_time_donor'] is bool ? json['is_first_time_donor'] : (json['is_first_time_donor'] == 1),
      medicalNotes: json['medical_notes'] as String?,
      staffNotes: json['staff_notes'] as String?,
      reminderSent: json['reminder_sent'] == true || json['reminder_sent'] == 1,
      reminderSentAt: json['reminder_sent_at'] != null ? DateTime.parse(json['reminder_sent_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      bloodcenter: json['bloodcenter'] != null ? BloodCenterModel.fromMap(json['bloodcenter'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_token': donationToken,
      'blood_type': bloodType,
      'donation_date': donationDate.toIso8601String(),
      'donation_time': donationTime,
      'status': status,
      'bloodcenter_id': bloodcenterId,
      'donor_age_range': donorAgeRange,
      'donor_gender': donorGender,
      'is_first_time_donor': isFirstTimeDonor,
      'medical_notes': medicalNotes,
      'staff_notes': staffNotes,
      'reminder_sent': reminderSent,
      'reminder_sent_at': reminderSentAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'bloodcenter': bloodcenter?.toMap(),
    };
  }

  // Métodos de conveniência
  bool get canBeCompleted => ['scheduled', 'confirmed'].contains(status);

  bool get canBeEdited => ['scheduled', 'confirmed'].contains(status);

  bool get canBeCancelled => ['scheduled', 'confirmed'].contains(status) && donationDate.isAfter(DateTime.now());

  String get statusDisplayName {
    switch (status) {
      case 'scheduled':
        return 'Agendado';
      case 'confirmed':
        return 'Confirmado';
      case 'completed':
        return 'Concluído';
      case 'cancelled':
        return 'Cancelado';
      case 'no_show':
        return 'Não compareceu';
      default:
        return 'Desconhecido';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'scheduled':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'scheduled':
        return Icons.schedule;
      case 'confirmed':
        return Icons.thumb_up_alt;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel;
      case 'no_show':
        return Icons.person_off;
      default:
        return Icons.info;
    }
  }

  DonationModel copyWith({
    int? id,
    String? donationToken,
    String? bloodType,
    DateTime? donationDate,
    String? donationTime,
    String? status,
    int? bloodcenterId,
    String? donorAgeRange,
    String? donorGender,
    bool? isFirstTimeDonor,
    String? medicalNotes,
    String? staffNotes,
    bool? reminderSent,
    DateTime? reminderSentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    BloodCenterModel? bloodcenter,
  }) {
    return DonationModel(
      id: id ?? this.id,
      donationToken: donationToken ?? this.donationToken,
      bloodType: bloodType ?? this.bloodType,
      donationDate: donationDate ?? this.donationDate,
      donationTime: donationTime ?? this.donationTime,
      status: status ?? this.status,
      bloodcenterId: bloodcenterId ?? this.bloodcenterId,
      donorAgeRange: donorAgeRange ?? this.donorAgeRange,
      donorGender: donorGender ?? this.donorGender,
      isFirstTimeDonor: isFirstTimeDonor ?? this.isFirstTimeDonor,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      staffNotes: staffNotes ?? this.staffNotes,
      reminderSent: reminderSent ?? this.reminderSent,
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bloodcenter: bloodcenter ?? this.bloodcenter,
    );
  }
}
