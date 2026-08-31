import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsIn,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  MaxLength,
} from 'class-validator';

export class UpdateAlertDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(80)
  name?: string;

  @ApiPropertyOptional({ enum: ['priceAbove', 'priceBelow', 'indicatorBuy', 'indicatorSell'] })
  @IsOptional()
  @IsIn(['priceAbove', 'priceBelow', 'indicatorBuy', 'indicatorSell'])
  type?: 'priceAbove' | 'priceBelow' | 'indicatorBuy' | 'indicatorSell';

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @IsPositive()
  targetPrice?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(50)
  indicatorId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  enabled?: boolean;
}
