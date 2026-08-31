import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { randomUUID } from 'node:crypto';
import { rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import request from 'supertest';

import { AppModule } from '../src/app.module';

describe('Pulse Chart API', () => {
  let app: INestApplication;
  const dataFile = join(tmpdir(), `pulse-chart-${randomUUID()}.json`);

  beforeAll(async () => {
    process.env.DATA_FILE = dataFile;
    process.env.ALLOW_DEMO_AUTH = 'true';
    process.env.NODE_ENV = 'test';
    process.env.JWT_SECRET = 'test-only-jwt-secret-not-for-production';
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    await rm(dataFile, { force: true });
  });

  it('reports health', async () => {
    await request(app.getHttpServer())
      .get('/api/health')
      .expect(200)
      .expect(({ body }) => expect(body.status).toBe('ok'));
  });

  it('signs in a demo user and persists watchlist data', async () => {
    const authentication = await request(app.getHttpServer()).post('/api/auth/demo').expect(201);
    const token = authentication.body.accessToken as string;

    const response = await request(app.getHttpServer())
      .post('/api/watchlist')
      .set('Authorization', `Bearer ${token}`)
      .send({
        symbol: 'NASDAQ:NVDA',
        ticker: 'NVDA',
        displayName: 'NVIDIA',
        exchange: 'NASDAQ',
      })
      .expect(201);

    expect(response.body[0].symbol).toBe('NASDAQ:NVDA');
  });
});
