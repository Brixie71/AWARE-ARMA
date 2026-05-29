$ErrorActionPreference = "Stop"

$functionPath = Join-Path $PSScriptRoot "..\addons\main\functions\fn_getSuggestedMedicalProcedures.sqf"
$trackingPath = Join-Path $PSScriptRoot "..\addons\main\functions\fn_registerMedicalTreatmentTracking.sqf"
$initPath = Join-Path $PSScriptRoot "..\addons\main\functions\fn_init.sqf"
$configPath = Join-Path $PSScriptRoot "..\addons\main\config.cpp"
$renderPath = Join-Path $PSScriptRoot "..\addons\main\functions\fn_renderMedicalSuggestions.sqf"
$inputPath = Join-Path $PSScriptRoot "..\addons\main\functions\fn_registerMedicalSuggestionInput.sqf"
$uiPath = Join-Path $PSScriptRoot "..\addons\main\ui\medicalSuggestion.hpp"
$stringtablePath = Join-Path $PSScriptRoot "..\addons\main\stringtable.xml"
$source = Get-Content -Raw $functionPath
$trackingSource = if (Test-Path $trackingPath) { Get-Content -Raw $trackingPath } else { "" }
$initSource = Get-Content -Raw $initPath
$configSource = Get-Content -Raw $configPath
$renderSource = Get-Content -Raw $renderPath
$inputSource = Get-Content -Raw $inputPath
$uiSource = Get-Content -Raw $uiPath
$stringtableSource = Get-Content -Raw $stringtablePath

