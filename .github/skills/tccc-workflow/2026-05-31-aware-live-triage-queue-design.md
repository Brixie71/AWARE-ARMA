# AWARE Live Triage Queue Design

## Approval Record

These are the design questions the user approved before implementation planning:

- FIRST AID default optimization: **Next lifesaving action**.
- Recommendation scope setting: add `Inventory-aware only`, `Medic-role aware`, and `Full ideal workflow`.
- Recommendation scope default: **Medic-role aware**.
- Shortcut behavior setting: add `Guide Only`, `Attempt Treatment`, and `Mixed`.
- Shortcut behavior default: **Guide Only**.
- Approved implementation approach: **Live Triage Queue**.
- Approved architecture: snapshot patient state, classify with MARCH, filter by setting scope, queue rows, render FIRST AID, reassess after treatment.
- Approved procedure/indicator behavior: KAT-aware procedure rows, ACE3 fallback, one direct action per row, blocked reasons, applied rows as reassessment prompts, and explicit `ACTION`, `MISSING`, `BLOCKED`, `APPLIED`, and `FOLLOW-UP` indicators.
- Approved docs/validation scope: update `.github/skills/tccc-workflow` markdown, copy useful KAT Python validators, include `sqf_linter.py`, and install its dependency.

## Purpose

Improve the AWARE FIRST AID checklist so it gives compact, useful, ACE3/KAT-aware recommendations during medical treatment. The default experience should prioritize the next lifesaving action, not long training text, while still allowing configurable detail and workflow behavior.

The approved approach is **Live Triage Queue**:

1. Snapshot the current patient state.
2. Classify threats using MARCH.
3. Filter recommendations by the selected scope setting.
4. Queue actionable, blocked, and completed rows.
5. Render the FIRST AID tab with clear indicators.
6. Reassess after each detected treatment.

ACE3 remains the baseline medical source. KAT is used as a module-aware extension for airway, breathing, circulation, pharma, surgery, oxygen, IV/IO, pulse ox, AED/AED-X, and advanced chest logic.

## Current Context

AWARE already has active local checklist work in:

- `addons/main/functions/fn_getSuggestedMedicalProcedures.sqf`
- `addons/main/functions/fn_renderMedicalSuggestions.sqf`
- `addons/main/functions/fn_executeMedicalSuggestion.sqf`
- `addons/main/functions/fn_registerMedicalSuggestionInput.sqf`
- `addons/main/functions/fn_registerMedicalTreatmentTracking.sqf`
- `addons/main/functions/fn_registerSettings.sqf`
- `addons/main/ui/medicalSuggestion.hpp`
- `addons/main/stringtable.xml`
- `.github/skills/tccc-workflow/`

These files should be edited carefully without reverting unrelated local work.

`.\hemtt.exe check` currently passes on the dirty tree. The existing `tools/test-now-procedure-suggestions.ps1` is stale and fails on the current indicator expectations, so it needs to be updated as part of this work.

## KAT Findings

Useful KAT sources from `C:\Users\Jhon_Brix\Desktop\KAT`:

- `addons/airway/ACE_Medical_Treatment_Actions.hpp`
- `addons/breathing/ACE_Medical_Treatment_Actions.hpp`
- `addons/circulation/ACE_Medical_Treatment_Actions.hpp`
- `addons/pharma/ACE_Medical_Treatment_Actions.hpp`
- `addons/surgery/ACE_Medical_Treatment_Actions.hpp`
- `docs/Equipment/*.md`
- `docs/Hemorrhaging/*.md`
- `docs/Cardiac/*.md`
- `docs/Pharmacy/*.md`

KAT constraints to reflect:

- Airway adjuncts and suction are head/body workflow actions and usually unconscious-gated.
- Breathing adds pulse oximeter, chest seal, hemopneumothorax/tension treatment, NCD/AAT, BVM, pocket BVM, nasal cannula, and oxygen source handling.
- Pharma can require IV/IO access for IV medications depending on settings.
- TXA/EACA can interact with IV/IO obstruction and catheter inspection/flush workflows.
- IV access uses limb-only `kat_IV_16`; IO uses torso `kat_IO_FAST`.
- AED/AED-X flow includes pads, rhythm analysis, shock/charge state, monitor connection, and medic-level requirements.
- Surgery and fracture workflows are mostly follow-up/stabilization, not first lifesaving actions unless the patient is otherwise stable.

