import { Inject, Injectable } from '@nestjs/common';

import { UserNotification } from '../../domain/workspace.models';
import { WORKSPACE_REPOSITORY } from '../../infrastructure/storage/workspace.repository';
import type { WorkspaceRepository } from '../../infrastructure/storage/workspace.repository';

@Injectable()
export class NotificationsService {
  constructor(
    @Inject(WORKSPACE_REPOSITORY)
    private readonly repository: WorkspaceRepository,
  ) {}

  getAll(userId: string): Promise<UserNotification[]> {
    return this.repository.getNotifications(userId);
  }

  markRead(userId: string, notificationId: string): Promise<UserNotification[]> {
    return this.repository.markNotificationRead(userId, notificationId);
  }
}
