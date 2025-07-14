class UserNameInitial{
  final String name;
  UserNameInitial(this.name);

  String get captureInitials {
  //Separa o nome em partes
  List<String> parts = name.split(' ');

  // Conta a quantidade de partes
  if (parts.length == 1) {
    // Se houver somente um nome, retorne a primeira letra
    return parts[0][0].toUpperCase();
  } else {
    // Se houver mais de um nome, retorne a inicial dos dois primeiros nomes
    return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
  }
}
}