Useful KAT Python tools to copy into AWARE `tools/`:

- `sqf_validator.py`
- `config_style_checker.py`
- `sqf_linter.py`

`sqf_linter.py` requires the Python `sqf` dependency. Install that dependency during implementation, requesting approval if network access is needed.

KAT-specific string/function scanners should not be copied as-is because they assume `STR_KAT_*` and `kat_*_fnc_*` naming. They can be adapted later if needed.

## Architecture

### State Snapshot

`AWARE_fnc_getSuggestedMedicalProcedures` should build a patient snapshot each refresh from:

- ACE life state, unconscious state, cardiac arrest state.
- ACE open and bandaged wounds by body part.
- ACE bleeding, tourniquets, fractures, blood volume, heart rate, blood pressure, pain, pain suppression, medications, and IV bags/access.
- KAT airway state when module exists: obstruction, occlusion, overstretch/recovery, airway item, suction/adjunct state.
- KAT breathing state when module exists: respiration rate, SpO2/oxygen saturation, cyanosis, chest injury state, chest seal state, BVM/oxygen/pulse ox state.
- KAT pharma state when module exists: IV/IO arrays, route availability, clotting/coagulation support, TXA/EACA, analgesia, obstruction signals if discoverable.
- KAT circulation state when module exists: AED/AED-X pads, rhythm/monitor state, CPR/cardiac workflow state.
- KAT surgery state when module exists: fracture state, surgery progress where useful for follow-up rows.
- Current medic/player inventory via `AWARE_fnc_getMedicInventoryItems`.
- Current player medical capability when available from ACE/KAT settings or treatment conditions.

Snapshot reads must be defensive. If a KAT module or variable is missing, fall back to ACE-compatible behavior instead of failing or hiding important threats.

### Threat Classification

Recommendations should use MARCH ordering:

- **M - Massive Hemorrhage**: active bleeding, limb tourniquet, bandage, tourniquet removal follow-up.
- **A - Airway**: unconscious airway obstruction/occlusion, recovery position, head positioning, Guedel/King LT, suction.
- **R - Respiration**: penetrating chest injury, chest seal, pneumothorax/tension/hemopneumothorax follow-up, NCD/AAT only when KAT state or SOP indicates, oxygen, BVM, pulse ox.
- **C - Circulation**: blood loss, shock, IV/IO, fluids/blood, TXA/EACA, AED/AED-X cardiac workflow.
- **H - Hypothermia/Head/Follow-up**: pain control, fracture/splint, surgery, hypothermia prevention, transport prep.

The default FIRST AID tab should optimize for **Next lifesaving action**: compact and urgent, with no long rationale unless detail settings request it.

### Queue Model

Each row should have structured fields before rendering:

- Priority: `M`, `A`, `R`, `C`, or `H`.
- Severity/order score.
- Heading.
- Direct action sentence.
- Body part key.
- Action type.
- Menu path or guide text.
- Requirement group.
- Item candidates.
- Required role or medical level, if known.
- Module requirement, if any.
- Route requirement, such as IV/IO.
- Status: `ACTION`, `MISSING`, `BLOCKED`, `APPLIED`, or `FOLLOW-UP`.
- Block reason, if status is blocked.
- Shortcut eligibility.

Render order:

1. `ACTION`
2. `MISSING`
3. `BLOCKED`
4. `APPLIED`
5. `FOLLOW-UP`

Within each status bucket, preserve MARCH and severity order.

## Settings

Add or align CBA Addon Options for these settings.

### Recommendation Scope

Default: **Medic-role aware**.

Options:

