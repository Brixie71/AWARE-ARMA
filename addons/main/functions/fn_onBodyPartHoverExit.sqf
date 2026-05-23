/*
    Function: AWARE_fnc_onBodyPartHoverExit
    Hides the body part details dropdown.
*/

params ["_control"];

if (isNull _control) exitWith {};

disableSerialization;

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _dropdownControl = _display displayCtrl 5110;
if (!isNull _dropdownControl) then {
    _dropdownControl ctrlShow false;
};

{
    private _rowControl = _display displayCtrl _x;
    if (!isNull _rowControl) then {
        _rowControl ctrlShow false;
    };
} forEach [5111, 5112, 5113, 5114, 5115, 5116, 5117, 5118];
