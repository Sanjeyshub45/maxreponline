// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/strava_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserAuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // ─── Avatar + Name ────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: user.photoUrl != null
                      ? ClipOval(
                          child: Image.network(user.photoUrl!,
                              fit: BoxFit.cover))
                      : Center(
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Text(user.displayName,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  '${user.orgId} • ${user.district}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ─── Pulse Score Card ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.15),
                  AppTheme.accent.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text('PULSE SCORE',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(
                  user.pulsePoints.toString(),
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _scoreComponent('Activity', user.activityScore,
                        AppTheme.primary, '40%'),
                    const SizedBox(width: 8),
                    _scoreComponent('Strength', user.strengthScore,
                        AppTheme.accentAlt, '30%'),
                    const SizedBox(width: 8),
                    _scoreComponent('Vitality', user.vitalityScore,
                        AppTheme.vitality, '30%'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Bio Stats ────────────────────────────────────────────────
          _sectionHeader('Body Stats'),
          const SizedBox(height: 12),
          Row(
            children: [
              _statTile('BMI', user.bmi.toStringAsFixed(1)),
              const SizedBox(width: 12),
              _statTile('Weight', '${user.weightKg.toStringAsFixed(0)} kg'),
              const SizedBox(width: 12),
              _statTile('Height', '${user.heightCm.toStringAsFixed(0)} cm'),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Tribe Info ───────────────────────────────────────────────
          _sectionHeader('Tribe'),
          const SizedBox(height: 12),
          _infoRow(Icons.business_outlined,
              user.orgType == 'company' ? 'Company' : 'College', user.orgId),
          if (user.department.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.group_outlined, 'Department', user.department),
          ],
          const SizedBox(height: 8),
          _infoRow(Icons.location_on_outlined, 'Location',
              '${user.district}, ${user.state}'),

          const SizedBox(height: 24),

          // ─── Strava Connect ───────────────────────────────────────────
          _sectionHeader('Integrations'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC4C02).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_run,
                      color: Color(0xFFFC4C02), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Strava',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      Text(
                        user.stravaLinked
                            ? 'Connected — Activity points active'
                            : 'Link to earn Activity points',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                user.stravaLinked
                    ? const Icon(Icons.check_circle,
                        color: AppTheme.primary, size: 22)
                    : OutlinedButton(
                        onPressed: () => StravaService()
                            .launchStravaAuth(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFFC4C02), width: 1),
                          foregroundColor: const Color(0xFFFC4C02),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Link',
                            style: TextStyle(fontSize: 13)),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── Sign Out ─────────────────────────────────────────────────
          OutlinedButton(
            onPressed: () => context.read<UserAuthProvider>().signOut(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Sign Out'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ));
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.primary,
        letterSpacing: 2,
      ),
    );
  }

  Widget _scoreComponent(
      String label, double score, Color color, String weight) {
    return Expanded(
      child: Column(
        children: [
          Text(
            score.toStringAsFixed(0),
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
          Text(weight,
              style: TextStyle(
                  color: color.withValues(alpha: 0.6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 18),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ],
    );
  }
}
