# CLAUDE.md

Claude Code(claude.ai/code)가 이 레포에서 작업할 때 따르는 가이드입니다.

## 프로젝트 개요

**하루기록** (시안 코드명 Greenlist) — 날짜별 일정과 일정마다의 세부 작업 체크리스트·메모를 관리하는 앱(iOS · Android).
Flutter 단일 모듈이며 Dart 패키지 이름은 `greenlist`, 앱 ID 는 Android `com.example.daily_note` ·
iOS `com.example.dailyNote` 입니다. 같은 템플릿에서 시작한 포켓가계부(money_diary)는
`com.example.blueberry_template` 이라, 앱 ID 를 바꿀 때 이 값과 겹치지 않게 합니다(겹치면 기기에서
서로를 덮어쓰고 데이터가 지워집니다). **서버 없이 기기의 로컬 DB**에
저장합니다(hive_ce).

- **Flutter 3.41.9**. 로컬은 FVM(`.fvmrc`), CI는 `subosito/flutter-action` 의
  `flutter-version`. 버전을 올릴 땐 `.fvmrc` 와 모든 워크플로의 `flutter-version` 을 함께 수정.
- 상태관리 **Riverpod 3** + **flutter_hooks** (`HookConsumerWidget`, `hooks_riverpod`).
- 다국어 easy_localization (`ko` 기본 · `en`).
- 엔트리포인트는 `lib/main.dart` 하나.
- 언어: 문서·주석 모두 **한국어**.
- 구조·패턴 상세는 [ARCHITECTURE.md](ARCHITECTURE.md), 실행 방법은 [README.md](README.md).
- 디자인 기준은 [docs/design/DESIGN.md](docs/design/DESIGN.md) 와 `docs/design/screens/`
  의 화면별 Stitch 시안(`screen.png` · `code.html`). 색은 기획서 값(Primary `#24734A` ·
  Accent `#F28C45` · Background `#F5F7F3`)이 시안 토큰보다 우선합니다.

## 구조 (feature-first)

```
lib/
├── core/                 # 의존성 없이 앱 전체 적용되는 leaf 코드
│   └── themes/           # AppPalette · AppColors · AppTypography · AppSpacing · AppRadius · AppLayout · AppTheme
├── shared/               # 여러 feature에서 중복되는 컴포넌트·코드
│   ├── models/ · repositories/ · controllers/  # 여러 feature가 쓰는 모델·로컬 DB·상태
│   ├── hooks/            # 여러 화면이 쓰는 훅
│   ├── util/             # 계산 · 표기 순수 함수
│   └── widgets/          # 공용 UI
└── features/<feature>/
    ├── models/           # 데이터 모델
    ├── repositories/     # 로컬 DB 읽기·쓰기
    ├── controllers/      # 상태 (Riverpod)
    ├── screens/
    └── widgets/          # 이 feature 전용
```

의존은 `features → shared → core` 한 방향(역방향 금지). **core** = 의존성 없이 앱 전체
적용되는 기능, **shared** = 여러 feature에서 중복되는 컴포넌트·코드. 폴더는 필요해질 때
만듭니다(빈 폴더를 미리 두지 않음).

## Provider 규칙

- 동기 상태 → `NotifierProvider`, 비동기 상태 → `AsyncNotifierProvider`.
- 컨트롤러 상태는 **모델 그대로** — `Schedule` · `List<Schedule>` ·
  `AsyncValue<ScheduleBook>`. 감싸는 State 클래스 금지(예외는 아래 모델 참고).
- 화면에서만 쓰는 값(입력값 · 펼침 · 임시 편집값 · 진행 중 플래그 · 애니메이션)은
  `HookConsumerWidget`(ref 불필요하면 `HookWidget`)의 `useState` ·
  `useTextEditingController` · `useAnimationController` 등 훅으로.
- 지금 시각은 `clockProvider` 로 읽습니다(테스트에서 고정). `DateTime.now()` 를 화면·컨트롤러에서
  직접 부르지 않습니다(id 생성 제외).
