/*
    Function: AWARE_fnc_getMedicalTarget
    Returns the patient currently selected by the medical menu or aimed at by the player.
*/

if (!hasInterface) exitWith { objNull };

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
    private _cursorTargets = [cursorTarget, cursorObject];
    {
        if (isNull _target && { !isNull _x } && { _x isKindOf "CAManBase" } && { _x distance player <= 12 }) then {
            _target = _x;
        };
    } forEach _cursorTargets;
};

if (isNull _target) then {
    player
} else {
    _target
}
