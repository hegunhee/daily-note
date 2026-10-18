# 앱 아키텍처

Flutter · Riverpod 3 · flutter_hooks · easy_localization. 기능(feature) 단위로 나눈
feature-first 구조입니다. 서버 없이 기기의 로컬 DB에 저장합니다. 구조와 규약은
포켓가계부(money_diary)와 같습니다.

## 디렉토리

```
lib/
├── main.dart             # 유일한 엔트리포인트 (플레이버 없음)
├── setup.dart            # Firebase·Crashlytics 초기화
├── core/                 # 의존성 없이 앱 전체에 적용되는 leaf 코드
│   └── themes/           # app_palette · app_colors · app_typography · app_spacing · app_layout · app_theme
├── shared/               # 여러 feature에서 중복되는 컴포넌트·코드
│   ├── models/           # Schedule · SubTask · ScheduleBook · ScheduleStatus
│   ├── repositories/     # 로컬 DB(Hive) 읽기·쓰기 (schedule_repository)
│   ├── controllers/      # 여러 화면이 쓰는 상태 (일정 · 보는 날짜 · 지금 시각)
│   ├── hooks/            # useNow (30초마다 다시 읽는 지금 시각)
│   ├── util/             # 계산(schedule_calculator) · 표기(schedule_labels) · id 생성
│   └── widgets/          # 공용 UI (카드 · 배지 · 체크박스 · 버튼 · 진행 바 · 삭제 확인)
└── features/<feature>/
    ├── models/           # 데이터 모델
    ├── repositories/     # 로컬 DB 읽기·쓰기
    ├── controllers/      # 상태 (Riverpod)
    ├── screens/          # 화면
    └── widgets/          # 이 feature 전용 위젯
```

- 의존은 **`features → shared → core`** 한 방향(역방향 금지).
  - **core** : 의존성 없이 앱 전체에 적용되는 기능(테마·순수 유틸).
  - **shared** : 여러 feature에서 중복되는 컴포넌트·코드(공용 위젯 등).
- feature: `timeline`(메인 — 날짜별 시간순 타임라인) · `schedule_form`(일정 등록·수정) · `schedule_detail`(일정 상세 — 세부 작업·메모 관리). 하위 폴더는 필요해질 때 만듭니다.

## 로컬 저장

