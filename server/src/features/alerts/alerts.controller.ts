import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { CurrentUser } from '../auth/auth-user';
import type { AuthenticatedUser } from '../auth/auth-user';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AlertsService } from './alerts.service';
import { CreateAlertDto } from './dto/create-alert.dto';
import { UpdateAlertDto } from './dto/update-alert.dto';

@ApiTags('alerts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('alerts')
export class AlertsController {
  constructor(private readonly alertsService: AlertsService) {}

  @Get()
  getAll(@CurrentUser() user: AuthenticatedUser) {
    return this.alertsService.getAll(user.id);
  }

  @Post()
  create(@CurrentUser() user: AuthenticatedUser, @Body() body: CreateAlertDto) {
    return this.alertsService.create(user.id, body);
  }

  @Patch(':alertId')
  update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('alertId') alertId: string,
    @Body() body: UpdateAlertDto,
  ) {
    return this.alertsService.update(user.id, alertId, body);
  }

  @Delete(':alertId')
  remove(@CurrentUser() user: AuthenticatedUser, @Param('alertId') alertId: string) {
    return this.alertsService.remove(user.id, alertId);
  }

  @Post(':alertId/test')
  test(@CurrentUser() user: AuthenticatedUser, @Param('alertId') alertId: string) {
    return this.alertsService.test(user.id, alertId);
  }
}
