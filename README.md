# 스프링부트 애플리케이션 템플릿 설정 가이드

이 프로젝트는 해커톤이나 빠른 개발을 위한 스프링부트 애플리케이션 템플릿입니다.
모니터링, CI/CD, Docker 환경이 사전 구성되어 있어 바로 개발을 시작할 수 있습니다.

## 📁 프로젝트 구조

- **spring-cicd-template/**: EC2 서버에서 사용할 인프라 스크립트들 (git submodule)
- **src/**: Spring Boot 애플리케이션 소스 코드
- **.github/workflows/**: GitHub Actions CI/CD 파이프라인
- **grafana/**: Grafana 대시보드 및 설정

## 🚀 빠른 시작

### 1. 프로젝트 복제
```bash
git clone <repository-url>
cd <project-directory>
git submodule update --init --recursive
```

### 2. 프로젝트 설정
```bash
# 프로젝트명, 그룹ID, 아티팩트ID 설정
./setup-project.sh my-spring-app com.mycompany myapp
```

### 3. Docker 환경 실행
```bash
# Docker 컨테이너들을 백그라운드에서 실행
docker compose up -d
```

### 4. 애플리케이션 실행
```bash
# 스프링부트 애플리케이션 실행 (개발환경)
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
- `.github/workflows/CI.yml, CICD/yml` - CI/CD 파이프라인 설정

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
   - `.github/workflows/CI.yml`
   - `.github/workflows/CICD.yml`
   - `src/main/resources/application-*.properties`
   - `docker-compose.yml`
   - `grafana/dashboards/spring-boot-board.json`
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

## 🚀 CI/CD 배포 설정

### GitHub Secrets 설정

GitHub 저장소의 Settings > Secrets and variables > Actions에서 다음 secrets을 설정하세요:

#### 필수 Secrets
- `DATABASE_URL`: 데이터베이스 URL (예: `jdbc:mysql://host.docker.internal:3306/myapp`)
- `DATABASE_USERNAME`: 데이터베이스 사용자명
- `DATABASE_PASSWORD`: 데이터베이스 비밀번호
- `SECURITY_USERNAME`: Spring Security 사용자명
- `SECURITY_PASSWORD`: Spring Security 비밀번호
- `REDIS_HOST`: Redis 호스트 (예: `host.docker.internal`)
- `REDIS_PORT`: Redis 포트 (예: `6379`)
- `SERVER_URL`: API 서버 URL (예: `http://13.209.96.85`) - **프로토콜 포함 필수**
- `DOCKER_USERNAME`: Docker Hub 사용자명
- `DOCKER_PASSWORD`: Docker Hub Access Token
- `DOCKERHUB_REPOSITORY`: Docker Hub 저장소명 (예: `myapp`)

#### 배포 관련 Secrets
- `SERVER_REMOTE_IP`: EC2 인스턴스 IP 주소 (SSH 접속용)
- `SERVER_REMOTE_USER`: EC2 사용자명 (예: `ubuntu`)
- `SERVER_REMOTE_PRIVATE_KEY`: EC2 접속용 Private Key (.pem 파일 내용)
- `SERVER_REMOTE_SSH_PORT`: SSH 포트 (기본: `22`)

### 환경별 설정

#### 로컬 개발환경
- Profile: `dev`
- 데이터베이스: `localhost:3306`
- 모니터링: `localhost:3000` (Grafana), `localhost:9090` (Prometheus)

#### 운영환경 (EC2)
- Profile: `prod`
- 데이터베이스: 컨테이너 네트워크 내부 통신
- 로그: Loki로 자동 전송
- 모니터링: 설정된 도메인/IP로 접근

### 배포 프로세스

1. **EC2 인스턴스 준비**: `spring-cicd-template/` 디렉토리의 스크립트를 사용하여 EC2 인스턴스에 인프라 환경을 구축합니다.
2. **코드 푸시**: `main` 브랜치에 푸시
3. **CI 단계**: 
   - 테스트 실행
   - JAR 파일 빌드
   - Docker 이미지 빌드 및 푸시
4. **배포 단계**: 
   - EC2 서버에 SSH 접속
   - 롤링 업데이트 실행
   - 헬스체크 확인

> **중요**: CI/CD 파이프라인을 사용하기 전에 EC2 인스턴스에서 `spring-cicd-template/` 디렉토리의 스크립트들을 실행하여 필요한 인프라 환경(Docker, 네트워크, 모니터링 스택 등)을 먼저 구축해야 합니다. 자세한 내용은 `spring-cicd-template/README.md`를 참조하세요.

## 📝 추가 정보

- 개발 환경에서는 `application-dev.properties` 프로필이 사용됩니다
- 운영 환경에서는 GitHub Actions에서 생성한 `application-prod.properties`가 사용됩니다
- 모니터링은 Grafana에서 확인 가능합니다
- 로그는 Loki를 통해 중앙 집중식으로 관리됩니다