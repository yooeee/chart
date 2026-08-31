import { Global, Module } from '@nestjs/common';

import { FileWorkspaceRepository } from './file-workspace.repository';
import { WORKSPACE_REPOSITORY } from './workspace.repository';

@Global()
@Module({
  providers: [
    FileWorkspaceRepository,
    {
      provide: WORKSPACE_REPOSITORY,
      useExisting: FileWorkspaceRepository,
    },
  ],
  exports: [WORKSPACE_REPOSITORY],
})
export class StorageModule {}
