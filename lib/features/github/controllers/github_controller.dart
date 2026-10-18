import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/github/models/github_repo_model.dart';
import 'package:template/features/github/repositories/github_repository.dart';

/// GitHub 레포지토리 정보를 관리하는 Provider
final githubProvider = AsyncNotifierProvider<GitHubNotifier, GithubRepoModel>(
  GitHubNotifier.new,
);

/// GitHub 레포지토리 상태 관리
class GitHubNotifier extends AsyncNotifier<GithubRepoModel> {
  @override
  Future<GithubRepoModel> build() {
    final repository = ref.read(githubRepositoryProvider);
    return repository.getRepo(
      owner: 'blueberry-team',
      repo: 'blueberry_template',
    );
  }
}
