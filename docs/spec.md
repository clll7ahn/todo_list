# 일정관리 앱 - 기능 명세서 및 데이터 모델 상세 설계

## 1. 화면별 상세 기능 명세

---

### 1.1 홈 화면 (HomeScreen)

**경로**: `/`

**목적**: 할일 목록을 중심으로 앱의 메인 진입점

**UI 구성 요소**
- AppBar: 앱 제목, 검색 아이콘, 카테고리 관리 메뉴 버튼
- 검색 바: 검색 아이콘 탭 시 확장 (제목/설명 검색)
- 필터/정렬 칩 영역: 카테고리, 우선순위, 완료 상태 필터 + 정렬 기준
- 할일 목록: TodoCard 위젯 리스트 (스크롤 가능)
- FAB (FloatingActionButton): 새 할일 추가

**동작 흐름**

| 사용자 행동 | 시스템 반응 |
|------------|------------|
| 앱 실행 | 저장된 할일 전체 목록 표시 (미완료 우선, 마감일 오름차순) |
| 검색 아이콘 탭 | 검색 바 노출, 키보드 포커스 |
| 검색어 입력 | 제목/설명에 검색어 포함된 항목 실시간 필터링 |
| 검색 바 닫기 | 검색어 초기화, 전체 목록 복원 |
| 카테고리 필터 탭 | 해당 카테고리의 할일만 표시 |
| 우선순위 필터 탭 | 해당 우선순위의 할일만 표시 |
| 완료/미완료 필터 탭 | 해당 상태의 할일만 표시 |
| 정렬 기준 선택 | 마감일/우선순위/생성일/제목 기준 정렬 |
| TodoCard 탭 | 할일 편집 화면(`/todo/edit/:id`)으로 이동 |
| 완료 체크박스 탭 | 해당 할일 완료/미완료 토글, 목록 즉시 갱신 |
| 중요 표시 아이콘 탭 | isImportant 토글 |
| FAB 탭 | 할일 추가 화면(`/todo/add`)으로 이동 |
| AppBar 메뉴 → 카테고리 관리 | 카테고리 관리 화면(`/categories`)으로 이동 |
| 할일 롱프레스 | 삭제 확인 다이얼로그 표시 |

**에러 처리**
- 할일이 없는 경우: "할일이 없습니다. + 추가 버튼" 빈 상태 위젯 표시
- 검색 결과 없음: "검색 결과가 없습니다" 메시지 표시

---

### 1.2 할일 추가 화면 (TodoAddScreen)

**경로**: `/todo/add`

**목적**: 새 할일 생성

**UI 구성 요소**
- AppBar: "할일 추가" 제목, 닫기(X) 버튼
- 제목 입력 필드 (필수, 최대 100자)
- 설명 입력 필드 (선택, 최대 500자, 멀티라인)
- 카테고리 선택 드롭다운
- 우선순위 선택 칩 (높음/중간/낮음)
- 마감일 선택 버튼 → DateTimePicker
- 중요 표시 토글 스위치
- 반복 설정 드롭다운 (없음/매일/매주/매월)
- 서브태스크 영역: 하위 항목 목록 + 추가 버튼
- 저장 버튼 (AppBar 또는 하단)

**동작 흐름**

| 사용자 행동 | 시스템 반응 |
|------------|------------|
| 화면 진입 | 빈 폼 표시, 제목 필드 자동 포커스 |
| 마감일 선택 버튼 탭 | DatePicker 표시 → 날짜 선택 → TimePicker 표시 |
| 서브태스크 추가 버튼 탭 | 서브태스크 텍스트 입력 필드 추가 |
| 서브태스크 삭제 | 해당 서브태스크 입력 필드 제거 |
| 저장 버튼 탭 (유효) | Todo 생성 후 홈 화면으로 복귀, 성공 스낵바 표시 |
| 저장 버튼 탭 (무효) | 제목 미입력 시 필드 하이라이트 + 에러 메시지 |
| 닫기(X) 버튼 탭 | 변경사항 있으면 확인 다이얼로그 → 홈 화면으로 복귀 |

**에러 처리**
- 제목 미입력: "제목을 입력해주세요" 유효성 검사 메시지
- 마감일이 과거인 경우: 경고 스낵바 표시 (저장은 허용)