- [hive_ce](https://pub.dev/packages/hive_ce) 로 기기에 저장합니다. 일정·세부 작업을 상자 하나씩
  (`schedules` · `sub_tasks`)에 id 를 키로, 모델의 `toJson()` 맵을 값으로 넣습니다(코드 생성 없음).
- `ScheduleRepository` 만 Hive 를 압니다. 테스트는 `test/helpers/fake_schedule_repository.dart` 의
  `FakeScheduleRepository` 로 바꿔 끼웁니다.
- 날짜는 `yyyy-MM-dd`, 시각은 `HH:mm` 문자열로 저장합니다. 모두 기기의 로컬 시간이며, 시간대가
  바뀌어도 일정 날짜가 밀리지 않습니다. 종료 시각은 시작 시각보다 늦어야 해서 자정을 넘기는
  일정은 없습니다.
- 일정을 지우면 그 일정의 세부 작업도 함께 지웁니다. 일정을 폼에서 다시 저장하면 그 일정의
  세부 작업 목록을 통째로 바꿉니다(빠진 작업은 지움).

## 일정 상태와 진행률

두 값은 서로 다른 개념이라 따로 계산합니다(`shared/util/schedule_calculator.dart`).

- **상태**(`ScheduleStatus`): 사용자가 완료 처리했으면 `done`, 아니면 지금 시각 기준으로
  시작 전 `upcoming` · 시작~종료 사이 `inProgress` · 종료 후 `past`. 세부 작업과 상관없습니다.
- **진행률**: 완료한 세부 작업 수 / 전체 수. 작업이 없으면 0%. 반올림하되 다 끝내기 전에는
  100%로 보이지 않게 99%에서 멈춥니다. 작업이 하나 이상 있고 모두 끝나면 "모든 작업 완료"로 표시합니다.
- 지금 시각은 `clockProvider` 로 읽습니다. 테스트는 시안의 시각(`designNow`)으로 고정합니다.
- 체크박스는 누르는 즉시 상태를 바꾸고 저장합니다. 저장에 실패하면 되돌립니다.

## 입력 검증

- 저장을 막는 사유는 `features/schedule_form/models/schedule_form_error.dart` 의 enum 과
  `validateSchedule` 순수 함수로 찾습니다(제목 비어 있음 · 종료 ≤ 시작).
- 시간 범위 오류는 고르는 즉시 시각 칸 아래에, 제목 오류는 저장을 한 번 눌러 본 뒤 제목 아래에
  알립니다. 저장 실패는 저장 버튼 위에 둡니다.
- 컨트롤러도 잘못된 시간 범위는 저장하지 않습니다(화면을 거치지 않는 호출 대비).
- 폼의 세부 작업은 저장할 때 일정과 함께 한 번에 저장합니다. 그래서 폼 안에서 뺀 작업은
  묻지 않고, 저장된 작업을 상세 화면에서 지울 때는 확인을 받습니다.

## 데이터 흐름

한 화면은 `Screen → Controller → Repository → 로컬 DB`로 흐릅니다.

- **Repository**: 로컬 DB를 읽고 써서 모델로 변환합니다. 단순 UI 상태뿐이면 두지 않습니다.
- **계산**: 정렬·진행률·상태 판단은 `shared/util/` 의 순수 함수에 둡니다. 화면과 컨트롤러는 결과만 씁니다.
- **Controller**: Riverpod. 동기 상태는 `NotifierProvider`, 비동기 상태는
  `AsyncNotifierProvider`. 상태는 **모델 그대로**(`X` · `List<X>` · `AsyncValue<X>`).
  감싸는 State 클래스 없음(예외는 아래 허가 목록).
```dart
final scheduleProvider =
    AsyncNotifierProvider<ScheduleController, ScheduleBook>(
  ScheduleController.new,
);
```

- **Screen**: `HookConsumerWidget`. 저장된 값은 `ref.watch`, 화면에서만 쓰는 값(입력값 ·
  펼침 · 진행 중 플래그 · 애니메이션)은 훅(`useState` · `useTextEditingController` …).

- ❌ `StateNotifierProvider`(구식) · `FutureProvider`(단순한 경우 외) · `setState` ·
  `StatefulWidget`(훅으로 대체) · `provider` 패키지 · 허가 목록에 없는 `*State` 클래스 ·
  record typedef 상태 묶음 금지.

### 예외 상태 클래스(`*State`)

모델 하나로 안 되고 훅으로도 안 될 때(화면보다 오래 살거나 여러 화면이 공유)만 씁니다.

- `models/xxx_state.dart`에 두고 필요한 이유를 한 줄 dartdoc으로 적습니다.
- `state_allowlist.txt`에 `이름 # 이유`로 올립니다. 새로 필요하면 같은 PR에서 추가합니다.
- `test/architecture/state_allowlist_test.dart`가 목록에 없는 `*State` · record typedef ·
  StatefulWidget의 State, `models/` 밖에 둔 State, 지워졌는데 목록에 남은 항목을 막습니다.

## 디자인 시스템

기준은 [docs/design/DESIGN.md](docs/design/DESIGN.md) 와 `docs/design/screens/` 의 화면별
Stitch 시안입니다. 코드에서는 `lib/core/themes/` 가 단일 출처입니다.

| 파일 | 역할 |
|---|---|
| `app_palette.dart` | 원시 색 토큰. hex 리터럴은 여기에만 둡니다 |
| `app_colors.dart` | 시맨틱 색(ThemeExtension). 라이트·다크 값을 함께 정의. 화면은 `context.colors` 로 읽음 |
| `app_typography.dart` | 글자 스타일. 폰트는 번들된 Pretendard(`assets/fonts/`) |
| `app_spacing.dart` | 간격 `AppSpacing` · 모서리 `AppRadius` |
| `app_layout.dart` | 본문 최대 폭, 최소 터치 영역 |
| `app_theme.dart` | `ThemeData`(라이트·다크), 앱바 틴트 끄기, 입력칸 테두리, 상태바 스타일 |

### 색

| 토큰 | 라이트 값 | 쓰는 곳 |
|---|---|---|
| `primary` / `primaryTint` | `#24734A` / `#E3F1E7` | 주 동작, 선택한 날짜, 체크, 완료된 줄·메모 바탕 |
| `accent` / `accentTint` / `onAccentTint` | `#F28C45` / `#FEF4EC` / `#984800` | **지금 진행 중인 일정만** — 왼쪽 띠, 타임라인 점, NOW 배지 |
| `background` / `surface` / `surfaceLow` | `#F5F7F3` / `#FFFFFF` / `#EFF3EC` | 화면 바탕 / 카드 / 카드 안의 입력칸 |
| `border` | `#E2E7DF` | 1px 테두리, 진행 바 트랙 |
| `textPrimary` / `textSecondary` / `textTertiary` | `#24352A` / `#5E685F` / `#788278` | 본문 / 설명 / 시각·완료된 글자 |

- 하드코딩 색 금지. 투명도는 `withValues(alpha:)`.
- Primary · Accent · Background 는 기획서 값입니다. 시안 PNG 와 DESIGN.md 상단 토큰은 더 짙은
  `#005A34` 와 민트 바탕 `#EAFFEE` 로 그려져 있지만, DESIGN.md 본문 설명과 기획서를 따릅니다.
- Accent `#F28C45` 는 흰 바탕 위 글자로는 대비가 모자라, 글자에는 `onAccentTint` 를 씁니다.
- 시안에 다크 화면이 없어 다크 값은 토큰의 inverse · fixed-dim 값에서 유도했습니다.

### 타이포

직접 `fontSize` 금지. 시각·날짜 숫자는 고정폭 숫자(tnum)가 켜진 `time*` 로 적습니다.

| 토큰 | 크기 / 줄 높이 · 굵기 |
|---|---|
| `headlineXl` / `headlineLg` / `headlineMd` / `headlineSm` | 32/40 Bold · 26/34 Bold · 20/28 SemiBold · 18/24 SemiBold |
| `bodyLg` / `bodyMd` / `bodySm` | 16/24 Medium · 14/20 · 13/18 Regular |
| `labelLg` / `labelMd` / `labelSm` | 14/20 · 12/16 SemiBold · 11/14 Medium |
| `timeLg` / `timeMd` / `timeSm` | 24/32 · 20/28 · 14/20 SemiBold, tnum |

### 간격·모양

- 간격 `AppSpacing`: `xs`=4 · `sm`=8 · `md`=12 · `lg`=16 · `xl`=24 · `xxl`=32, 화면 좌우 `gutter`=16.
- 모서리 `AppRadius`: `sm`=4 · `checkbox`=6 · `md`=8(배지·칩) · `lg`=12(카드·입력칸·버튼) ·
  `sheet`=20 · `full`.
- 탭 대상은 최소 44×44. 넓은 화면에서는 본문을 `AppContentWidth`(최대 480)로 묶습니다.

### 공용 위젯 (`lib/shared/widgets/`)

| 위젯 | 쓰는 곳 |
|---|---|
| `AppCard` | 흰 카드 + 1px 테두리. `accentColor` 를 주면 왼쪽 3px 띠(진행 중 일정) |
| `AppFillButton` | 높이 48 채움 버튼 (primary · secondary) |
| `AppCheckbox` | 22px 체크박스, 탭 영역 44×44 |
| `AppBadge` · `AppProgressBar` | 상태 배지 · 6px 진행 바 |
| `AppPressScale` · `AppTapRow` | 카드·아이콘 / 목록 줄의 누름 반응 |
| `AppErrorView` · `InlineErrorText` | 조회 실패 + 다시 시도 / 입력·저장 오류 |
| `confirmDelete` · `showNotice` · `promptRename` | 삭제 확인 · 알릴 자리가 없는 실패 안내 · 이름 고치기 |
| `SubTaskTile` · `SubTaskInputField` | 세부 작업 한 줄(체크·이름 고치기·지우기) · 새 작업 입력칸 |
| `confirmDeleteSchedule` · `toggleSubTask` … | 여러 화면이 쓰는 일정 동작 + 실패 안내 |

## 다국어

- easy_localization. 번역 파일 `assets/translations/{ko,en}.json`, 기본·fallback `ko`.
- 키 네이밍 `feature.component.text`. 여러 화면이 쓰는 문구는 `common.*`.
- `test/translations_parity_test.dart` 가 두 파일의 키·자리표시자 정합성을 확인합니다.

## 네이밍

- 파일·폴더: snake_case. 클래스: PascalCase + 접미사(`Controller`/`Screen`/`Repository`).
- Provider 변수: camelCase + `Provider` 접미사.
- **위젯**: 기반이 되는 Material 3 컴포넌트명을 접미사로 (`Button`/`Chip`/`Card`/`Dialog`
  /`Sheet` …). 공용 위젯은 `App` 접두사.

코딩 규약 상세는 [CLAUDE.md](CLAUDE.md) 참고.
