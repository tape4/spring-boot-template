# 스프링부트 애플리케이션 템플릿 설정 가이드

이 프로젝트는 해커톤이나 빠른 개발을 위한 스프링부트 애플리케이션 템플릿입니다.

## 🚀 빠른 시작

### 1. 프로젝트 복제
```bash
git clone <repository-url>
cd <project-directory>
```

### 2. 프로젝트 설정
```bash
# 프로젝트명을 설정합니다 (예: my-spring-app)
./setup-project.sh my-spring-app
```

### 3. Docker 환경 실행
```bash
# Docker 컨테이너들을 백그라운드에서 실행
docker compose up -d
```

### 4. 애플리케이션 실행
```bash
# 스프링부트 애플리케이션 실행
./gradlew bootRun
```

## 📋 setup-project.sh 스크립트 기능

이 스크립트는 다음과 같은 작업을 자동으로 수행합니다:

### 수정되는 파일들
- `src/main/resources/application.properties` - 기본 설정
- `src/main/resources/application-dev.properties` - 데이터베이스 URL, 보안 설정
- `src/main/resources/application-test.properties` - 테스트 데이터베이스 URL 설정
- `src/main/resources/logback.xml` - 로깅 서비스명
- `docker-compose.yml` - MySQL 데이터베이스명
- `init.sql` - 데이터베이스 및 사용자 생성
- `grafana/dashboards/spring-boot-board.json` - Grafana 대시보드 설정

### 치환되는 패턴
- `project_name` → 입력한 프로젝트명 (소문자)
- `PROJECT_NAME` → 입력한 프로젝트명 (대문자, 데이터베이스용)

## 🛡️ 안전 기능

- **백업**: 원본 파일들은 타임스탬프가 포함된 백업 디렉토리에 자동 저장
- **유효성 검사**: 프로젝트명은 영문, 숫자, 하이픈(-), 언더스코어(_)만 허용
- **에러 처리**: 스크립트 실행 중 오류 발생 시 중단

## 📊 포함된 서비스

Docker Compose를 통해 다음 서비스들이 실행됩니다:

- **MySQL**: 데이터베이스
- **Redis**: 인-메모리 데이터베이스
- **Prometheus**: 메트릭 수집
- **Grafana**: 모니터링 대시보드
- **Loki**: 로그 수집

## 🔧 수동 설정 (필요한 경우)

스크립트를 사용하지 않고 수동으로 설정하려면:

1. 모든 설정 파일에서 `project_name`을 원하는 프로젝트명으로 변경
2. `init.sql`에서 `PROJECT_NAME`을 대문자 프로젝트명으로 변경
3. 필요에 따라 포트, 비밀번호 등 추가 설정 수정

## 🔍 문제 해결

### 스크립트 실행 권한 부여
```bash
chmod +x setup-project.sh
```

### Docker 실행 오류
```bash
# Docker가 실행중인지 확인
docker --version
docker compose --version

# 기존 컨테이너 정리 (필요시)
docker compose down
docker compose up -d
```

### 애플리케이션 실행 오류
```bash
# 빌드 디렉토리 정리
./gradlew clean

# 다시 실행
./gradlew bootRun
```

## 📝 추가 정보

- CI/CD 파이프라인을 위한 GitHub Actions 설정은 별도로 구성 예정
- 개발 환경에서는 `application-dev.properties` 프로필이 사용됩니다
- 모니터링은 Grafana (http://localhost:3000)에서 확인 가능