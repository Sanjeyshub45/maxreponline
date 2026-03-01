// lib/screens/profile_setup_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/places_service.dart';
import '../theme/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placesService = PlacesService();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  // State
  String _gender = 'male';
  String _orgType = 'company';
  double? _bmi;
  bool _loading = false;

  // Places autocomplete
  List<PlacePrediction> _predictions = [];
  Timer? _debounce;
  bool _showDropdown = false;
  bool _fetchingDetails = false;
  final _orgFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _orgFocusNode.addListener(() {
      if (!_orgFocusNode.hasFocus) {
        setState(() => _showDropdown = false);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _orgCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _orgFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ─── BMI ────────────────────────────────────────────────────────────────────

  void _recalcBmi() {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    if (h != null && w != null && h > 0) {
      // calculateBmi(weightKg, heightCm) — note arg order
      setState(() => _bmi = UserModel.calculateBmi(w, h));
    }
  }

  // ─── Places autocomplete ─────────────────────────────────────────────────────

  void _onOrgChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() { _predictions = []; _showDropdown = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _placesService.autocomplete(value);
      if (mounted) {
        setState(() {
          _predictions = results;
          _showDropdown = results.isNotEmpty;
        });
      }
    });
  }

  Future<void> _onPredictionTapped(PlacePrediction p) async {
    setState(() {
      _orgCtrl.text = p.mainText;
      _showDropdown = false;
      _predictions = [];
      _fetchingDetails = true;
    });
    _orgFocusNode.unfocus();

    final details = await _placesService.getDetails(p.placeId, p.mainText);
    if (mounted && details != null) {
      setState(() {
        _districtCtrl.text = details.district;
        _stateCtrl.text = details.state;
        _countryCtrl.text = details.country;
        _fetchingDetails = false;
      });
    } else if (mounted) {
      setState(() => _fetchingDetails = false);
    }
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final authProvider = context.read<UserAuthProvider>();
    final firebaseUser = authProvider.firebaseUser;
    final uid = firebaseUser?.uid ?? 'demo_${DateTime.now().millisecondsSinceEpoch}';
    final email = firebaseUser?.email ?? '';

    final h = double.parse(_heightCtrl.text);
    final w = double.parse(_weightCtrl.text);
    // calculateBmi(weightKg, heightCm) — note argument order
    final bmi = UserModel.calculateBmi(w, h);

    final user = UserModel(
      uid: uid,
      email: email,
      displayName: _nameCtrl.text.trim(),
      age: int.parse(_ageCtrl.text),
      gender: _gender,
      heightCm: h,
      weightKg: w,
      bmi: bmi,
      orgId: _orgCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
      orgName: _orgCtrl.text.trim(),
      orgType: _orgType,
      district: _districtCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      pulsePoints: 0,
    );

    final success = await authProvider.saveProfile(user);
    if (mounted) {
      setState(() => _loading = false);
      if (!success && authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ─── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text('Set Up Profile',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                const Text('Tell us about yourself to calibrate your Pulse Score',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 32),

                // ── Section: Personal ───────────────────────────────────────
                _sectionLabel('Personal Info'),
                const SizedBox(height: 12),

                _field(_nameCtrl, 'Full Name', Icons.person_outline,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null),
                const SizedBox(height: 12),

                _field(_ageCtrl, 'Age', Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 10 || n > 100) return 'Enter a valid age';
                      return null;
                    }),
                const SizedBox(height: 16),

                // Gender picker
                _sectionLabel('Gender'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _genderChip('male', '♂ Male'),
                    const SizedBox(width: 12),
                    _genderChip('female', '♀ Female'),
                    const SizedBox(width: 12),
                    _genderChip('other', '⊕ Other'),
                  ],
                ),
                const SizedBox(height: 16),

                // Height / Weight
                Row(
                  children: [
                    Expanded(
                      child: _field(_heightCtrl, 'Height (cm)', Icons.height,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _recalcBmi(),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n < 100 || n > 250) return 'Invalid';
                            return null;
                          }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_weightCtrl, 'Weight (kg)', Icons.monitor_weight_outlined,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _recalcBmi(),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n < 30 || n > 300) return 'Invalid';
                            return null;
                          }),
                    ),
                  ],
                ),

                // BMI preview
                if (_bmi != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _bmiColor(_bmi!).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _bmiColor(_bmi!).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monitor_heart_outlined,
                            color: _bmiColor(_bmi!), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'BMI: ${_bmi!.toStringAsFixed(1)}  •  ${_bmiLabel(_bmi!)}',
                          style: TextStyle(
                              color: _bmiColor(_bmi!),
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // ── Section: Organisation ───────────────────────────────────
                _sectionLabel('Organisation / Affiliation'),
                const SizedBox(height: 8),

                // Org type chips
                Row(
                  children: [
                    _orgTypeChip('company', '🏢 Company'),
                    const SizedBox(width: 12),
                    _orgTypeChip('college', '🎓 College'),
                  ],
                ),
                const SizedBox(height: 12),

                // Organisation field WITH autocomplete
                _buildOrgField(),
                const SizedBox(height: 12),

                // Location fields (auto-filled by Places)
                Row(
                  children: [
                    Expanded(child: _locationField(_districtCtrl, 'District / City')),
                    const SizedBox(width: 12),
                    Expanded(child: _locationField(_stateCtrl, 'State')),
                  ],
                ),
                const SizedBox(height: 12),
                _locationField(_countryCtrl, 'Country'),

                const SizedBox(height: 36),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.black))
                        : const Text('Continue →',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Organisation field with dropdown overlay ──────────────────────────────

  Widget _buildOrgField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _orgCtrl,
          focusNode: _orgFocusNode,
          style: const TextStyle(color: AppTheme.textPrimary),
          onChanged: _onOrgChanged,
          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
          decoration: InputDecoration(
            labelText: _orgType == 'college'
                ? 'College / University Name'
                : 'Company Name',
            prefixIcon: Icon(
              _orgType == 'college'
                  ? Icons.school_outlined
                  : Icons.business_outlined,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            suffixIcon: _fetchingDetails
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primary),
                    ),
                  )
                : null,
          ),
        ),

        // Autocomplete dropdown
        if (_showDropdown && _predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _predictions.length.clamp(0, 5),
                separatorBuilder: (context2, idx) =>
                    const Divider(height: 1, color: AppTheme.border),
                itemBuilder: (ctx, i) {
                  final p = _predictions[i];
                  return InkWell(
                    onTap: () => _onPredictionTapped(p),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: AppTheme.primary, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.mainText,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                if (p.secondaryText.isNotEmpty)
                                  Text(p.secondaryText,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11),
                                      overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }

  Widget _locationField(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textPrimary),
      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.map_outlined,
            color: AppTheme.textSecondary, size: 20),
        suffixIcon: const Icon(Icons.auto_awesome,
            color: AppTheme.primary, size: 16),
        helperText: ctrl.text.isNotEmpty ? 'Auto-filled ✓' : null,
        helperStyle: const TextStyle(color: AppTheme.primary, fontSize: 11),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      );

  Widget _genderChip(String value, String label) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.15)
                : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _orgTypeChip(String value, String label) {
    final selected = _orgType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _orgType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accent.withValues(alpha: 0.12)
                : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.accent : AppTheme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppTheme.accent : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppTheme.primary;
    if (bmi < 30) return Colors.orange;
    return Colors.redAccent;
  }

  String _bmiLabel(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
