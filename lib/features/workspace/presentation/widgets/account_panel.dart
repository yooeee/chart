import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/pulse_workspace_controller.dart';
import 'google_sign_in_button.dart';

class AccountPanel extends StatelessWidget {
  const AccountPanel({super.key, required this.controller});

  final PulseWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final account = controller.account;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'ACCOUNT & SYNC',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              account == null ? '웹·앱 설정 동기화' : account.displayName,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              account?.email ??
                  'Google 계정으로 로그인하면 관심종목·차트 설정·알림 규칙을 공유할 수 있습니다.',
              style: const TextStyle(color: AppColors.body, fontSize: 11, height: 1.45),
            ),
            const SizedBox(height: 18),
            if (account != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xffeefaf2),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done_outlined, size: 18, color: AppColors.green),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '이 기기와 서버 동기화가 활성화되어 있습니다.',
                        style: TextStyle(
                          color: AppColors.label,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: controller.busy ? null : controller.signOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  shape: const RoundedRectangleBorder(),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('로그아웃'),
              ),
            ] else if (!controller.apiConfigured || !controller.googleConfigured) ...[
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xfffff7df),
                child: Text(
                  _configurationMessage(),
                  style: const TextStyle(color: AppColors.label, fontSize: 11, height: 1.45),
                ),
              ),
            ] else ...[
              if (kIsWeb && !controller.supportsProgrammaticGoogleSignIn)
                Center(child: buildGoogleSignInButton())
              else
                FilledButton.icon(
                  onPressed: controller.busy
                      ? null
                      : controller.signInWithGoogle,
                  icon: controller.busy
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login, size: 17),
                  label: const Text('Google로 계속'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            const Text(
              '로그인하지 않아도 설정은 현재 기기에 저장됩니다. 인증 토큰은 앱 설정 저장소에 기록하지 않습니다.',
              style: TextStyle(color: AppColors.muted, fontSize: 9, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  String _configurationMessage() {
    if (!controller.apiConfigured && !controller.googleConfigured) {
      return 'PULSE_API_BASE_URL과 Google OAuth Client ID가 아직 설정되지 않았습니다. 로컬 저장 기능은 정상 작동합니다.';
    }
    if (!controller.apiConfigured) {
      return 'PULSE_API_BASE_URL이 설정되지 않아 Google 계정 동기화를 시작할 수 없습니다.';
    }
    return 'Google OAuth Client ID가 설정되지 않았습니다. 배포 환경의 dart-define에 Client ID를 추가하세요.';
  }
}
