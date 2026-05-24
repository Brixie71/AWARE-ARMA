/*
    Function: AWARE_fnc_setBodyIndicatorVisible
    Shows or hides the AWARE BODY HUD controls.
*/

params [
    "_display",
    ["_isVisible", true]
];

if (isNull _display) exitWith {};

disableSerialization;

private _headerControl = _display displayCtrl 5100;
private _bodyGroup = _display displayCtrl 5099;

if (!isNull _headerControl) then {
    _headerControl ctrlShow _isVisible;
};
if (!isNull _bodyGroup) then {
    _bodyGroup ctrlShow _isVisible;
};

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

if (!_isVisible && { !isNull _bodyGroup }) then {
    {
        private _statusControl = _bodyGroup controlsGroupCtrl _x;
        if (!isNull _statusControl) then {
            _statusControl ctrlShow false;
        };
    } forEach [5101, 5102, 5103, 5104, 5105, 5106, 5107, 5108];
};

if (_isVisible && { !isNull _bodyGroup }) then {
    {
        private _statusControl = _bodyGroup controlsGroupCtrl _x;
        if (!isNull _statusControl) then {
            _statusControl ctrlShow true;
        };
    } forEach [5101, 5102, 5103, 5104, 5105, 5106];
};
