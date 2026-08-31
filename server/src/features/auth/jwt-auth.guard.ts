import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

import { AuthenticatedUser } from './auth-user';

type AuthenticatedRequest = Request & { user?: AuthenticatedUser };

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const authorization = request.headers.authorization;
    const [scheme, token] = authorization?.split(' ') ?? [];
    if (scheme !== 'Bearer' || !token) {
      throw new UnauthorizedException('로그인이 필요합니다.');
    }

    try {
      const payload = await this.jwtService.verifyAsync<{
        sub: string;
        email: string;
        displayName: string;
        photoUrl?: string;
      }>(token);
      request.user = {
        id: payload.sub,
        email: payload.email,
        displayName: payload.displayName,
        photoUrl: payload.photoUrl,
      };
      return true;
    } catch {
      throw new UnauthorizedException('로그인 토큰이 만료되었거나 유효하지 않습니다.');
    }
  }
}
