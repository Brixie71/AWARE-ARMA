$ErrorActionPreference = "Stop"

$functionPath = Join-Path $PSScriptRoot "..\addons\main\functions\fn_getSuggestedMedicalProcedures.sqf"
$renderPath = Join-Path $PSScriptRoot "..\addons\main\functions\fn_renderMedicalSuggestions.sqf"
$inputPath = Join-Path $PSScriptRoot "..\addons\main\functions\fn_registerMedicalSuggestionInput.sqf"
$uiPath = Join-Path $PSScriptRoot "..\addons\main\ui\medicalSuggestion.hpp"
$stringtablePath = Join-Path $PSScriptRoot "..\addons\main\stringtable.xml"
$source = Get-Content -Raw $functionPath
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

    $transportStart = $source.IndexOf("private _transportLines = [", $nowStart)
    if ($transportStart -lt 0) {
        throw "Could not find TRANSPORT generation block after NOW block."
    }

    return $source.Substring($nowStart, $transportStart - $nowStart)
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

Assert-SourceContains "Required Item:" "NOW missing inventory indicator should use 'Required Item:' wording."
Assert-SourceContains "private _maxNowTreatmentProcedures = 2;" "NOW should cap active treatment procedures at two."
Assert-SourceContains "private _nowTreatmentRows = \[\];" "NOW should collect candidate treatment rows before rendering."
Assert-SourceContains "_nowTreatmentRows pushBack" "NOW should render from prioritized treatment rows."
Assert-NowBlockDoesNotContain "_fnc_addUseMissingLines" "NOW should not use the generic MISSING helper."
Assert-NowBlockDoesNotContain "MISSING:" "NOW block should not emit generic MISSING wording."

Assert-TextDoesNotContain $source '\["FIRST"' "Checklist data should not expose a separate FIRST tab."
Assert-TextDoesNotContain $source "private _firstLines" "FIRST on-scene content should be merged into NOW."
Assert-TextContains (Get-NowGenerationBlock) "Scan casualties\. Treat lifesaving threats only\." "NOW should include the merged FIRST on-scene reminder."

Assert-InOrder $source @(
    "private _responseText",
    "private _painText",
    "private _heartRateText",
    "private _spo2Text",
    "private _bloodText"
) "RECHECK vital labels should be prepared in Response, Pain, Heart Rate, SpO2, Blood order."
Assert-InOrder $source @(
    'format ["[ ] %1", _responseText]',
    'format ["[ ] %1", _painText]',
    'format ["[ ] %1", _heartRateText]',
    'format ["[ ] %1", _spo2Text]',
    'format ["[ ] %1", _bloodText]'
) "RECHECK should render Response, Pain, Heart Rate, SpO2, Blood in that order."
Assert-TextDoesNotContain $source "Confirm bleeding remains controlled" "RECHECK should not include redundant bleeding confirmation."
Assert-TextDoesNotContain $source "Confirm airway and breathing" "RECHECK should not include redundant airway/breathing confirmation."
Assert-TextDoesNotContain $source "Update handoff notes before transport" "RECHECK should not include redundant handoff note prompt."

Assert-TextDoesNotContain $uiSource "STR_AWARE_TAB_FIRST" "UI should not render a FIRST tab label."
Assert-TextDoesNotContain $stringtableSource "STR_AWARE_TAB_FIRST" "Stringtable should not keep an active FIRST tab key."
Assert-TextContains $renderSource "private _tabCount = count _tabControls;" "Renderer should size the remaining tabs dynamically."
Assert-TextContains $inputSource "private _tabKeys = \[2, 3, 4\];" "Input handler should only map keys 1-3 to the remaining tabs."

Write-Output "NOW procedure suggestion source checks passed."
