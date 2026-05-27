# Repository Guidelines

## Project Structure & Module Organization

AWARE is an Arma 3 addon built with HEMTT. Root metadata lives in `mod.cpp`, `meta.cpp`, and `.hemtt/project.toml`. Addon source is under `addons/main/`: `config.cpp` registers patches, functions, and RscTitles; `functions/` contains SQF loaded as `AWARE_fnc_*`; `ui/` contains controls; `stringtable.xml` stores localized text; `missions/` contains test scenarios.

Build output goes to `.hemttout/` and should not be edited by hand.

## Build, Test, and Development Commands

- `.\hemtt.exe check`: validates configs, compiles SQF, and checks stringtables. Run before handoff.
- `.\hemtt.exe build`: builds the local test mod into `.hemttout/build`.
- `.\build.ps1`: PowerShell wrapper around `.\hemtt.exe build`.
- `.\hemtt.exe launch`: launches Arma 3 with the dev build.
- `.\hemtt.exe launch vr`: launches the bundled VR test mission.
- `.\hemtt.exe launch eden`: opens the bundled mission in Eden Editor.

## Coding Style & Naming Conventions

Use SQF conventions already present in `addons/main/functions`: one function per `fn_name.sqf`, private locals prefixed with `_`, and registered function names exposed as `AWARE_fnc_name`. Keep function registrations in `addons/main/config.cpp` synchronized with files in `functions/`.

Use four-space indentation in SQF, C++ config, XML, and HPP files. Keep UI control IDC values stable once referenced from scripts. Add stringtable keys for user-facing text instead of hardcoding repeated UI labels.

## TCCC Workflow References

Use `.github/skills/tccc-workflow/SKILL.md` before changing medical procedures, casualty workflows, or ACE/KAT treatment logic. The repo uses `SKILL.md`; References live in `.github/skills/tccc-workflow/references/`:

- `tccc-baseline.md`: TCCC stages and baseline care model.
- `march-protocol.md`: MARCH treatment priority order.
- `mass-casualty-checklist.md`: fast triage/checklist behavior.
- `body-composition.md`: body part and injury mapping.
- `common-procedures.md`: common treatment patterns.

Use `templates/medical-procedure-template.sqf` for new medical procedure functions.

## Testing Guidelines

There is no separate unit test framework. Treat `.\hemtt.exe check` as required automated validation. For UI or medical workflow changes, also test in Arma via `.\hemtt.exe launch vr` or `.\hemtt.exe launch eden` and verify relevant ACE/KAT medical menu behavior manually.

## Commit & Pull Request Guidelines

Recent history uses short subjects such as `Updated Medical Workflow`, `Improved Medical Workflow`, and `UI Bug Fix`. Follow that concise, behavior-focused style.

Pull requests should include a short description, affected systems, validation performed, and screenshots or clips for UI changes. Note manual Arma/ACE/KAT coverage and known limitations.

## Agent-Specific Instructions

Do not revert unrelated local changes. This repo may contain active work in `addons/main`; inspect diffs before editing shared files. Prefer targeted edits and leave generated `.hemttout/` artifacts alone.