- `Inventory-aware only`: a recommendation is actionable if the player has the needed item. Role/medical-level limits are not used for queue filtering.
- `Medic-role aware`: a recommendation is actionable only when item and medical capability are acceptable. If the item exists but the role is insufficient, show it as `BLOCKED`.
- `Full ideal workflow`: show the ideal next treatment path even if the current player lacks the item, role, route, or enabled module. Mark unavailable requirements clearly.

### Shortcut Mode

Default: **Guide Only**.

Options:

- `Guide Only`: open ACE/KAT medical menu when possible and show exact body part, item, and menu path.
- `Attempt Treatment`: attempt direct treatment only when the action can be safely and reliably called.
- `Mixed`: attempt simple ACE actions where reliable; guide complex KAT or setting-gated procedures.

The implementation should not over-automate KAT actions whose conditions depend on macros, treatment locations, medic levels, or runtime callback state unless it can prove they are safe.

## Procedure Improvements

Add or refine rows for:

- Limb bleeding with tourniquet and bandage follow-up.
- Torso wound handling with chest seal when KAT breathing state or injury state indicates it.
- Chest decompression/NCD/AAT only when KAT chest state or SOP condition supports it.
- Airway obstruction vs occlusion: adjunct/recovery/head position vs suction.
- Oxygen support, BVM/pocket BVM, nasal cannula, and pulse ox.
- IV/IO access, including limb IV vs torso FAST IO guidance.
- Blood/fluid recommendations after bleeding control.
- TXA/EACA clot support with IV/IO route awareness.
- Cardiac arrest workflow with CPR, AED/AED-X pads, rhythm analysis, shock/charge guidance, and ongoing MARCH stabilization.
- Pain control after lifesaving threats are addressed.
- Fracture/splint and KAT surgery follow-up.

Rows should avoid broad multi-action paragraphs. Prefer one direct action per row and use follow-up rows for reassessment.

## Indicator Improvements

Use these labels consistently:

- `ACTION`: can do now.
- `MISSING`: required item is not carried.
- `BLOCKED`: role, module, body part, IV/IO route, setting, or treatment location prevents action.
- `APPLIED`: treatment has been detected and should not be repeated.
- `FOLLOW-UP`: not the immediate lifesaving action, but still needed after urgent care.

Applied procedures should become reassessment prompts. For example, after oxygen or chest seal is detected, the next row should say to recheck breathing/SpO2 instead of recommending the same action again.

## Docs Updates

Update the repo guidance under `.github/skills/tccc-workflow/` to match this architecture:

- `SKILL.md`
- `references/march-protocol.md`
- `references/common-procedures.md`
- `references/body-composition.md`
- `references/beginner-medical-guide.md`
- `references/advanced-medical-implementation.md`

The docs should describe:

- `Snapshot -> MARCH classify -> scope filter -> queue -> render -> reassess`.
- ACE3 as baseline and KAT as module-aware extension.
- The recommendation scope setting and its default.
- The shortcut mode setting and its default.
- Compact FIRST AID behavior by default.
- Clear separation between lifesaving actions, blocked rows, applied rows, and follow-up rows.

## Validation

Required validation before handoff:

```powershell
.\hemtt.exe check
python tools\sqf_validator.py -m main
python tools\config_style_checker.py -m main
python tools\sqf_linter.py -m main
```

Also update and run:

```powershell
powershell -ExecutionPolicy Bypass -File tools\test-now-procedure-suggestions.ps1
```

Manual validation should cover:

- ACE-only patient with bleeding, fracture, pain, blood loss.
- ACE+KAT patient with airway obstruction/occlusion.
- ACE+KAT breathing cases: chest injury, chest seal, low SpO2, BVM/oxygen support, pulse ox.
- ACE+KAT circulation cases: IV/IO, shock, TXA/EACA, cardiac arrest, AED/AED-X.
- Scope setting behavior for Inventory-aware only, Medic-role aware, and Full ideal workflow.
- Shortcut setting behavior for Guide Only, Attempt Treatment, and Mixed.

## Visual Reference

A simple local diagram exists at:

- `diagram/medical-checklist-flow.html`

It illustrates the approved Live Triage Queue pipeline and indicator direction.
