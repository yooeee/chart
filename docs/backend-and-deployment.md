# Pulse Chart 백엔드·배포 안내

## 구조

`server/`는 NestJS 11 + TypeScript API입니다. Spring Boot와 비교하면 다음과 같습니다.

| Spring Boot | NestJS |
|---|---|
| `@RestController` | `@Controller` |
| `@Service` | `@Injectable` service |
| Repository interface | `WorkspaceRepository` interface + DI token |
| DTO + Bean Validation | DTO + `class-validator` |
| Filter/Interceptor | Guard/Interceptor |
| application.yml | `.env` + `ConfigService` |

현재 개발 저장소는 `FileWorkspaceRepository`이며 `server/data/workspace.json`에 저장합니다.
이 파일은 Git에서 제외됩니다. PostgreSQL로 전환할 때는
`WorkspaceRepository` 구현체만 교체하고 서비스와 컨트롤러는 유지합니다.
예정 테이블은 `server/database/schema.sql`에 있습니다.

## 로컬 실행

```bash
cd server
cp .env.example .env
npm ci
npm run start:dev
```

- API: `http://localhost:3000/api`
- Swagger: `http://localhost:3000/api/docs`
- 상태 확인: `http://localhost:3000/api/health`

개발 환경에서는 `POST /api/auth/demo`를 사용할 수 있습니다.
`NODE_ENV=production`에서는 개발용 로그인이 항상 차단됩니다.

## Flutter 연결

로컬 Web:

```bash
flutter run -d chrome \
  --dart-define=PULSE_API_BASE_URL=http://localhost:3000/api \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

EC2에서 Nginx가 `/api`를 프록시하면 Web 빌드는 다음과 같습니다.

```bash
flutter build web --release \
  --dart-define=PULSE_API_BASE_URL=/api \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

Android APK는 `/api` 같은 상대 주소를 사용할 수 없으므로 HTTPS 전체 주소가 필요합니다.

```bash
flutter build apk --release \
  --dart-define=PULSE_API_BASE_URL=https://YOUR_DOMAIN/api \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

## Google 로그인에서 사용자가 설정할 항목

1. Google Cloud Console에서 OAuth 동의 화면 생성
2. Web OAuth Client 생성 및 실제 도메인을 Authorized JavaScript origin에 등록
3. Android OAuth Client 생성 후 application ID와 release SHA-1 등록
4. Web Client ID를 NestJS의 `GOOGLE_CLIENT_IDS`에 등록
5. 같은 Web Client ID를 Flutter의 `GOOGLE_SERVER_CLIENT_ID`로 전달

OAuth Client ID는 공개 식별자이지만 Client secret, 서비스 계정 JSON, 인증서 개인키는
저장소에 커밋하지 않습니다.

## EC2 배포

예시 파일:

- Nginx: `deploy/nginx/pulse-chart.conf.example`
- systemd: `deploy/systemd/pulse-chart-api.service.example`

백엔드 빌드:

```bash
cd /opt/pulse-chart/server
npm ci
npm run check
npm run build
npm prune --omit=dev
sudo systemctl restart pulse-chart-api
```

Flutter Web의 `build/web` 내용은 `/var/www/pulse-chart/` 바로 아래에 놓습니다.
즉 `/var/www/pulse-chart/index.html`이 존재해야 합니다. Nginx 설정 후:

```bash
sudo nginx -t
sudo systemctl reload nginx
curl http://127.0.0.1:3000/api/health
```

실서비스에서는 도메인과 HTTPS 인증서를 먼저 연결하고 `CORS_ORIGINS`에도 해당 HTTPS
도메인만 등록합니다.

## 아직 외부 설정이 필요한 경계

- `GOOGLE_CLIENT_IDS`: Google 로그인 검증
- `JWT_SECRET`: 충분히 긴 운영용 비밀값
- PostgreSQL 접속정보와 Repository 구현체 교체
- 실제 시세·경제 일정 공급자 구현
- 모바일 푸시가 필요하면 FCM/APNs 발급정보와 전송 어댑터

알림 폴링·쿨다운·규칙 판정기는 이미 `AlertEvaluationService`에 구현되어 있습니다.
시세 공급자가 `supportsAlertEvaluation=true`와 `getAlertSnapshot()`을 구현하면 자동으로
가격·지표 규칙을 평가합니다.
