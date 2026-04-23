# OpenCode Project Rules — Token-Saving Edition
# These rules guide the AI to minimize token usage while maintaining quality.

## Context Discipline

1. **Exclude irrelevant files automatically.**
   - The `.opencodeignore` file at repo root already excludes `build/`, `.dart_tool/`, `android/`, `ios/`, `node_modules/`, generated `*.g.dart`, images, fonts, etc.
   - Do NOT read or reference excluded files unless the user explicitly asks.

2. **Scope every request.**
   - Before touching code, identify the exact file(s) involved. Avoid broad searches when a file path is known.
   - If the user says "fix the timer bug", assume `lib/modules/home/bloc/home_timer_cubit.dart` or `home_bloc.dart` — don't grep the whole repo.

3. **Reuse already-fetched context.**
   - If a file was read in the current conversation, reference it by line number or brief snippet rather than re-reading.
   - If the user refers to "the model we just fixed", assume the last model discussed (e.g., `StrengthSetModel`).

## Response Efficiency

4. **Return minimal, actionable output.**
   - For simple fixes: return a diff or the changed method only.
   - For multi-file refactors: list files changed and show only the modified sections.
   - Only return full files when the user asks, or when the file is very short (< 30 lines).

5. **Skip unnecessary narration.**
   - No need to say "Here is the updated code" or "I made the following changes" — just show the code or apply the edit.
   - Avoid repeating the user's request back to them.

6. **Batch trivial tasks.**
   - If the user lists 3 typo fixes, apply all 3 in one pass rather than 3 separate responses.

## Tool Usage

7. **Prefer `edit` over prose descriptions.**
   - When the change is unambiguous, use the `Edit` tool directly instead of describing what to change.
   - When creating new files, use `Write` directly.

8. **Use `bash` sparingly for exploration.**
   - `grep` and `glob` are cheap; `flutter test` and `flutter build` are expensive. Only run builds/tests when the user explicitly asks or when verification is critical.

## Flutter / Dart Specific

9. **Respect existing patterns.**
   - Follow the project's existing architecture (BLoC, Repository pattern, `BaseRepository`, `BaseBloc`).
   - Use the same error-handling style (`AppError.create`, `handleDatabaseOperation`) already present in the codebase.

10. **Avoid redundant type annotations.**
    - Dart infers many types. Don't add explicit types where the project already omits them (e.g., `final foo = 42;` is fine).

## Conversation Hygiene

11. **Start fresh for unrelated tasks.**
    - If the user pivots from "fix auth" to "add chart widget", suggest a new session to avoid carrying irrelevant context.

12. **Don't ask clarifying questions for obvious defaults.**
    - If the user says "add dark mode", default to Material 3 `ColorScheme.dark()` unless they specify otherwise.
    - If uncertain, make a reasonable choice and note it in one sentence.