---

### 1.3 할일 편집 화면 (TodoEditScreen)

**경로**: `/todo/edit/:id`

**목적**: 기존 할일 수정

**UI 구성 요소**: 추가 화면과 동일하나 기존 데이터 프리필

**동작 흐름**

| 사용자 행동 | 시스템 반응 |
|------------|------------|
| 화면 진입 | todo ID로 데이터 조회 후 폼에 자동 입력 |
| 저장 버튼 탭 (유효) | Todo 수정 후 홈 화면으로 복귀, 성공 스낵바 표시 |
| 삭제 버튼 탭 | 삭제 확인 다이얼로그 → 확인 시 삭제 후 홈 화면 복귀 |
| 닫기(X) 버튼 탭 | 변경사항 있으면 확인 다이얼로그 → 이전 화면으로 복귀 |

**에러 처리**
- 존재하지 않는 ID: 에러 메시지 표시 후 홈 화면으로 복귀

---

### 1.4 카테고리 관리 화면 (CategoryScreen)

**경로**: `/categories`

**목적**: 카테고리 생성, 수정, 삭제

**UI 구성 요소**
- AppBar: "카테고리 관리" 제목, 뒤로가기 버튼
- 카테고리 목록: CategoryTile 위젯 리스트 (색상 + 아이콘 + 이름 + 편집/삭제 버튼)
- FAB: 새 카테고리 추가

**동작 흐름**

| 사용자 행동 | 시스템 반응 |
|------------|------------|
| 화면 진입 | 저장된 카테고리 목록 표시 |
| FAB 탭 | 카테고리 추가 다이얼로그 표시 (이름, 색상, 아이콘 선택) |
| 편집 아이콘 탭 | 카테고리 편집 다이얼로그 표시 |
| 삭제 아이콘 탭 | 삭제 확인 다이얼로그 → 확인 시 카테고리 삭제 |
| 다이얼로그 저장 (유효) | 카테고리 저장, 목록 갱신 |
| 다이얼로그 저장 (무효) | "이름을 입력해주세요" 에러 메시지 |

**에러 처리**
- 카테고리 삭제 시 해당 카테고리에 속한 할일: categoryId를 null로 초기화
- 카테고리 이름 중복: 경고 메시지 표시
- 카테고리가 없는 경우: "카테고리가 없습니다" 빈 상태 위젯 표시

---

### 1.5 캘린더 뷰 화면 (CalendarScreen)

**경로**: `/calendar`

**목적**: 월간 캘린더에서 날짜별 할일 확인

**UI 구성 요소**
- AppBar: "캘린더" 제목
- 월간 캘린더 위젯 (TableCalendar 스타일)
  - 이전/다음 월 이동 버튼
  - 날짜별 할일 존재 여부 표시 (도트 마커)
  - 선택된 날짜 하이라이트
- 선택 날짜의 할일 목록 (하단 영역)
- FAB: 선택된 날짜로 새 할일 추가

**동작 흐름**

| 사용자 행동 | 시스템 반응 |
|------------|------------|
| 화면 진입 | 오늘 날짜 선택, 오늘의 할일 목록 표시 |
| 날짜 탭 | 해당 날짜의 할일 목록 표시 |
| 이전/다음 월 이동 | 해당 월의 캘린더 표시, 도트 마커 갱신 |
| 할일 항목 탭 | 할일 편집 화면으로 이동 |
| FAB 탭 | 선택된 날짜가 마감일로 설정된 할일 추가 화면으로 이동 |

**에러 처리**
- 선택 날짜에 할일 없음: "이 날의 할일이 없습니다" 메시지 표시

---

### 1.6 통계 화면 (StatisticsScreen)

**경로**: `/statistics`

**목적**: 완료율, 카테고리 분포 등 대시보드 표시

**UI 구성 요소**
- AppBar: "통계" 제목
- 요약 카드: 전체/완료/미완료/중요 할일 수
- 완료율 원형 차트 (fl_chart 또는 커스텀 Painter)
- 카테고리별 분포 바 차트
- 주간/월간 완료 트렌드 라인 차트
- 우선순위별 분포 표시

**동작 흐름**

