/*
    Function: AWARE_fnc_getMedicalTarget
    Returns the patient currently selected by the medical menu.
*/

if (!hasInterface) exitWith { objNull };

disableSerialization;

private _aceMedicalMenuDisplay = findDisplay 38580;
private _aceMedicalMenuDisplayNs = uiNamespace getVariable ["ace_medical_gui_menuDisplay", displayNull];
private _isMedicalMenuOpen = (!isNull _aceMedicalMenuDisplay) || { !isNull _aceMedicalMenuDisplayNs };

if (!_isMedicalMenuOpen) exitWith { player };

private _target = objNull;
private _medicalTargets = [
    missionNamespace getVariable ["ace_medical_gui_target", objNull],
    uiNamespace getVariable ["ace_medical_gui_target", objNull],
    missionNamespace getVariable ["ace_medical_menu_target", objNull],
    uiNamespace getVariable ["ace_medical_menu_target", objNull]
];

{
    if (isNull _target && { !isNull _x } && { _x isKindOf "CAManBase" }) then {
        _target = _x;
    };
} forEach _medicalTargets;

if (isNull _target) then {
    player
} else {
    _target
}
