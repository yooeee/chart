import {
  Inject,
  Injectable,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { OAuth2Client } from 'google-auth-library';

import { UserProfile, UserWorkspace } from '../../domain/workspace.models';
import { WORKSPACE_REPOSITORY } from '../../infrastructure/storage/workspace.repository';
import type { WorkspaceRepository } from '../../infrastructure/storage/workspace.repository';

export interface AuthenticationResult {
  accessToken: string;
  user: UserProfile;
  workspace: UserWorkspace;
}

@Injectable()
export class AuthService {
  private readonly googleClient = new OAuth2Client();
  private readonly googleClientIds: string[];

  constructor(
    private readonly configService: ConfigService,
    private readonly jwtService: JwtService,
    @Inject(WORKSPACE_REPOSITORY)
    private readonly workspaceRepository: WorkspaceRepository,
  ) {
    this.googleClientIds = (this.configService.get<string>('GOOGLE_CLIENT_IDS') ?? '')
      .split(',')
      .map((clientId) => clientId.trim())
      .filter(Boolean);
  }

  getClientConfiguration(): { googleConfigured: boolean; demoAuthAvailable: boolean } {
    return {
      googleConfigured: this.googleClientIds.length > 0,
      demoAuthAvailable: this.isDemoAuthenticationAvailable(),
    };
  }

  async authenticateWithGoogle(idToken: string): Promise<AuthenticationResult> {
    if (this.googleClientIds.length === 0) {
      throw new ServiceUnavailableException('서버에 Google OAuth Client ID가 설정되지 않았습니다.');
    }

    const ticket = await this.googleClient.verifyIdToken({
      idToken,
      audience: this.googleClientIds,
    });
    const payload = ticket.getPayload();
    if (!payload?.sub || !payload.email || payload.email_verified !== true) {
      throw new UnauthorizedException('검증된 Google 계정 정보를 확인할 수 없습니다.');
    }

    return this.issueSession({
      id: payload.sub,
      email: payload.email,
      displayName: payload.name ?? payload.email.split('@')[0],
      photoUrl: payload.picture,
    });
  }

  async authenticateDemoUser(): Promise<AuthenticationResult> {
    if (!this.isDemoAuthenticationAvailable()) {
      throw new UnauthorizedException('개발용 로그인이 비활성화되어 있습니다.');
    }
    return this.issueSession({
      id: 'demo-user',
      email: 'developer@pulse.local',
      displayName: 'Pulse Developer',
    });
  }

  private isDemoAuthenticationAvailable(): boolean {
    return (
      this.configService.get<string>('NODE_ENV') !== 'production' &&
      this.configService.get<string>('ALLOW_DEMO_AUTH', 'true') === 'true'
    );
  }

  private async issueSession(user: UserProfile): Promise<AuthenticationResult> {
    const workspace = await this.workspaceRepository.upsertUser(user);
    const accessToken = await this.jwtService.signAsync({
      sub: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    });
    return { accessToken, user, workspace };
  }
}
