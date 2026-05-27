/*
    Function: AWARE_fnc_getMedicalMenuDisplay
    Returns the active ACE/KAT medical menu display, or displayNull.
*/

if (!hasInterface) exitWith { displayNull };

disableSerialization;

private _medicalMenuDisplay = findDisplay 38580;
if (!isNull _medicalMenuDisplay) exitWith { _medicalMenuDisplay };

uiNamespace getVariable ["ace_medical_gui_menuDisplay", displayNull]
