#!/bin/bash

# 스프링부트 애플리케이션 템플릿 설정 스크립트
# 사용법: ./setup-project.sh <프로젝트명> <그룹명> <아티팩트명>

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 프로젝트명과 패키지명 입력 확인 (3개 모두 필수)
if [ $# -ne 3 ]; then
    print_error "3개의 파라미터를 모두 입력해주세요."
    echo "사용법: ./setup-project.sh <프로젝트명> <그룹명> <아티팩트명>"
    echo "예시: ./setup-project.sh my-spring-app com.mycompany myapp"
    echo ""
    echo "파라미터 설명:"
    echo "  <프로젝트명>: 소문자, 숫자, 하이픈(-) 사용 가능"
    echo "  <그룹명>: Java 패키지명 형식 (예: com.mycompany)"
    echo "  <아티팩트명>: 소문자, 숫자만 사용 가능 (예: myapp)"
    exit 1
fi

PROJECT_NAME=$1
GROUP_ID=$2
ARTIFACT_ID=$3

# 프로젝트명 유효성 검사 (소문자, 숫자, 하이픈만 허용)
if [[ ! $PROJECT_NAME =~ ^[a-z0-9-]+$ ]]; then
    print_error "프로젝트명은 소문자, 숫자, 하이픈(-)만 사용할 수 있습니다."
    exit 1
fi

# 그룹ID 유효성 검사 (패키지명 형식)
if [[ ! $GROUP_ID =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$ ]]; then
    print_error "그룹ID는 유효한 패키지명 형식이어야 합니다. (예: com.example)"
    exit 1
fi

# 아티팩트ID 유효성 검사 (소문자, 숫자만 허용)
if [[ ! $ARTIFACT_ID =~ ^[a-z][a-z0-9]*$ ]]; then
    print_error "아티팩트ID는 소문자와 숫자만 사용할 수 있습니다. (예: demo)"
    exit 1
fi

# 대문자 변환 (DATABASE 이름용)
PROJECT_NAME_UPPER=$(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

# 패키지 경로 생성
GROUP_PATH=$(echo "$GROUP_ID" | tr '.' '/')

# 클래스명 생성 (카멜케이스)
CLASS_NAME=$(echo "$ARTIFACT_ID" | sed 's/\b\w/\U&/g')

print_info "프로젝트 설정을 시작합니다..."
print_info "프로젝트명: $PROJECT_NAME"
print_info "그룹ID: $GROUP_ID"
print_info "아티팩트ID: $ARTIFACT_ID"
print_info "클래스명: ${CLASS_NAME}Application"
print_info "데이터베이스명: $PROJECT_NAME_UPPER"

# 이미 설정된 프로젝트인지 확인
if [ ! -d "src/main/java/com/example/demo" ]; then
    print_error "이미 설정된 프로젝트이거나 올바른 템플릿 구조가 아닙니다."
    print_info "원본 템플릿에서 다시 시작해주세요."
    exit 1
fi

# 백업 디렉토리 생성
BACKUP_DIR=".template-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 수정할 파일들 백업
print_info "원본 파일들을 백업중입니다..."
cp src/main/resources/application.properties "$BACKUP_DIR/"
cp src/main/resources/application-dev.properties "$BACKUP_DIR/"
cp src/main/resources/application-test.properties "$BACKUP_DIR/"
cp src/main/resources/logback.xml "$BACKUP_DIR/"
cp docker-compose.yml "$BACKUP_DIR/"
cp init.sql "$BACKUP_DIR/"
cp grafana/dashboards/spring-boot-board.json "$BACKUP_DIR/"

# Java 소스 파일들도 백업
cp -r src/main/java "$BACKUP_DIR/"
cp -r src/test/java "$BACKUP_DIR/"

# 파일들 수정
print_info "설정 파일들을 수정중입니다..."

# 0. application.properties 수정
sed -i.bak "s/demo/$PROJECT_NAME/g" src/main/resources/application.properties
rm src/main/resources/application.properties.bak

# 1. application-dev.properties 수정
sed -i.bak "s/project_name/$PROJECT_NAME/g" src/main/resources/application-dev.properties
rm src/main/resources/application-dev.properties.bak

# 2. application-test.properties 수정
sed -i.bak "s/project_name/$PROJECT_NAME/g" src/main/resources/application-test.properties
rm src/main/resources/application-test.properties.bak

# 3. logback.xml 수정
sed -i.bak "s/project_name/$PROJECT_NAME/g" src/main/resources/logback.xml
rm src/main/resources/logback.xml.bak

# 4. docker-compose.yml 수정
sed -i.bak "s/project_name/$PROJECT_NAME/g" docker-compose.yml
rm docker-compose.yml.bak

# 5. init.sql 수정
sed -i.bak "s/PROJECT_NAME/$PROJECT_NAME_UPPER/g; s/project_name/$PROJECT_NAME/g" init.sql
rm init.sql.bak

# 6. grafana dashboard 수정
sed -i.bak "s/project_name/$PROJECT_NAME/g" grafana/dashboards/spring-boot-board.json
rm grafana/dashboards/spring-boot-board.json.bak

# 7. Java 패키지 구조 변경
print_info "Java 패키지 구조를 변경중입니다..."

# 새로운 패키지 디렉토리 생성
mkdir -p "src/main/java/$GROUP_PATH/$ARTIFACT_ID"
mkdir -p "src/test/java/$GROUP_PATH/$ARTIFACT_ID"

# Java 파일들 이동 및 패키지명, 클래스명 수정
find src/main/java/com/example/demo -name "*.java" -type f | while read file; do
    # 새 파일 경로 계산
    relative_path=${file#src/main/java/com/example/demo/}
    
    # 클래스명 변경 (DemoApplication -> ${CLASS_NAME}Application)
    if [[ "$relative_path" == "DemoApplication.java" ]]; then
        new_file="src/main/java/$GROUP_PATH/$ARTIFACT_ID/${CLASS_NAME}Application.java"
    else
        new_dir="src/main/java/$GROUP_PATH/$ARTIFACT_ID/$(dirname "$relative_path")"
        new_file="src/main/java/$GROUP_PATH/$ARTIFACT_ID/$relative_path"
        mkdir -p "$new_dir"
    fi
    
    # 파일 내용에서 패키지명과 클래스명 변경 후 새 위치에 복사
    sed "s/package com\.example\.demo/package $GROUP_ID.$ARTIFACT_ID/g; s/import com\.example\.demo/import $GROUP_ID.$ARTIFACT_ID/g; s/class DemoApplication/class ${CLASS_NAME}Application/g; s/DemoApplication\.class/${CLASS_NAME}Application.class/g" "$file" > "$new_file"
done

find src/test/java/com/example/demo -name "*.java" -type f | while read file; do
    # 새 파일 경로 계산
    relative_path=${file#src/test/java/com/example/demo/}
    
    # 클래스명 변경 (DemoApplicationTests -> ${CLASS_NAME}ApplicationTests)
    if [[ "$relative_path" == "DemoApplicationTests.java" ]]; then
        new_file="src/test/java/$GROUP_PATH/$ARTIFACT_ID/${CLASS_NAME}ApplicationTests.java"
    else
        new_dir="src/test/java/$GROUP_PATH/$ARTIFACT_ID/$(dirname "$relative_path")"
        new_file="src/test/java/$GROUP_PATH/$ARTIFACT_ID/$relative_path"
        mkdir -p "$new_dir"
    fi
    
    # 파일 내용에서 패키지명과 클래스명 변경 후 새 위치에 복사
    sed "s/package com\.example\.demo/package $GROUP_ID.$ARTIFACT_ID/g; s/import com\.example\.demo/import $GROUP_ID.$ARTIFACT_ID/g; s/class DemoApplicationTests/class ${CLASS_NAME}ApplicationTests/g" "$file" > "$new_file"
done

# 기존 com/example/demo 디렉토리 삭제
rm -rf src/main/java/com/example/demo
rm -rf src/test/java/com/example/demo

# 빈 디렉토리들 정리
find src/main/java/com -type d -empty -delete 2>/dev/null || true
find src/test/java/com -type d -empty -delete 2>/dev/null || true

# build 디렉토리가 있다면 정리
if [ -d "build" ]; then
    print_info "기존 빌드 파일들을 정리중입니다..."
    rm -rf build/
fi

print_success "프로젝트 설정이 완료되었습니다!"
echo
print_info "변경된 내용:"
echo -e "  - 프로젝트명: ${YELLOW}$PROJECT_NAME${NC}"
echo -e "  - 패키지: ${YELLOW}$GROUP_ID.$ARTIFACT_ID${NC}"
echo -e "  - 메인 클래스: ${YELLOW}${CLASS_NAME}Application${NC}"
echo -e "  - 테스트 클래스: ${YELLOW}${CLASS_NAME}ApplicationTests${NC}"
echo -e "  - 데이터베이스: ${YELLOW}$PROJECT_NAME_UPPER${NC}"
echo

print_info "🚀 애플리케이션 실행 방법:"
echo -e "1. Docker 컨테이너 실행: ${YELLOW}docker compose up -d${NC}"
echo -e "2-1. 터미널에서 실행: ${YELLOW}./gradlew bootRun${NC}"
echo -e "2-2. IntelliJ에서 실행: ${YELLOW}$GROUP_ID.$ARTIFACT_ID.${CLASS_NAME}Application${NC} 클래스 실행"
echo
print_warning "⚠️  IntelliJ 사용자 주의사항:"
echo "   IntelliJ 우측 상단의 실행 버튼이 기존 DemoApplication으로 설정되어 있을 수 있습니다."
echo -e "   ${YELLOW}Run Configuration${NC}을 ${YELLOW}${CLASS_NAME}Application${NC}으로 변경하거나"
echo "   메인 클래스를 직접 우클릭하여 실행해주세요."
echo

print_info "🗄️ 데이터베이스 접근 정보:"
echo -e "  - 호스트: ${YELLOW}localhost:3306${NC}"
echo -e "  - 데이터베이스: ${YELLOW}$PROJECT_NAME_UPPER${NC}"
echo -e "  - 사용자명: ${YELLOW}$PROJECT_NAME${NC}"
echo -e "  - 비밀번호: ${YELLOW}${PROJECT_NAME}_pw${NC}"
echo -e "  - Root 비밀번호: ${YELLOW}rootPW${NC}"
echo

print_info "📊 모니터링 서비스 접근 정보:"
echo -e "  - Grafana: ${YELLOW}http://localhost:3000${NC} (admin/admin)"
echo -e "  - Prometheus: ${YELLOW}http://localhost:9090${NC}"
echo -e "  - Redis: ${YELLOW}localhost:6379${NC}"
echo

print_info "🔍 애플리케이션 엔드포인트:"
echo -e "  - Swagger UI: ${YELLOW}http://localhost:8080/swagger-ui/index.html${NC} ($PROJECT_NAME/$PROJECT_NAME)"
echo -e "  - 헬스체크: ${YELLOW}http://localhost:8088/actuator/health${NC}"
echo -e "  - 메트릭: ${YELLOW}http://localhost:8088/actuator/metrics${NC}"
echo -e "  - 해쉬: ${YELLOW}http://localhost:8080/hash${NC}"
echo

print_info "백업 파일들은 ${YELLOW}$BACKUP_DIR${NC} 디렉토리에 저장되었습니다."
print_warning "설정이 완료되면 백업 디렉토리는 삭제하셔도 됩니다."