function Assert-SourceContains {
    param (
        [string]$Pattern,
        [string]$Message
    )

    if ($source -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-TextContains {
    param (
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-TextDoesNotContain {
    param (
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ($Text -match $Pattern) {
        throw $Message
    }
}

function Assert-InOrder {
    param (
        [string]$Text,
        [string[]]$Needles,
        [string]$Message
    )

    $lastIndex = -1
    foreach ($needle in $Needles) {
        $index = $Text.IndexOf($needle)
        if ($index -lt 0 -or $index -le $lastIndex) {
            throw $Message
        }
        $lastIndex = $index
    }
}

function Get-NowGenerationBlock {
    $lifeStateIndex = $source.IndexOf("private _lifeState")
    if ($lifeStateIndex -lt 0) {
        throw "Could not find patient-state section."
    }

    $nowStart = $source.IndexOf("private _nowLines = [", $lifeStateIndex)
    if ($nowStart -lt 0) {
        throw "Could not find ACE NOW generation block."
    }

    $recheckStart = $source.IndexOf("private _responseStatus", $nowStart)
    if ($recheckStart -lt 0) {
        throw "Could not find VITALS generation block after FIRST AID block."
    }

    return $source.Substring($nowStart, $recheckStart - $nowStart)
}

function Get-RequirementDefinitionBlock {
    $start = $source.IndexOf("private _tourniquetRequirements")
    if ($start -lt 0) {
        throw "Could not find treatment requirement definitions."
    }

    $end = $source.IndexOf("private _airwayRequirements", $start)
    if ($end -lt 0) {
        throw "Could not find airway requirement definitions after first-aid requirements."
    }

    return $source.Substring($start, $end - $start)
}

function Assert-NowBlockDoesNotContain {
    param (
        [string]$Pattern,
        [string]$Message
    )

    $nowBlock = Get-NowGenerationBlock
    if ($nowBlock -match $Pattern) {
        throw $Message
    }
}

Assert-SourceContains "#F06A5A" "Missing inventory items should use red text."
Assert-SourceContains "private _nowTreatmentRows = \[\];" "NOW should collect candidate treatment rows before rendering."
Assert-SourceContains "_nowTreatmentRows pushBack" "NOW should render from prioritized treatment rows."
Assert-SourceContains "private _orderedTreatmentSteps = \[\];" "NOW should build all pending treatment steps in order."
Assert-SourceContains "\(Required\)" "Missing inventory items should show a Required indicator beside the item."
Assert-SourceContains "%1 <t color='#9BE28F'>\(Applied\)</t>" "Applied indicator should be an inline green suffix beside the item."
Assert-SourceContains "%1 <t color='#F06A5A'>\(Required\)</t>" "Required indicator should be an inline red suffix beside the item."
Assert-SourceContains "AWARE_appliedMedicalItems" "Suggestions should read patient-side applied medical item state."
Assert-SourceContains "ace_medical_fnc_getBandagedWounds" "Suggestions should fall back to ACE patient bandaged-wound state."
Assert-SourceContains "ace_medical_fnc_getOpenWounds" "Suggestions should inspect ACE open wounds by body part."
Assert-SourceContains "ace_medical_tourniquets" "Suggestions should inspect ACE tourniquet state by limb."
Assert-SourceContains "ace_medical_fractures" "Suggestions should inspect ACE fracture state by limb."
Assert-SourceContains "private _hasAnyTourniquet" "Suggestions should keep follow-up wound care visible after a tourniquet stops bleeding."
Assert-SourceContains "ACE_splint" "Suggestions should include splint requirements for fractured limbs."
Assert-SourceContains "kat_chestSeal" "Suggestions should include chest seal requirements for torso gunshots."
Assert-SourceContains "ACE_painkillers" "Suggestions should include painkiller requirements after urgent first aid."
Assert-SourceContains "ACE_morphine" "Suggestions should include morphine requirements for treated painful limb injuries."
Assert-SourceContains "Blood Transfusion" "Suggestions should recommend blood transfusion for blood loss."
Assert-SourceContains "Tourniquet Removal" "Suggestions should recommend tourniquet removal after bandaging."
Assert-SourceContains "\(Applied\)" "Requirement labels should show an applied indicator."
Assert-SourceContains "_fnc_formatRequirementName" "Requirement display should format item names with applied state."
Assert-NowBlockDoesNotContain "_fnc_addUseMissingLines" "NOW should not use the generic MISSING helper."
Assert-NowBlockDoesNotContain "MISSING:" "NOW block should not emit generic MISSING wording."
Assert-NowBlockDoesNotContain "_nowTreatmentRows resize" "FIRST AID should show all pending treatment steps in order instead of capping rows."
Assert-NowBlockDoesNotContain "_painValue > 0.15 && \{ !_hasLifeThreatTreatmentRows \}" "Pain control should be appended in order, not hidden while urgent rows exist."
Assert-NowBlockDoesNotContain '"Find wound source\. Pack, bandage' "Generic active bleeding fallback should not skip tourniquet."
Assert-TextContains (Get-NowGenerationBlock) "Find wound source\. Apply tourniquet first" "Generic active bleeding fallback should recommend tourniquet before bandage."

Assert-InOrder (Get-RequirementDefinitionBlock) @(
    "Tourniquet",
    "Splint",
    "Packing Bandage",
    "Tourniquet Removal",
    "Chest Seal",
    "Painkillers",
    "Morphine",
    "Blood Transfusion"
) "Treatment source should define first-aid items in the requested priority order."
Assert-TextDoesNotContain (Get-RequirementDefinitionBlock) '\[_bleedRequirements, "Elastic Bandage"' "Bleeding requirement should render one bandage recommendation line, not duplicate bandage alternatives."

Assert-TextContains $source '\["FIRST AID", _nowLines\]' "Checklist data should expose FIRST AID as the first tab."
Assert-TextContains $source '\["VITALS", _recheckLines\]' "Checklist data should expose VITALS as the second tab."
Assert-TextDoesNotContain $source '\["TRANSPORT"' "Checklist data should not expose a TRANS tab."
Assert-TextDoesNotContain $source "private _firstLines" "FIRST on-scene content should be merged into FIRST AID."
Assert-TextContains (Get-NowGenerationBlock) "Scan casualties\. Treat lifesaving threats only\." "FIRST AID should include the merged on-scene reminder."

Assert-InOrder $source @(
    "private _responseText",
    "private _painText",
    "private _heartRateText",
    "private _bloodPressureText",
    "private _breathingText",
    "private _bloodText"
) "RECHECK vital labels should be prepared in Response, Pain, Heart Rate, Blood Pressure, Breathing, Blood order."
Assert-InOrder $source @(
    'format ["[ ] %1", _responseText]',
    'format ["[ ] %1", _painText]',
    'format ["[ ] %1", _heartRateText]',
    'format ["[ ] %1", _bloodPressureText]',
    'format ["[ ] %1", _breathingText]',
    'format ["[ ] %1", _bloodText]'
) "RECHECK should render Response, Pain, Heart Rate, Blood Pressure, Breathing, Blood in that order."
Assert-SourceContains "ace_medical_bloodPressure" "RECHECK should read ACE patient blood pressure."
Assert-SourceContains "Blood Pressure:" "RECHECK should display blood pressure text."
Assert-TextDoesNotContain $source "Oxygen in the Blood" "RECHECK should not display oxygen-in-blood wording."
Assert-TextDoesNotContain $source "_spo2Text" "RECHECK should not build a SpO2 line."
Assert-SourceContains "kat_breathing_breathRate" "Breathing status should read KAT patient respiratory rate."
Assert-SourceContains "Breathing: Rapid" "Breathing status should classify rapid breathing."
Assert-SourceContains "Breathing: Normal" "Breathing status should classify normal breathing."
Assert-SourceContains "kat_airway_obstruction" "Airway guidance should read KAT patient obstruction state."
Assert-SourceContains "kat_airway_occluded" "Airway guidance should read KAT patient occlusion state."
Assert-SourceContains "private _needsAirwayAction" "Airway adjunct guidance should be gated by actual airway need."
Assert-TextDoesNotContain (Get-NowGenerationBlock) "if \(_isUnconscious\) then \{\s*_nowTreatmentRows pushBack" "NOW should not suggest Airway Adjunct solely because the patient is unconscious."
Assert-TextDoesNotContain $source "Confirm bleeding remains controlled" "RECHECK should not include redundant bleeding confirmation."
Assert-TextDoesNotContain $source "Confirm airway and breathing" "RECHECK should not include redundant airway/breathing confirmation."
Assert-TextDoesNotContain $source "Update handoff notes before transport" "RECHECK should not include redundant handoff note prompt."

Assert-TextDoesNotContain $uiSource "STR_AWARE_TAB_FIRST" "UI should not render a FIRST tab label."
Assert-TextDoesNotContain $stringtableSource "STR_AWARE_TAB_FIRST" "Stringtable should not keep an active FIRST tab key."
Assert-TextContains $stringtableSource "FIRST AID CHECKLIST" "Title should read FIRST AID CHECKLIST."
Assert-TextContains $stringtableSource "<Original>FIRST AID</Original>" "First tab should read FIRST AID."
Assert-TextContains $stringtableSource "<Original>VITALS</Original>" "Vitals tab should read VITALS."
Assert-TextDoesNotContain $stringtableSource "STR_AWARE_TAB_TRANSPORT" "Stringtable should not keep an active TRANS tab key."
Assert-TextContains $renderSource "private _tabCount = count _tabControls;" "Renderer should size the remaining tabs dynamically."
Assert-TextContains $renderSource "_display displayCtrl 5204,\s*_display displayCtrl 5205" "Renderer should use only two active tab controls."
Assert-TextDoesNotContain $renderSource "_display displayCtrl 5206" "Renderer should not wire a third active tab control."
Assert-TextContains $inputSource "private _tabKeys = \[2, 3\];" "Input handler should only map keys 1-2 to the remaining tabs."
Assert-TextContains $configSource "class registerMedicalTreatmentTracking" "Config should register the medical treatment tracking function."
Assert-TextContains $initSource "\[\] call AWARE_fnc_registerMedicalTreatmentTracking;" "Init should start treatment tracking for patient-side applied item state."
Assert-TextContains $trackingSource "ace_medical_treatment_bandaged" "Tracking should subscribe to ACE bandage treatment events."
Assert-TextContains $trackingSource "ace_treatmentSucceded" "Tracking should subscribe to generic completed treatment events."
Assert-TextContains $trackingSource "AWARE_appliedMedicalItems" "Tracking should store applied medical items on the patient."
Assert-TextContains $trackingSource "ACE_packingBandage" "Tracking should normalize packing bandage treatments to the ACE item class."
Assert-TextContains $trackingSource "ACE_tourniquet" "Tracking should normalize tourniquet treatments to the ACE item class."
Assert-TextContains $trackingSource "ACE_splint" "Tracking should normalize splint treatments to the ACE item class."
Assert-TextContains $trackingSource "kat_chestSeal" "Tracking should normalize chest seal treatments to the KAT item class."

Write-Output "FIRST AID procedure suggestion source checks passed."
