$ErrorActionPreference = 'Stop'

if (-not $PSScriptRoot) {
    $PSScriptRoot = (Get-Location).Path
}

Push-Location $PSScriptRoot
try {
    .\hemtt.exe build
} finally {
    Pop-Location
}
