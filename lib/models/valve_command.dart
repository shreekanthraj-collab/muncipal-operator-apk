class ValveCommand {
  final String valveId;
  final String command;
  final int value;

  const ValveCommand({
    required this.valveId,
    required this.command,
    this.value = 0,
  });

  Map<String, dynamic> toJson() => {
        'valve_id': valveId,
        'command': command,
        'value': value,
      };
}
