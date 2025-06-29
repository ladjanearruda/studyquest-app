class RecursosOceano {
  final int pressao; // Resistência à pressão das profundezas
  final int oxigenio; // Suprimento de oxigênio
  final int temperatura; // Resistência ao frio das profundezas

  const RecursosOceano({
    required this.pressao,
    required this.oxigenio,
    required this.temperatura,
  });

  RecursosOceano ajustar(
      {int pressaoDelta = 0, int oxigenioDelta = 0, int temperaturaDelta = 0}) {
    return RecursosOceano(
      pressao: (pressao + pressaoDelta).clamp(0, 100),
      oxigenio: (oxigenio + oxigenioDelta).clamp(0, 100),
      temperatura: (temperatura + temperaturaDelta).clamp(0, 100),
    );
  }

  bool get estaVivo => pressao > 0 && oxigenio > 0 && temperatura > 0;
}
