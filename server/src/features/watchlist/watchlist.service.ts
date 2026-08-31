import { Inject, Injectable } from '@nestjs/common';

import { WatchlistItem } from '../../domain/workspace.models';
import { WORKSPACE_REPOSITORY } from '../../infrastructure/storage/workspace.repository';
import type { WorkspaceRepository } from '../../infrastructure/storage/workspace.repository';
import { SaveWatchlistItemDto } from './dto/save-watchlist-item.dto';

@Injectable()
export class WatchlistService {
  constructor(
    @Inject(WORKSPACE_REPOSITORY)
    private readonly repository: WorkspaceRepository,
  ) {}

  getAll(userId: string): Promise<WatchlistItem[]> {
    return this.repository.getWatchlist(userId);
  }

  save(userId: string, dto: SaveWatchlistItemDto): Promise<WatchlistItem[]> {
    return this.repository.saveWatchlistItem(userId, {
      ...dto,
      createdAt: new Date().toISOString(),
    });
  }

  remove(userId: string, symbol: string): Promise<WatchlistItem[]> {
    return this.repository.removeWatchlistItem(userId, symbol);
  }
}
