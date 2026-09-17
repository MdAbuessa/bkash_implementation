class BkashCredentials {
  final String username;
  final String password;
  final String appKey;
  final String appSecret;
  final bool isSandbox;

  const BkashCredentials({
    this.username = 'sandboxTokenizedUser02',
    this.password = 'sandboxTokenizedUser02@12345',
    this.appKey = '4f6o0cjiki2rfm34kfdadl1eqq',
    this.appSecret = '2is7hdktrekvrbljjh44ll3d9l1dtjo4pasmjvs5vl5qr3fug4b',
    this.isSandbox = true,
  });

  String get baseUrl => isSandbox
      ? 'https://tokenized.sandbox.bka.sh/v1.2.0-beta/tokenized/checkout'
      : 'https://tokenized.pay.bka.sh/v1.2.0-beta/tokenized/checkout';

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'appKey': appKey,
        'appSecret': appSecret,
        'isSandbox': isSandbox,
      };

  factory BkashCredentials.fromJson(Map<String, dynamic> json) {
    return BkashCredentials(
      username: json['username'] ?? 'sandboxTokenizedUser02',
      password: json['password'] ?? 'sandboxTokenizedUser02@12345',
      appKey: json['appKey'] ?? '4f6o0cjiki2rfm34kfdadl1eqq',
      appSecret: json['appSecret'] ?? '2is7hdktrekvrbljjh44ll3d9l1dtjo4pasmjvs5vl5qr3fug4b',
      isSandbox: json['isSandbox'] ?? true,
    );
  }
}