- ❌ `StateNotifierProvider`(구식) · `FutureProvider`(단순한 경우 외) · `setState` ·
  `StatefulWidget`(훅으로 대체) · `provider` 패키지 금지.
- Provider 변수명은 camelCase + `Provider` 접미사.

```dart
final scheduleProvider =
    AsyncNotifierProvider<ScheduleController, ScheduleBook>(ScheduleController.new);
```

## 디자인 시스템

- 색: `context.colors` (ThemeExtension 기반 `AppColors`). 하드코딩 색 금지. 원시 hex 는
  `AppPalette` 에만 둡니다. 투명도는 `withValues(alpha:)` (`withOpacity` 금지).
- Primary(초록)는 주 동작·선택·완료, Accent(주황)는 **지금 진행 중인 일정에만** 씁니다.
- 표면은 그림자 없이 흰 카드 + 1px `border` 로 구분합니다(디자인 가이드 Level 1).
- 타이포: `AppTypography` (`headlineXl/Lg/Md/Sm` · `bodyLg/Md/Sm` · `labelLg/Md/Sm` ·
  `timeLg/Md/Sm`). 직접 `fontSize` 금지. 시각·날짜 숫자는 고정폭 숫자가 켜진 `time*` 로.
  폰트는 Pretendard.
- 간격: `AppSpacing` (`xs`=4 · `sm`=8 · `md`=12 · `lg`=16 · `xl`=24 · `xxl`=32), 모서리는
  `AppRadius`. 탭 대상은 최소 44×44(`AppLayout.minTouchTarget`). 넓은 화면은 `AppContentWidth`.
- 문자열: `'key'.tr()` (하드코딩 문자열 금지). 키는 `feature.component.text`. 키를 더하면
  `ko.json` · `en.json` 양쪽에 넣습니다(`test/translations_parity_test.dart` 가 확인).
- 누름 반응: 목록의 줄은 `AppTapRow`, 카드·알약·아이콘은 `AppPressScale`.
- 피드백은 스낵바를 기본으로 쓰지 않습니다. 입력 오류는 필드 근처(`InlineErrorText`),
  저장 실패와 재시도는 해당 작업 영역 안에 표시합니다. 다이얼로그는 명시적 결정이 필요한
  경우만 사용합니다.
- 삭제처럼 되돌릴 수 없는 동작은 확인 창(`confirmDelete`)을 거칩니다.
- 이미 읽은 값이 있으면 다시 읽는 동안 그대로 둡니다. 로딩 표시는 처음 읽을 때만.

## 네이밍

- 파일·폴더: snake_case. 클래스: PascalCase + 접미사(`Controller`/`Screen`/`Repository`).
- 예: `ScheduleController` → `schedule_controller.dart`.
- **위젯**: 기반 Material 3 컴포넌트명을 suffix로 (`Button`/`Chip`/`Card`/`Dialog`/`Sheet` …).
  공용 위젯은 `App` 접두사(`AppFillButton`).

## 모델

- 모델은 `models/` 에 대표 클래스명(snake_case) 파일로. 저장소 파일 안에 정의하지 않습니다.
- 화면 표시만을 위한 모델 클래스는 만들지 않습니다. 저장된 값은 모델 그대로, 화면 값은
  훅으로. enum 은 허용. `Model` 접미사 · record typedef 로 상태를 묶는 우회 금지.
- 진행률·정렬·상태 같은 계산은 화면이 아니라 순수 함수(`shared/util/`)에 두고 테스트합니다.
  **일정 상태(완료 처리·시각 기준)와 세부 작업 완료율은 서로 다른 개념**으로 둡니다.
- `*State` 클래스는 **예외로만**: 모델 하나로 안 되고 훅으로도 안 될 때(화면보다 오래
  살거나 여러 화면이 공유)만. `models/xxx_state.dart` 에 두고 필요한 이유를 한 줄
  dartdoc 으로 적습니다.
- 허가 목록은 `state_allowlist.txt`(한 줄에 이름 하나 + `# 이유`).
  `test/architecture/state_allowlist_test.dart` 가 목록에 없는 `*State` · record typedef ·
  StatefulWidget 의 State 를 막습니다. 새로 필요하면 같은 PR 에서 목록에 이유와 함께 추가.

