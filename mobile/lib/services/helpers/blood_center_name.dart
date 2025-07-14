class BloodCenterName{
  String name;
  BloodCenterName(this.name);

  List<String> formatName(){
    List<String> parts = name.split(' - ');
    return parts;
  }
}