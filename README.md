# Pulse Chart

Flutter Web·Android에서 동일하게 실행되는 TradingView 기반 시장 작업공간과 NestJS
TypeScript 백엔드입니다.

## 구현 기능

- 관심종목 추가·삭제 및 선택 즉시 차트 변경
- 모바일·Web 차트 전체화면
- 종목·시간봉·차트 테마·6개 지표 선택 상태 로컬 저장
- 가격·지표 알림 규칙 생성·활성화·삭제·테스트
- 주요 지수·상승률·하락률·코인 시장 요약
- 경제 캘린더
- 6개 보조지표 계산식·해석·주의점 가이드
- Google 로그인 후 Web·앱 설정 서버 동기화
- NestJS Swagger API, Google ID token 검증, JWT, JSON 개발 저장소
- 실제 시세 공급자 연결 후 동작하는 서버 알림 평가기

시장 요약과 경제 일정은 공급자 미설정 시 `샘플 데이터`라고 명확히 표시합니다.
TradingView 무료 Advanced Chart 위젯에는 자체 지표 계산 코드를 삽입할 수 없으므로,
6개 지표는 현재 설명·선택·설정 저장까지 동작합니다. 실제 선 렌더링은 TradingView
Advanced Charts 라이선스와 Datafeed 연결 후 활성화합니다.

## Flutter 실행

```bash
flutter create --platforms=web,ios,android .
flutter pub get
flutter run -d chrome
```

백엔드·Google 로그인까지 연결하는 명령은
[`docs/backend-and-deployment.md`](docs/backend-and-deployment.md)를 참고합니다.

## NestJS 실행

```bash
cd server
cp .env.example .env
npm ci
npm run start:dev
```

- API 기본 경로: `http://localhost:3000/api`
- Swagger: `http://localhost:3000/api/docs`
- 전체 검사: `npm run check`

## 프로젝트 구조

- `lib/features/landing`: 소개 화면과 공통 작업공간 셸
- `lib/features/chart`: TradingView 및 기존 지표 계산 도메인
- `lib/features/workspace`: 관심종목·설정·알림·시장·인증 동기화
- `server/src/features`: NestJS 기능 모듈
- `server/src/infrastructure`: 교체 가능한 저장소 구현
- `server/database/schema.sql`: PostgreSQL 전환용 스키마
- `deploy`: EC2 Nginx·systemd 예시

## 배포

- Web: GitHub Pages workflow 또는 EC2 Nginx
- Android: GitHub Actions release APK artifact
- API: EC2에서 NestJS를 systemd로 실행하고 Nginx `/api` 프록시

비밀값과 런타임 데이터는 `.gitignore`로 제외되어 있습니다. `.env.example`에는 키 이름만
들어 있으며 실제 OAuth 정보·JWT secret·DB 비밀번호는 환경변수로 전달합니다.
