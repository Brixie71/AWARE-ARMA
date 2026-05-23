/*
    Function: AWARE_fnc_renderMedicalSuggestions
    Shows or hides the left-side treatment extension and updates checklist text.
*/

params [
    ["_forceVisible", -1]
];

disableSerialization;

private _display = uiNamespace getVariable ["AWARE_MedicalSuggestionExtension", displayNull];
if (isNull _display) exitWith {};

private _isVisible = uiNamespace getVariable ["AWARE_MedicalSuggestionsVisible", false];
if (_forceVisible isEqualType true) then {
    _isVisible = _forceVisible;
    uiNamespace setVariable ["AWARE_MedicalSuggestionsVisible", _isVisible];
};

private _backgroundControl = _display displayCtrl 5200;
private _headerControl = _display displayCtrl 5201;
private _scrollGroup = _display displayCtrl 5199;
private _bodyControl = if (!isNull _scrollGroup) then {
    _scrollGroup controlsGroupCtrl 5202
} else {
    _display displayCtrl 5202
};
private _hintControl = _display displayCtrl 5203;
private _tabControls = [
    _display displayCtrl 5204,
    _display displayCtrl 5205,
    _display displayCtrl 5206,
    _display displayCtrl 5207
];

if (isNull _backgroundControl || { isNull _headerControl } || { isNull _scrollGroup } || { isNull _bodyControl } || { isNull _hintControl }) exitWith {};

if (!_isVisible) exitWith {
    _backgroundControl ctrlShow false;
    _headerControl ctrlShow false;
    _scrollGroup ctrlShow false;
    _bodyControl ctrlShow false;
    _hintControl ctrlShow false;
    {
        if (!isNull _x) then {
            _x ctrlShow false;
        };
    } forEach _tabControls;
};

_backgroundControl ctrlShow true;
_headerControl ctrlShow true;
_scrollGroup ctrlShow true;
_bodyControl ctrlShow true;
_hintControl ctrlShow false;
{
    if (!isNull _x) then {
        _x ctrlShow true;
    };
} forEach _tabControls;

private _tabs = uiNamespace getVariable ["AWARE_MedicalSuggestionLines", [["MARCH", ["No suggestion data yet."]]]];
if !(_tabs isEqualType []) then {
    _tabs = [["MARCH", ["No suggestion data yet."]]];
};

private _activeTab = uiNamespace getVariable ["AWARE_MedicalSuggestionTab", 0];
_activeTab = (_activeTab max 0) min 3;

{
    if (!isNull _x) then {
        if (_forEachIndex == _activeTab) then {
            _x ctrlSetBackgroundColor [0.12, 0.42, 0.58, 0.98];
        } else {
            _x ctrlSetBackgroundColor [0.08, 0.08, 0.08, 0.9];
        };
    };
} forEach _tabControls;

private _activeEntry = _tabs param [_activeTab, ["MARCH", ["No suggestion data yet."]]];
private _lines = _activeEntry param [1, ["No suggestion data yet."]];
if !(_lines isEqualType []) then {
    _lines = ["No suggestion data yet."];
};

private _bodyHeight = (((count _lines) max 1) * 0.044 * safeZoneH) + (0.04 * safeZoneH);
_bodyControl ctrlSetPosition [0, 0, 0.434, _bodyHeight];
_bodyControl ctrlCommit 0;
_bodyControl ctrlSetStructuredText parseText (_lines joinString "<br/>");
