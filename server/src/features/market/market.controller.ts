import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { MarketService } from './market.service';

@ApiTags('market')
@Controller('market')
export class MarketController {
  constructor(private readonly marketService: MarketService) {}

  @Get('summary')
  getSummary() {
    return this.marketService.getSummary();
  }

  @Get('economic-calendar')
  getEconomicCalendar() {
    return this.marketService.getEconomicCalendar();
  }
}
