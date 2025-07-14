import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vitalink/services/models/user_model.dart';
import 'package:vitalink/services/stores/user_store.dart';
import 'package:vitalink/src/components/checkbox_profile.dart';
import 'package:vitalink/src/components/rich_text_label.dart';
import 'package:vitalink/src/components/user_header.dart';
import 'package:vitalink/styles.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfilePage extends StatefulWidget {
  final UserStore userStore;
  const ProfilePage({super.key, required this.userStore});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> list = <String>[
    'A+',
    'B+',
    'AB+',
    'O+',
    'A-',
    'B-',
    'AB-',
    'O-'
  ];

  final _profileFormKey = GlobalKey<FormState>(debugLabel: 'Profile');
  TextEditingController nameController = TextEditingController();
  TextEditingController bloodTypeController = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  late bool hasTattoo;
  late bool hasMicropigmentation;
  late bool hasPermanentMakeup;
  late String oldBloodTypeTopic;

  @override
  void initState() {
    var user = widget.userStore.state.value.first;
    oldBloodTypeTopic =
        convertBloodType(user.bloodType!); // Salva o tópico antigo
    subscribeToBloodTypeTopic(user.bloodType!);
    nameController.text = user.name;
    bloodTypeController.text = user.bloodType!;
    dateInput.text = user.birthDate!;
    hasTattoo = user.hasTattoo;
    hasMicropigmentation = user.hasMicropigmentation;
    hasPermanentMakeup = user.hasPermanentMakeup;
    super.initState();
  }

  void subscribeToBloodTypeTopic(String bloodType) {
    final topic = convertBloodType(bloodType);
    if (topic.isNotEmpty) {
      FirebaseMessaging.instance.subscribeToTopic(topic);
    }
  }

  void unsubscribeFromBloodTypeTopic(String bloodType) {
    final topic = convertBloodType(bloodType);
    if (topic.isNotEmpty) {
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
  }

  String convertBloodType(String type) {
    switch (type) {
      case 'A+':
        return 'positiveA';
      case 'A-':
        return 'negativeA';
      case 'B+':
        return 'positiveB';
      case 'B-':
        return 'negativeB';
      case 'AB+':
        return 'positiveAB';
      case 'AB-':
        return 'negativeAB';
      case 'O+':
        return 'positiveO';
      case 'O-':
        return 'negativeO';
      default:
        return '';
    }
  }

  initialDate(String? date) {
    if (date != null && date.isNotEmpty) {
      DateFormat format = DateFormat('dd/MM/yyyy');
      DateTime dateTime = format.parse(date);
      return dateTime;
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    bloodTypeController.dispose();
    dateInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Skeletonizer(
        enabled: widget.userStore.isLoading.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([
                widget.userStore.state,
                widget.userStore.isLoading,
                widget.userStore.erro
              ]),
              builder: (context, child) => UserHeader(user: widget.userStore),
            ),
            Padding(
                padding: EdgeInsets.symmetric(
                    vertical:
                        MediaQuery.sizeOf(context).height * (5.83 / 100) / 2),
                child: const Divider()),
            Text('Atualizar dados de perfil', style: textTheme.titleMedium),
            Form(
              key: _profileFormKey,
              canPop: false,
              onPopInvoked: (didPop) async => false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 29),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      label: RichTextLabel(label: 'Nome'),
                      prefixIcon: Icon(LucideIcons.user2),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 29),
                  DropdownButtonFormField<String>(
                    value: bloodTypeController.text.isNotEmpty
                        ? bloodTypeController.text
                        : null,
                    decoration: const InputDecoration(
                      label: RichTextLabel(label: 'Tipo sanguíneo'),
                      prefixIcon: Icon(LucideIcons.droplet),
                    ),
                    items: list.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        bloodTypeController.text = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tipo sanguíneo é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 29),
                  TextField(
                    controller: dateInput,
                    decoration: const InputDecoration(
                      label: RichTextLabel(label: 'Data de nascimento'),
                      prefixIcon: Icon(LucideIcons.calendar),
                    ),
                    readOnly: true,
                    onTap: () async {
                      // se o campo já tem valor válido, usa-o; senão usa lastDate
                      final now = DateTime.now();
                      final last = DateTime(now.year - 16, now.month, now.day);
                      final first = DateTime(now.year - 69, now.month, now.day);

                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        locale: const Locale('pt', 'BR'),
                        firstDate: first,
                        lastDate: last,
                        initialDate: initialDate(dateInput.text.trim()) ??
                            last, // << ajuste
                      );

                      if (pickedDate != null) {
                        setState(() {
                          dateInput.text =
                              DateFormat('dd/MM/yyyy').format(pickedDate);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 29),
                  CheckBoxProfile(
                    option: hasTattoo,
                    label: 'Possui tatuagens?',
                    onChanged: (option) {
                      setState(() {
                        hasTattoo = option!;
                      });
                    },
                  ),
                  CheckBoxProfile(
                    option: hasMicropigmentation,
                    label: 'Possui micropigmentação?',
                    onChanged: (option) {
                      setState(() {
                        hasMicropigmentation = option!;
                      });
                    },
                  ),
                  CheckBoxProfile(
                    option: hasPermanentMakeup,
                    label: 'Possui maquiagem definitiva?',
                    onChanged: (option) {
                      setState(() {
                        hasPermanentMakeup = option!;
                      });
                    },
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.sizeOf(context).height *
                              (5.83 / 100) /
                              2),
                      child: const Divider()),
                  TextButton.icon(
                    onPressed: () async {
                      if (_profileFormKey.currentState!.validate()) {
                        _profileFormKey.currentState!.save();
                        var instantiatedUser =
                            widget.userStore.state.value.first;
                        var newUser = UserModel(
                          id: instantiatedUser
                              .id, // <-- AQUI: usa o id real (12, 16, etc.)
                          name: nameController.text.trim(),
                          birthDate: dateInput.text.trim(),
                          bloodType: bloodTypeController.text.trim(),
                          hasTattoo: hasTattoo,
                          hasMicropigmentation: hasMicropigmentation,
                          hasPermanentMakeup: hasPermanentMakeup,
                          viewedTutorial: true,
                          email: instantiatedUser.email, // <-- mantenha o email
                          token: instantiatedUser.token, // <-- mantenha o token
                        );
                        if (instantiatedUser == newUser) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar(
                              reason: SnackBarClosedReason.swipe);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Nenhum dado alterado')));
                        } else {
                          // Se mudou o tipo sanguíneo, desinscreve do antigo e inscreve no novo
                          if (instantiatedUser.bloodType != newUser.bloodType) {
                            unsubscribeFromBloodTypeTopic(
                                instantiatedUser.bloodType!);
                            subscribeToBloodTypeTopic(newUser.bloodType!);
                            oldBloodTypeTopic =
                                convertBloodType(newUser.bloodType!);
                          }
                          await widget.userStore
                              .updateUser(newUser: newUser)
                              .whenComplete(
                                () => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Dados alterados com sucesso'),
                                  backgroundColor: Styles.green,
                                )),
                              );
                        }
                      }
                    },
                    label: const Text('Salvar'),
                    icon: const Icon(LucideIcons.save),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

// Botão de logout
                  TextButton.icon(
                    onPressed: () async {
                      // Confirmação
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sair'),
                          content:
                              const Text('Deseja realmente sair da sua conta?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Sair'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await widget.userStore.logout();

                        // Redirecionar para tela de login
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/auth', (route) => false);
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    icon: const Icon(LucideIcons.logOut),
                    label: const Text('Sair da conta'),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
