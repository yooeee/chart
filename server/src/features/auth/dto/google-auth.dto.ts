import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class GoogleAuthDto {
  @ApiProperty({ description: 'Flutter Google Sign-In에서 받은 ID token' })
  @IsString()
  @IsNotEmpty()
  idToken: string;
}
