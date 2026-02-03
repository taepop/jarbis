import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/jarvis_theme.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/jarvis_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isApiKeyConfigured = false;
  bool _isTestingApiKey = false;
  bool _obscureApiKey = true;
  String? _defaultSoundPath;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isApiKeyConfigured = await GeminiService.isConfigured();
    _defaultSoundPath = await AudioService.getDefaultSound();
    
    if (_isApiKeyConfigured) {
      final apiKey = await GeminiService.getApiKey();
      _apiKeyController.text = apiKey ?? '';
    }
    
    setState(() {});
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('SETTINGS', style: JarvisTextStyles.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildApiKeySection(),
            const SizedBox(height: 24),
            _buildDefaultSoundSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeySection() {
    return JarvisCard(
      glowColor: _isApiKeyConfigured ? JarvisColors.tertiary : JarvisColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isApiKeyConfigured ? Icons.check_circle : Icons.warning_amber,
                color: _isApiKeyConfigured ? JarvisColors.tertiary : JarvisColors.secondary,
              ),
              const SizedBox(width: 8),
              Text('GEMINI API KEY', style: JarvisTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isApiKeyConfigured
                ? 'API key is configured. AI-powered news briefings are enabled.'
                : 'Configure your Gemini API key for AI-powered news summaries.',
            style: JarvisTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          // API Key Input
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            style: JarvisTextStyles.bodyMedium.copyWith(
              color: JarvisColors.textPrimary,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: 'Enter your Gemini API key',
              hintStyle: JarvisTextStyles.bodyMedium.copyWith(color: JarvisColors.textMuted),
              prefixIcon: const Icon(Icons.key, color: JarvisColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                  color: JarvisColors.textMuted,
                ),
                onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: JarvisColors.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JarvisColors.primary.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: JarvisColors.primary, width: 2),
              ),
              filled: true,
              fillColor: JarvisColors.surfaceLight,
            ),
          ),
          const SizedBox(height: 16),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: JarvisButton(
                  label: 'SAVE KEY',
                  icon: Icons.save,
                  isLoading: _isTestingApiKey,
                  onPressed: _saveApiKey,
                ),
              ),
              const SizedBox(width: 12),
              JarvisButton(
                label: 'GET KEY',
                icon: Icons.open_in_new,
                isOutlined: true,
                onPressed: _openGoogleAIStudio,
              ),
            ],
          ),
          
          if (_isApiKeyConfigured) ...[
            const SizedBox(height: 12),
            JarvisButton(
              label: 'REMOVE KEY',
              icon: Icons.delete_outline,
              color: JarvisColors.error,
              isOutlined: true,
              onPressed: _removeApiKey,
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildDefaultSoundSection() {
    return JarvisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DEFAULT ALARM SOUND', style: JarvisTextStyles.labelLarge),
          const SizedBox(height: 8),
          Text(
            'Set a default audio file for all new alarms.',
            style: JarvisTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDefaultSound,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: JarvisColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: JarvisColors.primary.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(
                    _defaultSoundPath != null ? Icons.music_note : Icons.music_off,
                    color: JarvisColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _defaultSoundPath != null
                          ? _defaultSoundPath!.split('/').last
                          : 'No default sound set',
                      style: JarvisTextStyles.bodyMedium.copyWith(
                        color: _defaultSoundPath != null
                            ? JarvisColors.textPrimary
                            : JarvisColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.folder_open, color: JarvisColors.primary),
                ],
              ),
            ),
          ),
          if (_defaultSoundPath != null) ...[
            const SizedBox(height: 12),
            JarvisButton(
              label: 'CLEAR DEFAULT',
              icon: Icons.clear,
              color: JarvisColors.textMuted,
              isOutlined: true,
              onPressed: _clearDefaultSound,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildAboutSection() {
    return JarvisCard(
      glowColor: JarvisColors.glowBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ABOUT', style: JarvisTextStyles.labelLarge),
          const SizedBox(height: 16),
          _buildInfoRow('App', 'J.A.R.V.I.S Alarm v1.0.0'),
          _buildInfoRow('Weather', 'Open-Meteo (Free)'),
          _buildInfoRow('News', 'BBC, NYT, NPR RSS'),
          _buildInfoRow('AI', 'Google Gemini 2.0 Flash'),
          const Divider(color: JarvisColors.surfaceLight, height: 24),
          Text(
            'This app uses free APIs and services. No payment required!',
            style: JarvisTextStyles.caption.copyWith(color: JarvisColors.textSecondary),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: JarvisTextStyles.caption),
          Text(
            value,
            style: JarvisTextStyles.bodyMedium.copyWith(color: JarvisColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    
    if (apiKey.isEmpty) {
      _showSnackBar('Please enter an API key', isError: true);
      return;
    }

    setState(() => _isTestingApiKey = true);

    // Test the API key
    final isValid = await GeminiService.testApiKey(apiKey);

    if (isValid) {
      await GeminiService.saveApiKey(apiKey);
      setState(() {
        _isApiKeyConfigured = true;
        _isTestingApiKey = false;
      });
      _showSnackBar('API key saved successfully!');
    } else {
      setState(() => _isTestingApiKey = false);
      _showSnackBar('Invalid API key. Please check and try again.', isError: true);
    }
  }

  Future<void> _removeApiKey() async {
    await GeminiService.removeApiKey();
    setState(() {
      _isApiKeyConfigured = false;
      _apiKeyController.clear();
    });
    _showSnackBar('API key removed');
  }

  Future<void> _openGoogleAIStudio() async {
    final uri = Uri.parse('https://aistudio.google.com/app/apikey');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _pickDefaultSound() async {
    final path = await AudioService.pickAudioFile();
    if (path != null) {
      await AudioService.setDefaultSound(path);
      setState(() => _defaultSoundPath = path);
      _showSnackBar('Default sound set');
    }
  }

  Future<void> _clearDefaultSound() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('default_alarm_sound');
    setState(() => _defaultSoundPath = null);
    _showSnackBar('Default sound cleared');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: JarvisColors.textPrimary),
        ),
        backgroundColor: isError ? JarvisColors.error.withOpacity(0.9) : JarvisColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
