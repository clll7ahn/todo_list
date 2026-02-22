# 일정관리 앱 - 요구사항 명세서 (TodoMaster)

*작성일: 2026-02-22 | 작성자: PM | 버전: 1.1*

---

## 1. 프로젝트 개요

### 프로젝트명
**TodoMaster** - 최고의 Flutter 일정관리 앱

### 목적
사용자가 일상의 할 일을 효율적으로 관리할 수 있도록 직관적이고 강력한 일정관리 앱을 제공합니다.
개인 생산성 극대화를 위해 우선순위 기반 작업 관리, 반복 일정, 캘린더 통합, 통계 시각화 등 최고 수준의 기능을 제공합니다.

### 개발 환경
- **플랫폼**: Android (API 21+) / iOS (12.0+)
- **프레임워크**: Flutter (최신 stable 버전)
- **언어**: Dart
- **프로젝트 경로**: `D:\flutter\todo_list`

---

## 2. 기술 스택

| 분류 | 기술 | 버전 | 용도 |
|------|------|------|------|
| 프레임워크 | Flutter | stable 최신 | 크로스 플랫폼 앱 개발 |
| 언어 | Dart | - | 메인 개발 언어 |
| 상태 관리 | Provider | ^6.0.0 | 전역 상태 관리 |
| 라우팅 | go_router | ^14.0.0 | 화면 간 네비게이션 |
| 로컬 저장소 | shared_preferences | ^2.0.0 | 설정 및 데이터 영속성 |
| 고유 ID | uuid | ^4.0.0 | 할일/카테고리 ID 생성 |
| 날짜 포맷 | intl | ^0.19.0 | 날짜/시간 포맷팅 |
| 캘린더 | table_calendar | ^3.0.0 | 캘린더 뷰 위젯 |
| 차트 | fl_chart | ^0.68.0 | 통계 시각화 |
| UI | Material Design 3 | - | 기본 UI 컴포넌트 |

---

## 3. 핵심 기능 목록 (우선순위순)

### P0 - 필수 기능 (Must Have)

| # | 기능 | 상세 설명 |
|---|------|-----------|
| 1 | **할일 CRUD** | 할일 생성, 조회, 수정, 삭제. 제목(필수), 설명(선택) 포함 |
| 2 | **완료 체크** | 체크박스로 할일 완료/미완료 토글. 완료 시 취소선 표시 |
| 3 | **카테고리** | 할일을 카테고리별로 그룹화. 색상 및 아이콘 구분 |
| 4 | **우선순위** | 높음(빨강)/중간(노랑)/낮음(초록) 3단계 시각적 구분 |
| 5 | **마감일/시간** | DatePicker + TimePicker로 마감일 및 시간 설정 |
| 6 | **하단 네비게이션** | 홈/캘린더/통계/설정 간 전환 |

### P1 - 중요 기능 (Should Have)

| # | 기능 | 상세 설명 |
|---|------|-----------|
| 7 | **하위 작업** | 할일에 체크리스트형 서브태스크 추가/삭제 |
| 8 | **검색** | 제목/설명 텍스트 실시간 검색 |
| 9 | **필터/정렬** | 카테고리별, 우선순위별, 상태별 필터; 마감일/우선순위/생성일 정렬 |
| 10 | **중요 표시** | 별표(★)로 중요 할일 표시 및 필터 |
| 11 | **메모/설명** | 할일에 멀티라인 상세 설명 추가 |
| 12 | **캘린더 뷰** | 월간 캘린더에서 마감일 기준 일정 확인 |
| 13 | **다크모드** | 라이트/다크/시스템 테마 전환 |

### P2 - 부가 기능 (Nice to Have)

| # | 기능 | 상세 설명 |
|---|------|-----------|
| 14 | **반복 일정** | 매일/매주/매월 반복 규칙 설정 |
| 15 | **통계 대시보드** | 완료율 원형 차트, 카테고리 분포, 주간 트렌드 막대그래프 |
| 16 | **카테고리 관리 화면** | 카테고리 추가/편집/삭제 전용 화면 |

---

## 4. 화면 목록 및 설명

### 4.1 홈 화면 (Home Screen) - `/`
- **역할**: 앱 메인 진입점, 할일 목록 표시
- **구성요소**:
  - 앱바: 앱 제목, 검색 아이콘, 필터/정렬 버튼
  - 탭바: 오늘 | 예정 | 전체 | 완료
  - 할일 목록 (ListView): 우선순위 색상 바, 제목, 마감일, 카테고리 태그, 완료 체크박스
  - FloatingActionButton: 할일 추가 (+)
  - 하단 네비게이션 바
- **인터랙션**:
  - 할일 카드 탭 → 편집 화면으로 이동
  - 할일 카드 스와이프 → 삭제
  - 완료 체크박스 탭 → 완료 토글

