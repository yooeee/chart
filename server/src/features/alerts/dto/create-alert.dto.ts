import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsIn,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  MaxLength,
} from 'class-validator';

export class CreateAlertDto {
  @ApiProperty({ example: 'BTC 목표가 도달' })
  @IsString()
  @MaxLength(80)
  name: string;

  @ApiProperty({ example: 'BINANCE:BTCUSDT' })
  @IsString()
  @MaxLength(80)
  symbol: string;

  @ApiProperty({ enum: ['priceAbove', 'priceBelow', 'indicatorBuy', 'indicatorSell'] })
  @IsIn(['priceAbove', 'priceBelow', 'indicatorBuy', 'indicatorSell'])
  type: 'priceAbove' | 'priceBelow' | 'indicatorBuy' | 'indicatorSell';

  @ApiPropertyOptional({ example: 100000 })
  @IsOptional()
  @IsNumber()
  @IsPositive()
  targetPrice?: number;

  @ApiPropertyOptional({ example: 'rsiPulse' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  indicatorId?: string;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  enabled?: boolean;
}
