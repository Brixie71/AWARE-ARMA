/*
    Function: AWARE_fnc_registerMedicalSuggestionInput
    Registers tab, scroll, and drag input handlers on the active medical menu display.
*/

params [
    ["_tabDisplay", displayNull, [displayNull]]
];

if (isNull _tabDisplay) exitWith {};

disableSerialization;

private _registeredDisplay = uiNamespace getVariable ["AWARE_MedicalSuggestionTabDisplay", displayNull];
if (_registeredDisplay isEqualTo _tabDisplay) exitWith {};

private _registeredHandlers = [
    ["KeyDown", "AWARE_MedicalSuggestionTabEH"],
    ["MouseButtonDown", "AWARE_MedicalSuggestionTabMouseEH"],
    ["MouseButtonUp", "AWARE_MedicalSuggestionMouseUpEH"],
    ["MouseMoving", "AWARE_MedicalSuggestionMouseMoveEH"]
];

{
    _x params ["_eventName", "_handlerKey"];
    private _handlerId = uiNamespace getVariable [_handlerKey, -1];
    if (!isNull _registeredDisplay && { _handlerId >= 0 }) then {
        _registeredDisplay displayRemoveEventHandler [_eventName, _handlerId];
    };
} forEach _registeredHandlers;

private _tabEh = _tabDisplay displayAddEventHandler ["KeyDown", {
    params ["_display", "_dikCode"];

    if !(missionNamespace getVariable ["AWARE_medicalSuggestions_enabled", true]) exitWith { false };

    private _tabKeys = [2, 3, 4];
    private _tabIndex = _tabKeys find _dikCode;
    if (_tabIndex > -1) then {
        uiNamespace setVariable ["AWARE_MedicalSuggestionTab", _tabIndex];
        uiNamespace setVariable ["AWARE_MedicalSuggestionScrollOffset", 0];
        [true] call AWARE_fnc_renderMedicalSuggestions;
        true
    } else {
        false
    };
}];

private _tabMouseEh = _tabDisplay displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_mouseX", "_mouseY"];

    if (_button != 0) exitWith { false };
    if !(missionNamespace getVariable ["AWARE_medicalSuggestions_enabled", true]) exitWith { false };
    if !(uiNamespace getVariable ["AWARE_MedicalSuggestionsVisible", false]) exitWith { false };

    private _tabRects = uiNamespace getVariable ["AWARE_MedicalSuggestionTabRects", []];
    private _tabIndex = -1;

    {
        _x params ["_tabX", "_tabY", "_tabW", "_tabH"];
        if (_mouseX >= _tabX && { _mouseX <= (_tabX + _tabW) } && { _mouseY >= _tabY } && { _mouseY <= (_tabY + _tabH) }) exitWith {
            _tabIndex = _forEachIndex;
        };
    } forEach _tabRects;

    if (_tabIndex > -1) then {
        uiNamespace setVariable ["AWARE_MedicalSuggestionTab", _tabIndex];
        uiNamespace setVariable ["AWARE_MedicalSuggestionScrollOffset", 0];
        [true] call AWARE_fnc_renderMedicalSuggestions;
        true
    } else {
        private _scrollButtonRects = uiNamespace getVariable ["AWARE_MedicalSuggestionScrollButtonRects", []];
        private _scrollDirection = 0;
        {
            _x params ["_buttonX", "_buttonY", "_buttonW", "_buttonH", "_direction"];
            if (_mouseX >= _buttonX && { _mouseX <= (_buttonX + _buttonW) } && { _mouseY >= _buttonY } && { _mouseY <= (_buttonY + _buttonH) }) exitWith {
                _scrollDirection = _direction;
            };
        } forEach _scrollButtonRects;

        if (_scrollDirection != 0) exitWith {
            private _scrollOffset = uiNamespace getVariable ["AWARE_MedicalSuggestionScrollOffset", 0];
            private _scrollPage = uiNamespace getVariable ["AWARE_MedicalSuggestionScrollPage", 0.2];
            private _scrollMax = uiNamespace getVariable ["AWARE_MedicalSuggestionScrollMax", 0];
            _scrollOffset = ((_scrollOffset + (_scrollDirection * _scrollPage)) max 0) min _scrollMax;
            uiNamespace setVariable ["AWARE_MedicalSuggestionScrollOffset", _scrollOffset];
            [true] call AWARE_fnc_renderMedicalSuggestions;
            true
        };

        private _canDrag = missionNamespace getVariable ["AWARE_medicalSuggestions_draggable", true];
        private _headerRect = uiNamespace getVariable ["AWARE_MedicalSuggestionHeaderRect", []];
        if (!_canDrag || { _headerRect isEqualTo [] }) exitWith { false };

        _headerRect params ["_panelX", "_panelY", "_panelW", "_panelH"];
        if (_mouseX >= _panelX && { _mouseX <= (_panelX + _panelW) } && { _mouseY >= _panelY } && { _mouseY <= (_panelY + _panelH) }) then {
            uiNamespace setVariable ["AWARE_MedicalSuggestionDragging", true];
            uiNamespace setVariable ["AWARE_MedicalSuggestionDragStartMouse", [_mouseX, _mouseY]];
            uiNamespace setVariable ["AWARE_MedicalSuggestionDragStartPosition", [_panelX, _panelY]];
            true
        } else {
            false
        };
    };
}];

