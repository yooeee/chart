import { Body, Controller, Get, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { CurrentUser } from '../auth/auth-user';
import type { AuthenticatedUser } from '../auth/auth-user';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { SaveChartPreferencesDto } from './dto/save-chart-preferences.dto';
import { PreferencesService } from './preferences.service';

@ApiTags('preferences')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('preferences')
export class PreferencesController {
  constructor(private readonly preferencesService: PreferencesService) {}

  @Get()
  get(@CurrentUser() user: AuthenticatedUser) {
    return this.preferencesService.get(user.id);
  }

  @Put()
  save(@CurrentUser() user: AuthenticatedUser, @Body() body: SaveChartPreferencesDto) {
    return this.preferencesService.save(user.id, body);
  }
}
