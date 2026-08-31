import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';

import { CurrentUser } from './auth-user';
import type { AuthenticatedUser } from './auth-user';
import { AuthService } from './auth.service';
import { GoogleAuthDto } from './dto/google-auth.dto';
import { JwtAuthGuard } from './jwt-auth.guard';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('config')
  getConfiguration() {
    return this.authService.getClientConfiguration();
  }

  @Post('google')
  @ApiOperation({ summary: 'Google ID token을 검증하고 Pulse 세션을 발급합니다.' })
  authenticateWithGoogle(@Body() body: GoogleAuthDto) {
    return this.authService.authenticateWithGoogle(body.idToken);
  }

  @Post('demo')
  @ApiOperation({ summary: '로컬 개발 전용 계정으로 로그인합니다.' })
  authenticateDemoUser() {
    return this.authService.authenticateDemoUser();
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  getCurrentUser(@CurrentUser() user: AuthenticatedUser) {
    return user;
  }
}