| 사용자 행동 | 시스템 반응 |
|------------|------------|
| 화면 진입 | 현재 저장된 모든 데이터 기반 통계 계산 후 차트 표시 |
| 주간/월간 탭 전환 | 해당 기간의 트렌드 차트 갱신 |

**에러 처리**
- 데이터 없음: "통계를 표시할 데이터가 없습니다" 메시지 표시

---

### 1.7 설정 화면 (SettingsScreen)

**경로**: `/settings`

**목적**: 앱 설정 관리

**UI 구성 요소**
- AppBar: "설정" 제목
- 다크모드 토글 스위치
- 데이터 초기화 버튼
- 앱 버전 표시

**동작 흐름**

| 사용자 행동 | 시스템 반응 |
|------------|------------|
| 다크모드 토글 | 즉시 테마 전환, shared_preferences에 저장 |
| 데이터 초기화 탭 | 삭제 확인 다이얼로그 → 확인 시 모든 할일/카테고리 삭제 |

**에러 처리**
- 데이터 초기화 실패: 에러 스낵바 표시

---

## 2. 화면 간 네비게이션 흐름

```
하단 네비게이션 바 (BottomNavigationBar)
├── 홈 (/)
│   ├── → 할일 추가 (/todo/add)          [FAB 탭]
│   │   └── → 홈 (/)                    [저장/닫기]
│   ├── → 할일 편집 (/todo/edit/:id)    [항목 탭]
│   │   └── → 홈 (/)                    [저장/삭제/닫기]
│   └── → 카테고리 관리 (/categories)   [AppBar 메뉴]
│       └── → 홈 (/)                    [뒤로가기]
├── 캘린더 (/calendar)
│   ├── → 할일 추가 (/todo/add)          [FAB 탭 - 날짜 프리셋]
│   └── → 할일 편집 (/todo/edit/:id)    [항목 탭]
├── 통계 (/statistics)
└── 설정 (/settings)
```

**go_router 라우트 정의**
```dart
/            → HomeScreen (ShellRoute with BottomNav)
/calendar    → CalendarScreen
/statistics  → StatisticsScreen
/settings    → SettingsScreen
/todo/add    → TodoAddScreen
/todo/edit/:id → TodoEditScreen
/categories  → CategoryScreen
```

---

## 3. 데이터 모델 상세 설계

---

### 3.1 Todo 모델

**파일**: `lib/models/todo.dart`

```dart
// 우선순위 열거형
enum Priority { high, medium, low }

// 반복 유형 열거형
enum RepeatType { none, daily, weekly, monthly }
```

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| id | String | O | UUID v4 자동 생성 | 고유 식별자 |
| title | String | O | - | 할일 제목 (1~100자) |
| description | String | X | '' | 상세 설명 (최대 500자) |
| categoryId | String? | X | null | 카테고리 참조 ID |
| priority | Priority | O | Priority.medium | 우선순위 |
| dueDate | DateTime? | X | null | 마감일시 |
| isCompleted | bool | O | false | 완료 여부 |
| isImportant | bool | O | false | 중요 표시 여부 |
| repeatType | RepeatType | O | RepeatType.none | 반복 유형 |
| subtasks | List\<Subtask\> | O | [] | 하위 작업 목록 |
| createdAt | DateTime | O | 생성 시각 | 생성 일시 |
| updatedAt | DateTime | O | 생성 시각 | 최종 수정 일시 |

