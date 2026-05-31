import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_error_message.dart';
import '../../../core/utils/api_url_utils.dart';
import '../../../providers/api_provider.dart';
import '../../../providers/ml_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/sf_card.dart';

/// Configuration et test de connexion FastAPI.
class ApiConnectionSection extends ConsumerStatefulWidget {
  const ApiConnectionSection({super.key});

  @override
  ConsumerState<ApiConnectionSection> createState() =>
      _ApiConnectionSectionState();
}

class _ApiConnectionSectionState extends ConsumerState<ApiConnectionSection> {
  late final TextEditingController _urlController;
  String? _testMessage;
  bool? _testOk;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) return;

    final url = normalizeApiBaseUrl(raw);
    _urlController.text = url;

    setState(() {
      _testing = true;
      _testMessage =
          'Connexion en cours… (Render peut mettre jusqu\'à 60 s au 1er appel)';
      _testOk = null;
    });

    await ref.read(apiBaseUrlProvider.notifier).setBaseUrl(url);
    ref.invalidate(apiDatasourceProvider);

    try {
      final api = ref.read(apiDatasourceProvider);
      final health = await api.getFieldHealth();
      final models = health['models'] as Map<String, dynamic>? ?? {};
      final m1 = models['model1_loaded'] == true;
      final m3 = models['model3_loaded'] == true;

      await ref.read(apiConnectedProvider.notifier).setConnected(true);
      await ref.read(demoModeProvider.notifier).setDemoMode(false);
      ref.invalidate(et0TodayProvider);
      ref.invalidate(et0ForecastProvider);
      ref.invalidate(fullFieldYieldProvider);

      if (!mounted) return;
      setState(() {
        _testing = false;
        _testOk = m1 && m3;
        _testMessage = _testOk!
            ? 'Connecté — Model 1 et Model 3 chargés · mode production activé'
            : 'Serveur répond mais modèles incomplets ($models)';
      });
    } catch (e) {
      await ref.read(apiConnectedProvider.notifier).setConnected(false);
      if (!mounted) return;
      setState(() {
        _testing = false;
        _testOk = false;
        _testMessage = apiErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedUrl = ref.watch(apiBaseUrlProvider);
    if (_urlController.text.isEmpty) {
      _urlController.text = savedUrl;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'CONNEXION API',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.textMuted,
            ),
          ),
        ),
        SfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL du serveur',
                  hintText: AppConstants.defaultApiBaseUrl,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  helperText:
                      'Hébergement Render : laissez l\'app 30–60 s au premier test',
                  helperMaxLines: 2,
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                enabled: !_testing,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _testing ? null : _testConnection,
                child: _testing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Tester'),
              ),
              if (_testMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _testOk == true
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 18,
                      color: _testOk == true
                          ? AppColors.primary
                          : AppColors.dangerRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testOk == true
                            ? '✅ $_testMessage'
                            : '❌ $_testMessage',
                        style: TextStyle(
                          fontSize: 12,
                          color: _testOk == true
                              ? AppColors.primary
                              : AppColors.dangerRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
