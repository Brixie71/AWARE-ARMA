/*
    Function: AWARE_fnc_onBodyPartHover
    Shows a dropdown with details for the hovered body part row.
*/

params ["_control"];

if (isNull _control) exitWith {};

disableSerialization;

private _display = ctrlParent _control;
if (isNull _display) exitWith {};

private _dropdownControl = _display displayCtrl 5110;
if (isNull _dropdownControl) exitWith {};

private _detailsByIdc = uiNamespace getVariable ["AWARE_BodyIndicatorDetails", createHashMap];
private _detailRows = ["Status: Unavailable."];
if (_detailsByIdc isEqualType createHashMap) then {
    _detailRows = _detailsByIdc getOrDefault [str (ctrlIDC _control), _detailRows];
};

if !(_detailRows isEqualType []) then {
    _detailRows = ["Status: Unavailable."];
};

private _rowIds = [5111, 5112, 5113, 5114, 5115, 5116, 5117, 5118];
private _rowsToShow = (count _detailRows) min (count _rowIds);

private _partPos = ctrlPosition _control;
private _parentGroup = ctrlParentControlsGroup _control;
private _groupOffsetX = 0;
private _groupOffsetY = 0;
private _scrollOffsetY = 0;

if (!isNull _parentGroup) then {
    private _groupPos = ctrlPosition _parentGroup;
    private _scrollValues = ctrlScrollValues _parentGroup;
    _groupOffsetX = _groupPos param [0, 0];
    _groupOffsetY = _groupPos param [1, 0];
    _scrollOffsetY = _scrollValues param [1, 0];
};

private _dropX = _groupOffsetX + (_partPos param [0, 0]);
private _dropY = _groupOffsetY + (_partPos param [1, 0]) - _scrollOffsetY + (_partPos param [3, 0]) + 0.001;
private _dropW = _partPos param [2, 0.325];
private _rowHeight = 0.021 * safeZoneH;
private _rowGap = 0.0018 * safeZoneH;
private _padding = 0.0035 * safeZoneH;
private _dropH = (_padding * 2) + (_rowsToShow * _rowHeight) + (((_rowsToShow - 1) max 0) * _rowGap);

_dropdownControl ctrlSetPosition [_dropX, _dropY, _dropW, _dropH];
_dropdownControl ctrlCommit 0;
_dropdownControl ctrlShow true;

{
    private _rowControl = _display displayCtrl _x;
    if !(isNull _rowControl) then {
        if (_forEachIndex < _rowsToShow) then {
            private _rowText = _detailRows param [_forEachIndex, ""];
            private _rowY = _dropY + _padding + (_forEachIndex * (_rowHeight + _rowGap));
            _rowControl ctrlSetText _rowText;
            _rowControl ctrlSetPosition [_dropX + 0.004, _rowY, _dropW - 0.008, _rowHeight];
            _rowControl ctrlCommit 0;
            _rowControl ctrlShow true;
        } else {
            _rowControl ctrlShow false;
        };
    };
} forEach _rowIds;
