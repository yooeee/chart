import { Body, Controller, Delete, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { CurrentUser } from '../auth/auth-user';
import type { AuthenticatedUser } from '../auth/auth-user';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { SaveWatchlistItemDto } from './dto/save-watchlist-item.dto';
import { WatchlistService } from './watchlist.service';

@ApiTags('watchlist')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('watchlist')
export class WatchlistController {
  constructor(private readonly watchlistService: WatchlistService) {}

  @Get()
  getAll(@CurrentUser() user: AuthenticatedUser) {
    return this.watchlistService.getAll(user.id);
  }

  @Post()
  save(@CurrentUser() user: AuthenticatedUser, @Body() body: SaveWatchlistItemDto) {
    return this.watchlistService.save(user.id, body);
  }

  @Delete(':symbol')
  remove(@CurrentUser() user: AuthenticatedUser, @Param('symbol') symbol: string) {
    return this.watchlistService.remove(user.id, decodeURIComponent(symbol));
  }
}
