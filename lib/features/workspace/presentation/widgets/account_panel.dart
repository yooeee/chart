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
      child: SingleChildScrollView(
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
                color: AppColors.greenInk,
                fontSize: 12,
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
              style: const TextStyle(color: AppColors.body, fontSize: 14, height: 1.45),
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
                          fontSize: 14,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  style: const TextStyle(color: AppColors.label, fontSize: 14, height: 1.45),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            const Text(
              '로그인하지 않아도 관심종목과 차트 설정은 현재 기기에 저장됩니다.',
              style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _configurationMessage() =>
      '현재 계정 연결을 사용할 수 없습니다. 관심종목과 차트 설정은 이 기기에서 계속 이용할 수 있습니다.';
}
