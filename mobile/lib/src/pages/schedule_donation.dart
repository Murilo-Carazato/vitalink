import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/services/stores/blood_center_store.dart';
import 'package:vitalink/services/stores/donation_store.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:provider/provider.dart';

class ScheduleDonationPage extends StatefulWidget {
  static const routeName = '/schedule-donation';

  final DonationStore donationStore;
  final BloodCenterStore bloodCenterStore;
  final UserStore userStore;
  final int? preSelectedBloodcenterId;

  const ScheduleDonationPage({
    super.key,
    required this.donationStore,
    required this.bloodCenterStore,
    required this.userStore,
    this.preSelectedBloodcenterId,
  });

  @override
  State<ScheduleDonationPage> createState() => _ScheduleDonationPageState();
}

class _ScheduleDonationPageState extends State<ScheduleDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _medicalNotesController = TextEditingController();

  int? _selectedBloodcenterId;
  String _selectedBloodType = 'O+';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedAgeRange = '18-25';
  String _selectedGender = 'masculino';
  bool _isFirstTimeDonor = false;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _ageRanges = [
    '18-25',
    '26-35',
    '36-45',
    '46-55',
    '56-65',
    '65+'
  ];
  final List<String> _genders = ['masculino', 'feminino', 'outros'];

  bool _didRunInitialSetup = false;

  @override
  void initState() {
    super.initState();
    // A lógica foi movida para didChangeDependencies para garantir o acesso ao context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didRunInitialSetup) {
      _didRunInitialSetup = true;

      // Adia a execução para depois da fase de build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Extrai o ID do hemocentro dos argumentos da rota de forma robusta
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final preSelectedId = args?['preSelectedBloodcenterId'] as int? ?? widget.preSelectedBloodcenterId;
        
          setState(() {
            _selectedBloodcenterId = preSelectedId;
          });

          // Carrega os dados do usuário
          _loadUserData();
        }
        
        // Carrega a lista completa de hemocentros para o dropdown
        widget.bloodCenterStore.fetchForDropdown();
      });
    }
  }

  void _loadUserData() {
    final user = widget.userStore.state.value.first;

    // Define o tipo sanguíneo do usuário se disponível
    if (user.bloodType != null && user.bloodType!.isNotEmpty) {
      setState(() {
        _selectedBloodType = user.bloodType!;
      });
    }

    // Calcula a faixa etária com base na data de nascimento
    if (user.birthDate != null && user.birthDate!.isNotEmpty) {
      try {
        final birthDate = DateFormat('dd/MM/yyyy').parse(user.birthDate!);
        final age = DateTime.now().year - birthDate.year;

        // Ajusta a faixa etária selecionada
        setState(() {
          if (age >= 18 && age <= 25) {
            _selectedAgeRange = '18-25';
          } else if (age <= 35) {
            _selectedAgeRange = '26-35';
          } else if (age <= 45) {
            _selectedAgeRange = '36-45';
          } else if (age <= 55) {
            _selectedAgeRange = '46-55';
          } else if (age <= 65) {
            _selectedAgeRange = '56-65';
          } else {
            _selectedAgeRange = '65+';
          }
        });
      } catch (e) {
        print('Erro ao calcular idade: $e');
      }
    }
  }

  @override
  void dispose() {
    _medicalNotesController.dispose();
    super.dispose();
  }

  final Map<String, String> _bloodTypeMap = {
    'A+': 'positiveA',
    'A-': 'negativeA',
    'B+': 'positiveB',
    'B-': 'negativeB',
    'AB+': 'positiveAB',
    'AB-': 'negativeAB',
    'O+': 'positiveO',
    'O-': 'negativeO',
  };

  final Map<String, String> _genderMap = {
    'masculino': 'M',
    'feminino': 'F',
    'outros': 'O',
  };

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Dentro do método _scheduleDonation() após o agendamento bem-sucedido:

  Future<void> _scheduleDonation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodcenterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um hemocentro')),
      );
      return;
    }

    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final donation = await widget.donationStore.scheduleDonation(
      bloodType: _bloodTypeMap[_selectedBloodType]!,
      donationDate: _selectedDate,
      donationTime: timeString,
      bloodcenterId: _selectedBloodcenterId!,
      donorAgeRange: _selectedAgeRange,
      donorGender: _genderMap[_selectedGender],
      isFirstTimeDonor: _isFirstTimeDonor,
      medicalNotes: _medicalNotesController.text.isEmpty
          ? ''
          : _medicalNotesController.text,
    );

    if (donation != null) {
      // Força a atualização da próxima doação e do histórico
      await widget.donationStore.fetchNextDonation();
      await widget.donationStore.fetchDonationHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doação agendada com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${widget.donationStore.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final store = Provider.of<DonationStore>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Doação'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seleção de Hemocentro
              Text('Hemocentro', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: widget.bloodCenterStore.dropdownBloodCenters,
                builder: (context, bloodCenters, child) {
                  return DropdownButtonFormField<int>(
                    value: _selectedBloodcenterId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Selecione um hemocentro',
                    ),
                    items: bloodCenters.map((center) {
                      return DropdownMenuItem<int>(
                        value: center.id,
                        child: Text(center.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodcenterId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione um hemocentro';
                      }
                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              // Tipo Sanguíneo
              Text('Tipo Sanguíneo', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _bloodTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Data e Hora
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data', style: textTheme.titleMedium),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.calendar),
                                const SizedBox(width: 8),
                                Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Horário', style: textTheme.titleMedium),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.clock),
                                const SizedBox(width: 8),
                                Text(
                                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Informações Adicionais
              Text('Informações Adicionais', style: textTheme.titleMedium),
              const SizedBox(height: 16),

              // Faixa Etária
              Text('Faixa Etária', style: textTheme.bodyMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAgeRange,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _ageRanges.map((range) {
                  return DropdownMenuItem<String>(
                    value: range,
                    child: Text(range),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAgeRange = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Gênero
              Text('Gênero', style: textTheme.bodyMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _genders.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Primeira vez doando
              CheckboxListTile(
                title: const Text('É a primeira vez doando sangue?'),
                value: _isFirstTimeDonor,
                onChanged: (value) {
                  setState(() {
                    _isFirstTimeDonor = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 16),

              // Observações Médicas
              Text('Observações Médicas (Opcional)',
                  style: textTheme.bodyMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicalNotesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      'Descreva qualquer condição médica relevante...',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Botão de Agendar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: store.isLoading ? null : _scheduleDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: store.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Agendar Doação'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
