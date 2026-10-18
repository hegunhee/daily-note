# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.2.1] - 2025-01-30

### Changed
- Flutter 버전 3.38.5 → 3.38.8 업데이트
- 패키지 업데이트
  - `google_fonts`: 6.3.3 → 8.0.0
  - `flutter_riverpod`: 3.0.3 → 3.2.0
  - `firebase_core`: 4.3.0 → 4.4.0
  - `firebase_crashlytics`: 5.0.6 → 5.0.7

## [0.2.0] - 2024-12-24

### Added
- Repository를 Riverpod Provider로 관리하도록 패턴 개선
  - `githubRepositoryProvider` 추가로 의존성 주입 개선
  - Riverpod 공식 권장 패턴 사용 (매번 `ref.read()` 호출)

### Changed
- Flutter 버전을 3.35.6에서 3.38.5로 업데이트
- Android Gradle 설정 최신화
  - Gradle 8.14 사용
  - Android Gradle Plugin 8.11.1 사용
  - NDK 28.2.13676358 요구
- GitHub Repository 예제에서 Repository Pattern 개선
  - Provider를 통한 의존성 주입으로 테스트 용이성 향상
  - Riverpod 공식 문서와 일관된 패턴 적용

### Fixed
- iOS 빌드 설정 최신 Flutter 버전과 호환성 확인

## [0.1.0] - 2024

### Added
- Flutter 프로젝트 템플릿 초기 버전
- Riverpod 3.0 상태 관리
- Material 3 테마 시스템 (AppColors, AppTypography)
- easy_localization 다국어 지원
- Firebase Crashlytics 통합
- FVM을 통한 Flutter 버전 관리 (3.35.6)
- Feature-based 모듈 구조
- GitHub API 연동 예제
- Todo 기능 예제
- 포괄적인 문서 (아키텍처, 설정 가이드)
