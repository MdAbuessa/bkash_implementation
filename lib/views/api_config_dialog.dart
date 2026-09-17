import 'package:flutter/material.dart';
import '../models/bkash_credentials.dart';
import '../theme/bkash_theme.dart';

class ApiConfigDialog extends StatefulWidget {
  final BkashCredentials initialCredentials;
  final Function(BkashCredentials) onSave;

  const ApiConfigDialog({
    super.key,
    required this.initialCredentials,
    required this.onSave,
  });

  @override
  State<ApiConfigDialog> createState() => _ApiConfigDialogState();
}

class _ApiConfigDialogState extends State<ApiConfigDialog> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _appKeyController;
  late TextEditingController _appSecretController;
  late bool _isSandbox;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.initialCredentials.username);
    _passwordController =
        TextEditingController(text: widget.initialCredentials.password);
    _appKeyController =
        TextEditingController(text: widget.initialCredentials.appKey);
    _appSecretController =
        TextEditingController(text: widget.initialCredentials.appSecret);
    _isSandbox = widget.initialCredentials.isSandbox;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _appKeyController.dispose();
    _appSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BkashTheme.primaryPink.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings_suggest_rounded,
                      color: BkashTheme.primaryPink,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'bKash API Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: BkashTheme.textDark,
                          ),
                        ),
                        Text(
                          'Configure Merchant Credentials',
                          style: TextStyle(fontSize: 12, color: BkashTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: BkashTheme.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isSandbox ? Icons.science_outlined : Icons.cloud_done,
                          color: _isSandbox ? Colors.amber[800] : BkashTheme.successGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSandbox ? 'Sandbox Mode' : 'Live Production Mode',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: BkashTheme.textDark),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isSandbox,
                      activeThumbColor: BkashTheme.primaryPink,
                      onChanged: (val) {
                        setState(() {
                          _isSandbox = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: BkashTheme.textDark),
                decoration: const InputDecoration(
                  labelText: 'bKash Username',
                  prefixIcon: Icon(Icons.person_outline, color: BkashTheme.primaryPink),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: BkashTheme.textDark),
                decoration: const InputDecoration(
                  labelText: 'bKash Password',
                  prefixIcon: Icon(Icons.lock_outline, color: BkashTheme.primaryPink),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _appKeyController,
                style: const TextStyle(color: BkashTheme.textDark),
                decoration: const InputDecoration(
                  labelText: 'App Key',
                  prefixIcon: Icon(Icons.key_outlined, color: BkashTheme.primaryPink),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _appSecretController,
                obscureText: true,
                style: const TextStyle(color: BkashTheme.textDark),
                decoration: const InputDecoration(
                  labelText: 'App Secret',
                  prefixIcon: Icon(Icons.security_outlined, color: BkashTheme.primaryPink),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BkashTheme.textMuted,
                        side: const BorderSide(color: BkashTheme.dividerColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final creds = BkashCredentials(
                          username: _usernameController.text.trim(),
                          password: _passwordController.text.trim(),
                          appKey: _appKeyController.text.trim(),
                          appSecret: _appSecretController.text.trim(),
                          isSandbox: _isSandbox,
                        );
                        widget.onSave(creds);
                        Navigator.pop(context);
                      },
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
