library environment;

class Environment {
  final String _env;
  const Environment._(this._env);
  const Environment.custom(this._env);

  static const Environment prd = Environment._('prd');
  static const Environment dev = Environment._('dev');
  static const Environment unknown = Environment._('unknown');

  @override
  String toString() => _env;

  static Environment tryParse(String val) {
    switch (val) {
      case 'prd':
        return Environment.prd;
      case 'dev':
        return Environment.dev;
      default:
        // ignore: avoid_print
        print('$val is not a valid Environment');
        return Environment.unknown;
    }
  }
}