### 4.2 할일 추가/편집 화면 (Todo Form Screen) - `/todo/add`, `/todo/edit/:id`
- **역할**: 할일 생성 및 수정 폼
- **구성요소**:
  - 제목 입력 (필수)
  - 설명/메모 입력 (선택, 멀티라인)
  - 마감일 선택 (DatePicker)
  - 마감시간 선택 (TimePicker)
  - 우선순위 선택 (높음/중간/낮음 칩 버튼)
  - 카테고리 선택 (드롭다운)
  - 중요 표시 토글 (스위치)
  - 반복 설정 (없음/매일/매주/매월)
  - 하위 작업 목록 (추가/삭제)
  - 저장 / 취소 버튼

### 4.3 카테고리 관리 화면 (Category Screen) - `/categories`
- **역할**: 카테고리 목록 관리
- **구성요소**:
  - 카테고리 목록: 아이콘, 색상, 이름, 해당 카테고리 할일 수
  - 카테고리 추가 버튼 (FAB)
  - 카테고리 편집/삭제 (스와이프 또는 탭)

### 4.4 캘린더 뷰 화면 (Calendar Screen) - `/calendar`
- **역할**: 월간 캘린더에서 일정 확인
- **구성요소**:
  - 월간 캘린더 위젯 (table_calendar)
  - 날짜에 마감일 있는 할일 점(dot) 표시
  - 선택 날짜 아래 해당 날짜 할일 목록

### 4.5 통계/대시보드 화면 (Stats Screen) - `/stats`
- **역할**: 할일 현황 통계 시각화
- **구성요소**:
  - 전체 완료율 (원형 진행 표시)
  - 오늘 완료/미완료 카운트 카드
  - 카테고리별 할일 분포 (파이차트)
  - 주간 완료 추이 (막대그래프)
  - 우선순위별 통계

### 4.6 설정 화면 (Settings Screen) - `/settings`
- **역할**: 앱 설정 및 환경 구성
- **구성요소**:
  - 테마 설정 (라이트/다크/시스템 선택)
  - 기본 정렬 방식 설정
  - 카테고리 관리 링크
  - 앱 정보 (버전)

---

## 5. 네비게이션 구조

```
앱 시작
  └─ 홈 화면 (/)
       ├─ [+] FAB → 할일 추가 (/todo/add)
       ├─ 할일 카드 탭 → 할일 편집 (/todo/edit/:id)
       └─ 하단 네비게이션
            ├─ 홈 (/)
            ├─ 캘린더 (/calendar)
            │    └─ 날짜 탭 → 할일 추가/편집
            ├─ 통계 (/stats)
            └─ 설정 (/settings)
                 └─ 카테고리 관리 (/categories)
```

---

## 6. 데이터 모델

### Todo (할일)
```dart
class Todo {
  final String id;              // 고유 ID (UUID)
  final String title;           // 제목 (필수)
  final String? description;    // 설명/메모 (선택)
  final String? categoryId;     // 카테고리 ID 참조
  final Priority priority;      // 우선순위 (high/medium/low)
  final DateTime? dueDate;      // 마감일
  final bool isCompleted;       // 완료 여부
  final bool isImportant;       // 중요(별표) 표시
  final RepeatType repeatType;  // 반복 유형
  final List<SubTask> subTasks; // 하위 작업 목록
  final DateTime createdAt;     // 생성일시
  final DateTime updatedAt;     // 수정일시
}

enum Priority { high, medium, low }
enum RepeatType { none, daily, weekly, monthly }
```

### Category (카테고리)
```dart
class Category {
  final String id;       // 고유 ID (UUID)
  final String name;     // 카테고리명
  final int color;       // 색상 값 (Color.value)
  final int icon;        // 아이콘 코드 (IconData.codePoint)
  final DateTime createdAt;
}
```

### SubTask (하위 작업)
```dart
class SubTask {
  final String id;
  final String title;
  final bool isCompleted;
}
```

---

## 7. 완료 기준 (Definition of Done)

### 기능 완료 기준
- [ ] 모든 P0 기능 정상 동작 확인
- [ ] 모든 P1 기능 정상 동작 확인
- [ ] 최소 통계 화면(P2) 구현
- [ ] 6개 화면 모두 구현 완료
- [ ] 하단 네비게이션으로 화면 간 이동 정상 동작
- [ ] 앱 재시작 후 데이터 유지 (로컬 저장소 영속성)
- [ ] 다크모드 전환 정상 동작

### 코드 품질 기준
- [ ] `flutter analyze` 오류/경고 없음
- [ ] `flutter test` 통과 (주요 Provider, Service 단위 테스트)
- [ ] 모든 UI 텍스트 한국어 작성
- [ ] `const` 위젯 적극 활용
- [ ] 비즈니스 로직 Provider/Service 분리
- [ ] 파일명 snake_case, 클래스명 PascalCase, 주석 한국어

### 산출물 기준
- [ ] 앱 정상 빌드 및 에뮬레이터/실기기 실행 확인
- [ ] `사용가이드.md` 작성 완료 (실행 방법 포함)
