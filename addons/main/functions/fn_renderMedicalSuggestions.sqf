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

private _isEnabled = missionNamespace getVariable ["AWARE_medicalSuggestions_enabled", true];
private _isVisible = uiNamespace getVariable ["AWARE_MedicalSuggestionsVisible", false];
if (!_isEnabled) then {
    _isVisible = false;
};
if (_forceVisible isEqualType true) then {
    _isVisible = _forceVisible && { _isEnabled };
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
private _pageUpControl = _display displayCtrl 5208;
private _pageDownControl = _display displayCtrl 5209;

if (isNull _backgroundControl || { isNull _headerControl } || { isNull _scrollGroup } || { isNull _bodyControl } || { isNull _hintControl }) exitWith {};

private _scale = missionNamespace getVariable ["AWARE_medicalSuggestions_scale", 1];
_scale = (_scale max 0.85) min 1.25;

private _defaultPosition = [safeZoneX + 0.02, safeZoneY + (0.23 * safeZoneH)];
private _panelPosition = uiNamespace getVariable ["AWARE_MedicalSuggestionPosition", _defaultPosition];
if !(_panelPosition isEqualType []) then {
    _panelPosition = _defaultPosition;
};

private _panelX = _panelPosition param [0, _defaultPosition select 0];
private _panelY = _panelPosition param [1, _defaultPosition select 1];
private _panelW = 0.46 * _scale;
private _panelH = 0.58 * safeZoneH * _scale;
private _padX = 0.004 * _scale;
private _headerH = 0.034 * _scale;
private _tabGap = 0.006 * _scale;
private _tabY = _panelY + (0.038 * safeZoneH * _scale);
private _tabH = 0.028 * _scale;
private _footerH = 0.034 * safeZoneH * _scale;
private _contentX = _panelX + _padX;
private _contentY = _panelY + (0.072 * safeZoneH * _scale);
private _contentW = _panelW - (2 * _padX);
private _contentH = _panelH - (_contentY - _panelY) - _footerH - (0.006 * safeZoneH * _scale);
private _tabW = (_contentW - (3 * _tabGap)) / 4;
private _scrollButtonGap = 0.006 * _scale;
private _scrollButtonY = _panelY + _panelH - _footerH;
private _scrollButtonH = 0.026 * safeZoneH * _scale;
private _scrollButtonW = (_contentW - _scrollButtonGap) / 2;

_backgroundControl ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
_backgroundControl ctrlCommit 0;
_headerControl ctrlSetPosition [_panelX, _panelY, _panelW, _headerH];
_headerControl ctrlCommit 0;
_scrollGroup ctrlSetPosition [_contentX, _contentY, _contentW, _contentH];
_scrollGroup ctrlCommit 0;

private _tabRects = [];
{
    if (!isNull _x) then {
        private _tabX = _contentX + (_forEachIndex * (_tabW + _tabGap));
        _x ctrlSetPosition [_tabX, _tabY, _tabW, _tabH];
        _x ctrlCommit 0;
        _tabRects pushBack [_tabX, _tabY, _tabW, _tabH];
    } else {
        _tabRects pushBack [0, 0, 0, 0];
    };
} forEach _tabControls;

uiNamespace setVariable ["AWARE_MedicalSuggestionPanelRect", [_panelX, _panelY, _panelW, _panelH]];
uiNamespace setVariable ["AWARE_MedicalSuggestionHeaderRect", [_panelX, _panelY, _panelW, _headerH]];
uiNamespace setVariable ["AWARE_MedicalSuggestionTabRects", _tabRects];
private _scrollButtonRects = [];
if (!isNull _pageUpControl) then {
    _pageUpControl ctrlSetPosition [_contentX, _scrollButtonY, _scrollButtonW, _scrollButtonH];
    _pageUpControl ctrlCommit 0;
    _scrollButtonRects pushBack [_contentX, _scrollButtonY, _scrollButtonW, _scrollButtonH, -1];
};
if (!isNull _pageDownControl) then {
    private _pageDownX = _contentX + _scrollButtonW + _scrollButtonGap;
    _pageDownControl ctrlSetPosition [_pageDownX, _scrollButtonY, _scrollButtonW, _scrollButtonH];
    _pageDownControl ctrlCommit 0;
    _scrollButtonRects pushBack [_pageDownX, _scrollButtonY, _scrollButtonW, _scrollButtonH, 1];
};
uiNamespace setVariable ["AWARE_MedicalSuggestionScrollButtonRects", _scrollButtonRects];

if (!_isVisible) exitWith {
    uiNamespace setVariable ["AWARE_MedicalSuggestionDragging", false];
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
    if (!isNull _pageUpControl) then {
        _pageUpControl ctrlShow false;
    };
    if (!isNull _pageDownControl) then {
        _pageDownControl ctrlShow false;
    };
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
if (!isNull _pageUpControl) then {
    _pageUpControl ctrlShow true;
};
if (!isNull _pageDownControl) then {
    _pageDownControl ctrlShow true;
};

private _tabs = uiNamespace getVariable ["AWARE_MedicalSuggestionLines", [["MARCH", ["No suggestion data yet."]]]];
if !(_tabs isEqualType []) then {
    _tabs = [["MARCH", ["No suggestion data yet."]]];
};

private _activeTab = uiNamespace getVariable ["AWARE_MedicalSuggestionTab", 0];
_activeTab = (_activeTab max 0) min 3;
private _lastActiveTab = uiNamespace getVariable ["AWARE_MedicalSuggestionLastTab", -1];
if (_lastActiveTab != _activeTab) then {
    uiNamespace setVariable ["AWARE_MedicalSuggestionLastTab", _activeTab];
    uiNamespace setVariable ["AWARE_MedicalSuggestionScrollOffset", 0];
};

{
    if (!isNull _x) then {
        if (_forEachIndex == _activeTab) then {
            _x ctrlSetBackgroundColor [0.79, 0.48, 0.08, 0.98];
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

private _lineHeight = 0.036 * safeZoneH;
if (_activeTab in [0, 1]) then {
    _lineHeight = 0.033 * safeZoneH;
};

private _bodyHeight = (((count _lines) max 1) * _lineHeight) + (0.045 * safeZoneH);
private _maxScroll = (_bodyHeight - _contentH) max 0;
private _scrollOffset = uiNamespace getVariable ["AWARE_MedicalSuggestionScrollOffset", 0];
_scrollOffset = (_scrollOffset max 0) min _maxScroll;
uiNamespace setVariable ["AWARE_MedicalSuggestionScrollOffset", _scrollOffset];
uiNamespace setVariable ["AWARE_MedicalSuggestionScrollMax", _maxScroll];
uiNamespace setVariable ["AWARE_MedicalSuggestionScrollPage", (_contentH * 0.75) max (0.1 * safeZoneH)];

private _buttonAlpha = [0.45, 0.92] select (_maxScroll > 0);
if (!isNull _pageUpControl) then {
    _pageUpControl ctrlSetBackgroundColor [0.08, 0.08, 0.08, _buttonAlpha];
};
if (!isNull _pageDownControl) then {
    _pageDownControl ctrlSetBackgroundColor [0.08, 0.08, 0.08, _buttonAlpha];
};

_bodyControl ctrlSetPosition [0, -_scrollOffset, _contentW - (0.018 * _scale), _bodyHeight];
_bodyControl ctrlCommit 0;
_bodyControl ctrlSetStructuredText parseText (_lines joinString "<br/>");
