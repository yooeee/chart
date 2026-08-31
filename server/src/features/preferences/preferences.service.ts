import { Inject, Injectable } from '@nestjs/common';

import { ChartPreferences } from '../../domain/workspace.models';
import { WORKSPACE_REPOSITORY } from '../../infrastructure/storage/workspace.repository';
import type { WorkspaceRepository } from '../../infrastructure/storage/workspace.repository';
import { SaveChartPreferencesDto } from './dto/save-chart-preferences.dto';

@Injectable()
export class PreferencesService {
  constructor(
    @Inject(WORKSPACE_REPOSITORY)
    private readonly repository: WorkspaceRepository,
  ) {}

  get(userId: string): Promise<ChartPreferences> {
    return this.repository.getPreferences(userId);
  }

  save(userId: string, dto: SaveChartPreferencesDto): Promise<ChartPreferences> {
    return this.repository.savePreferences(userId, {
      ...dto,
      updatedAt: new Date().toISOString(),
    });
  }
}