private _mouseUpEh = _tabDisplay displayAddEventHandler ["MouseButtonUp", {
    params ["_display", "_button"];

    if (_button == 0) then {
        uiNamespace setVariable ["AWARE_MedicalSuggestionDragging", false];
        uiNamespace setVariable ["AWARE_MedicalSuggestionDragStartMouse", nil];
        uiNamespace setVariable ["AWARE_MedicalSuggestionDragStartPosition", nil];
    };

    false
}];

private _mouseMoveEh = _tabDisplay displayAddEventHandler ["MouseMoving", {
    params ["_display", "_mouseX", "_mouseY"];

    if !(uiNamespace getVariable ["AWARE_MedicalSuggestionDragging", false]) exitWith { false };
    if !(missionNamespace getVariable ["AWARE_medicalSuggestions_draggable", true]) exitWith {
        uiNamespace setVariable ["AWARE_MedicalSuggestionDragging", false];
        false
    };

    private _rect = uiNamespace getVariable ["AWARE_MedicalSuggestionPanelRect", [safeZoneX + 0.02, safeZoneY + (0.23 * safeZoneH), 0.46, 0.58 * safeZoneH]];
    _rect params ["_panelX", "_panelY", "_panelW", "_panelH"];

    private _dragStartMouse = uiNamespace getVariable ["AWARE_MedicalSuggestionDragStartMouse", [_mouseX, _mouseY]];
    private _dragStartPosition = uiNamespace getVariable ["AWARE_MedicalSuggestionDragStartPosition", [_panelX, _panelY]];
    _dragStartMouse params ["_startMouseX", "_startMouseY"];
    _dragStartPosition params ["_startPanelX", "_startPanelY"];

    private _nextX = ((_startPanelX + (_mouseX - _startMouseX)) max safeZoneX) min (safeZoneX + safeZoneW - _panelW);
    private _nextY = ((_startPanelY + (_mouseY - _startMouseY)) max safeZoneY) min (safeZoneY + safeZoneH - _panelH);

    uiNamespace setVariable ["AWARE_MedicalSuggestionPosition", [_nextX, _nextY]];
    [true] call AWARE_fnc_renderMedicalSuggestions;
    true
}];

uiNamespace setVariable ["AWARE_MedicalSuggestionTabDisplay", _tabDisplay];
uiNamespace setVariable ["AWARE_MedicalSuggestionTabEH", _tabEh];
uiNamespace setVariable ["AWARE_MedicalSuggestionTabMouseEH", _tabMouseEh];
uiNamespace setVariable ["AWARE_MedicalSuggestionMouseUpEH", _mouseUpEh];
uiNamespace setVariable ["AWARE_MedicalSuggestionMouseMoveEH", _mouseMoveEh];
