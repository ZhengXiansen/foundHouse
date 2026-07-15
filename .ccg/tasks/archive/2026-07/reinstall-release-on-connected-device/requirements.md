# Release install request

Build a fresh signed Android release APK after the device integration run, then install it on connected device `e4e6ad3a` without changing application code. Verify package metadata and launch smoke test afterward.

Safety: attempt non-destructive `adb install -r` first. If Android reports a signing conflict that requires uninstalling the existing app, stop and ask before removing user data.
