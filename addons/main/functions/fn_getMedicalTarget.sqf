/*
    Function: AWARE_fnc_getMedicalTarget
    Returns the patient currently selected by the medical menu.
*/

if (!hasInterface) exitWith { objNull };

disableSerialization;

private _medicalMenuDisplay = [] call AWARE_fnc_getMedicalMenuDisplay;
if (isNull _medicalMenuDisplay) exitWith { player };

private _target = objNull;
private _medicalTargets = [
    missionNamespace getVariable ["ace_medical_gui_target", objNull],
    uiNamespace getVariable ["ace_medical_gui_target", objNull],
    missionNamespace getVariable ["ace_medical_menu_target", objNull],
    uiNamespace getVariable ["ace_medical_menu_target", objNull]
];

{
    if (!isNull _x && { _x isKindOf "CAManBase" }) exitWith {
        _target = _x;
    };
} forEach _medicalTargets;

if (isNull _target) then {
    player
} else {
    _target
}