## 금지

`setState` · `StatefulWidget` · 허가 목록에 없는 `*State` 클래스 · record 상태 묶음 ·
`provider` 패키지 · 하드코딩(색/폰트/문자열) · 과도한 추상화(YAGNI) · 영어 doc comment ·
이름만 되풀이하는 doc comment.

## 패키지 추가

`pubspec.yaml` 직접 수정 금지. 반드시 명령어로:

```bash
fvm flutter pub add package_name
fvm flutter pub add package_name --dev
```

## 테스트 작성 기준

테스트는 개수를 늘리거나 단순 구현 내용을 고정하기 위해 만들지 않습니다. 테스트를 추가하기
전에 **어떤 실제 회귀를 막는지** 한 문장으로 설명할 수 있어야 하며, 설명할 수 없다면 추가하지
않습니다.

- 진행률·정렬·시간 검증 같은 비즈니스 규칙, 저장 실패·롤백, 데이터 정합성(일정 삭제 시 세부
  작업 정리)처럼 실제로 깨질 수 있는 동작과 경계를 우선 검증합니다.
- 버그 수정에는 가능하면 그 버그가 재발하면 실패하는 가장 작은 회귀 테스트 하나를 둡니다.
  같은 동작을 단위·위젯 테스트에서 의미 없이 중복 검증하지 않습니다.
- 번역 문구, 정적 파일 존재 여부, 상수값, 단순 생성자·getter, 컴파일러나 정적 분석기가
  이미 잡는 내용만 확인하는 전용 테스트는 작성하지 않습니다.
- 커버리지 수치나 테스트 개수 자체를 목표로 삼지 않습니다.

## 커밋 전 검증

```bash
fvm flutter analyze
fvm flutter test
git ls-files '*.dart' | xargs fvm dart format --output=none --set-exit-if-changed
```

- `dart format` 은 `flutter pub get` 뒤에, 바꾼 파일만 돌립니다.
- `dart fix --apply` 같은 일괄 수정 뒤에는 `git status` 로 의도하지 않은 파일을 확인하고 되돌립니다.

## CI (`.github/workflows/`)

커밋을 푸시할 때마다 네 가지가 돕니다. 모두 푸시된 커밋을 기준으로 검사합니다.

| 워크플로 | 하는 일 | 로컬에서 같은 검사 |
|---|---|---|
| 포맷 검사 (`format-test.yml`) | 포맷이 어긋난 `.dart` 파일이 있으면 실패 | `git ls-files '*.dart' \| xargs fvm dart format --output=none --set-exit-if-changed` |
| 린트 검사하기 (`lint-test.yml`) | `flutter analyze --no-fatal-infos` | `fvm flutter analyze` |
| 유닛 테스트 (`unit-test.yml`) | `flutter test --coverage` | `fvm flutter test` |
| 빌드 테스트 (`build-test.yml`) | Android APK 빌드 | `fvm flutter build apk` |

## 커밋·PR 규약

- 커밋·PR 제목은 **한국어 문장**. 영어 `feat:`/`fix:` 프리픽스 사용 금지.
- 작업은 단위별로 **이슈와 PR 을 나눠** 만들고, PR 본문에 `Closes #이슈번호` 를 적습니다.
- PR은 Ready 상태(draft 아님)로, linear 히스토리를 유지해 Rebase-and-merge 가능하게.
- 변경을 서술하는 주석(`// X 제거`, `// 이전엔…`)을 소스에 남기지 않습니다.
- 이슈·PR 에는 만든 날 기준으로 **`N일차` 라벨**을 붙입니다. 프로젝트 시작일
  **2026-10-18 이 1일차**이고, 한국 시간(KST) 달력 날짜로 셉니다(작업하지 않은 날도 셈에
  넣습니다. 예: 2026-10-21 → `4일차`). 라벨이 없으면 먼저 만듭니다.

  ```bash
  gh label create "4일차" --color 0E8A16 --description "프로젝트 4일차 (2026-10-21)"
  gh pr create --label "4일차" …
  ```
