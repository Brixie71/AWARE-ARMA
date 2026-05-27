$ErrorActionPreference = "Stop"

$functionPath = Join-Path $PSScriptRoot "..\addons\main\functions\fn_getSuggestedMedicalProcedures.sqf"
$source = Get-Content -Raw $functionPath

function Assert-SourceContains {
    param (
        [string]$Pattern,
        [string]$Message
    )

    if ($source -notmatch $Pattern) {
        throw $Message
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

    $firstStart = $source.IndexOf("private _firstLines = [", $nowStart)
    if ($firstStart -lt 0) {
        throw "Could not find FIRST generation block after NOW block."
    }

    return $source.Substring($nowStart, $firstStart - $nowStart)
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

Write-Output "NOW procedure suggestion source checks passed."