**JSON 직렬화 스펙**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Flutter 앱 개발",
  "description": "할일 관리 앱 개발 완료",
  "categoryId": "cat-001",
  "priority": "high",
  "dueDate": "2026-02-28T23:59:00.000",
  "isCompleted": false,
  "isImportant": true,
  "repeatType": "none",
  "subtasks": [
    {
      "id": "sub-001",
      "title": "UI 설계",
      "isCompleted": true
    }
  ],
  "createdAt": "2026-02-22T10:00:00.000",
  "updatedAt": "2026-02-22T10:00:00.000"
}
```

**직렬화 규칙**
- `priority`: 열거형 → `"high"` / `"medium"` / `"low"` 문자열
- `repeatType`: 열거형 → `"none"` / `"daily"` / `"weekly"` / `"monthly"` 문자열
- `dueDate`: `null` 또는 ISO 8601 형식 문자열
- `subtasks`: 내포 객체 배열

---

### 3.2 Category 모델

**파일**: `lib/models/category.dart`

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| id | String | O | UUID v4 자동 생성 | 고유 식별자 |
| name | String | O | - | 카테고리 이름 (1~30자) |
| color | int | O | 0xFF2196F3 | 색상 코드 (ARGB int) |
| icon | int | O | 0xe047 (Icons.label) | 아이콘 코드포인트 |

**JSON 직렬화 스펙**

```json
{
  "id": "cat-001",
  "name": "업무",
  "color": 4278190335,
  "icon": 57671
}
```

**직렬화 규칙**
- `color`: Flutter Color의 `.value` (int) 저장 및 복원
- `icon`: IconData.codePoint (int) 저장, 복원 시 `IconData(codePoint, fontFamily: 'MaterialIcons')`

**기본 카테고리 (앱 최초 실행 시 자동 생성)**

| 이름 | 색상 | 아이콘 |
|------|------|--------|
| 업무 | 파랑 (#2196F3) | work |
| 개인 | 초록 (#4CAF50) | person |
| 쇼핑 | 주황 (#FF9800) | shopping_cart |
| 건강 | 빨강 (#F44336) | favorite |

---

### 3.3 Subtask 모델

**파일**: `lib/models/subtask.dart`

| 필드명 | 타입 | 필수 | 기본값 | 설명 |
|--------|------|------|--------|------|
| id | String | O | UUID v4 자동 생성 | 고유 식별자 |
| title | String | O | - | 하위 작업 제목 (1~100자) |
| isCompleted | bool | O | false | 완료 여부 |

**JSON 직렬화 스펙**

```json
{
  "id": "sub-001",
  "title": "UI 설계",
  "isCompleted": false
}
```

---

## 4. 로컬 저장소 키 구조

**저장소**: `shared_preferences`

| 키 | 타입 | 설명 | 예시 값 |
|----|------|------|---------|
| `todos` | String (JSON) | 전체 Todo 목록 | `[{...}, {...}]` |
| `categories` | String (JSON) | 전체 Category 목록 | `[{...}, {...}]` |
| `settings_dark_mode` | bool | 다크모드 활성화 여부 | `false` |
| `settings_initialized` | bool | 앱 최초 실행 여부 (기본 데이터 생성 플래그) | `false` |

**저장 전략**
- Todo/Category 변경 시 전체 목록을 JSON 직렬화하여 단일 키에 저장
- 앱 시작 시 전체 목록 일괄 로드 후 메모리(Provider)에서 관리
- 변경 시 Provider 상태 갱신 → 자동으로 shared_preferences 동기화

**서비스 파일**: `lib/services/storage_service.dart`

```dart
// 주요 메서드
Future<List<Todo>> loadTodos()
Future<void> saveTodos(List<Todo> todos)
Future<List<Category>> loadCategories()
Future<void> saveCategories(List<Category> categories)
Future<bool> getDarkMode()
Future<void> setDarkMode(bool value)
Future<void> clearAll()  // 데이터 초기화
```

---

## 5. Provider 구조

| Provider 클래스 | 파일 | 담당 상태 |
|----------------|------|----------|
| `TodoProvider` | `lib/providers/todo_provider.dart` | 할일 목록, 필터, 정렬, CRUD |
| `CategoryProvider` | `lib/providers/category_provider.dart` | 카테고리 목록 CRUD |
| `ThemeProvider` | `lib/providers/theme_provider.dart` | 다크모드 설정 |

**멀티 Provider 설정** (`lib/main.dart`)
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => CategoryProvider()),
    ChangeNotifierProvider(create: (_) => TodoProvider()),
  ],
  child: const MyApp(),
)
```

---

## 6. 에러 처리 공통 전략

| 상황 | 처리 방법 |
|------|----------|
| 저장소 읽기 실패 | 빈 목록으로 초기화, 에러 로그 출력 |
| 저장소 쓰기 실패 | 에러 스낵바 표시 ("저장에 실패했습니다. 다시 시도해주세요.") |
| 필수 필드 미입력 | 해당 필드 아래 유효성 검사 메시지 표시 |
| 존재하지 않는 ID 접근 | 에러 메시지 후 홈 화면으로 이동 |
| 알 수 없는 예외 | 콘솔 에러 로그, 사용자에게 일반 에러 메시지 표시 |
