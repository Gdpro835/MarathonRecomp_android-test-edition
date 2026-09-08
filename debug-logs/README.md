# Drop tester logs here

Scratch folder for device logs while an issue is being diagnosed. Nothing in the
build reads it — it exists so a log can be handed over through the repository when
chat attachments don't come through.

## How to add a log without a PC

1. Open this folder on github.com, on the branch you are working with.
2. **Add file → Upload files**, drag `log.txt` in, commit.

## How to add a log with adb

```bash
adb shell run-as com.sega.marathon cat files/log.txt > log.txt
# or, if the log is in external app storage:
adb shell cat /sdcard/Android/data/com.sega.marathon/files/log.txt > log.txt
```

Then upload it the same way, or commit it directly.

## Where the log comes from on the device

`Android/data/com.sega.marathon/files/log.txt`, reachable from the launcher's **Log**
button. The previous run is kept next to it as `log_prev.txt`.

## What is worth capturing alongside it

When reporting a rendering problem, a screenshot of the broken frame plus the value
in `driver_import/a610_preset.txt` (if any) makes the log far more useful — the log
records which preset it used, but not what the result looked like.

Delete files here once the issue they belong to is closed.
