import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class SaveWatchlistItemDto {
  @ApiProperty({ example: 'NASDAQ:NVDA' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  symbol: string;

  @ApiProperty({ example: 'NVDA' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(20)
  ticker: string;

  @ApiProperty({ example: 'NVIDIA' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  displayName: string;

  @ApiProperty({ example: 'NASDAQ' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(40)
  exchange: string;
}
