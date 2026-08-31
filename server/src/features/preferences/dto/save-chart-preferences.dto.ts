import { ApiProperty } from '@nestjs/swagger';
import { ArrayMaxSize, IsArray, IsIn, IsString, MaxLength } from 'class-validator';

export class SaveChartPreferencesDto {
  @ApiProperty({ example: 'BINANCE:BTCUSDT' })
  @IsString()
  @MaxLength(80)
  symbol: string;

  @ApiProperty({ enum: ['1', '5', '15', '30', '60', '240', 'D', 'W', 'M'] })
  @IsIn(['1', '5', '15', '30', '60', '240', 'D', 'W', 'M'])
  interval: '1' | '5' | '15' | '30' | '60' | '240' | 'D' | 'W' | 'M';

  @ApiProperty({ enum: ['light', 'dark'] })
  @IsIn(['light', 'dark'])
  theme: 'light' | 'dark';

  @ApiProperty({ type: [String], maxItems: 6 })
  @IsArray()
  @ArrayMaxSize(6)
  @IsString({ each: true })
  activeIndicators: string[];
}
