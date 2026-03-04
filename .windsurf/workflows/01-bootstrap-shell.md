# /bootstrap-shell

Goal: Ensure the hub shell, theme tokens, and game registry compile and run on Web.

Steps:
1) Verify file tree matches README.
2) Run:
   - flutter pub get
   - flutter analyze
   - flutter test
   - flutter run -d chrome
3) If errors:
   - fix the minimum necessary lines
   - keep diffs small
4) Commit with message: "Bootstrap shell + registry + theme tokens"
