/*
    Function: AWARE_fnc_startBodyIndicator
    Starts the client-side HUD loop for body part indicators.
*/

if (!hasInterface) exitWith {};

private _runningHandle = uiNamespace getVariable ["AWARE_bodyIndicatorLoop", scriptNull];
if (!isNull _runningHandle && { !scriptDone _runningHandle }) exitWith {};

private _loopHandle = [] spawn {
    disableSerialization;
    waitUntil { !isNull findDisplay 46 };

    private _bodyHudLayer = ["AWARE_BodyHudLayer"] call BIS_fnc_rscLayer;
    private _medicalExtLayer = ["AWARE_MedicalExtLayer"] call BIS_fnc_rscLayer;

    while { true } do {
        if (isNull player) then {
            uiSleep 0.25;
        } else {
            private _display = uiNamespace getVariable ["AWARE_BodyIndicator", displayNull];
            if (isNull _display) then {
                _bodyHudLayer cutRsc ["AWARE_BodyIndicator", "PLAIN"];
                _display = uiNamespace getVariable ["AWARE_BodyIndicator", displayNull];
                if (!isNull _display) then {
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

                    private _bodyGroup = _display displayCtrl 5099;
                    {
                        private _statusControl = if (!isNull _bodyGroup) then {
                            _bodyGroup controlsGroupCtrl _x
                        } else {
                            _display displayCtrl _x
                        };
                        if (!isNull _statusControl) then {
                            _statusControl ctrlShow false;
                        };
                    } forEach [5107, 5108];
                };
            };

            private _extensionDisplay = uiNamespace getVariable ["AWARE_MedicalSuggestionExtension", displayNull];
            if (isNull _extensionDisplay) then {
                _medicalExtLayer cutRsc ["AWARE_MedicalSuggestionExtension", "PLAIN"];
                _extensionDisplay = uiNamespace getVariable ["AWARE_MedicalSuggestionExtension", displayNull];
                if (!isNull _extensionDisplay) then {
                    uiNamespace setVariable ["AWARE_MedicalSuggestionsVisible", false];
                    [false] call AWARE_fnc_renderMedicalSuggestions;
                };
            };

            if (!isNull _display) then {
                private _isAlive = alive player;
                private _isUnconscious = false;
                if (_isAlive) then {
                    _isUnconscious = (player getVariable ["ACE_isUnconscious", false]) || { lifeState player == "INCAPACITATED" };
                };

                private _bodyGroup = _display displayCtrl 5099;
                private _deadControl = if (!isNull _bodyGroup) then {
                    _bodyGroup controlsGroupCtrl 5107
                } else {
                    _display displayCtrl 5107
                };
                if (!isNull _deadControl) then {
                    _deadControl ctrlShow (!_isAlive);
                };

                private _unconsciousControl = if (!isNull _bodyGroup) then {
                    _bodyGroup controlsGroupCtrl 5108
                } else {
                    _display displayCtrl 5108
                };
                if (!isNull _unconsciousControl) then {
                    _unconsciousControl ctrlShow (_isAlive && _isUnconscious);
                };

                if (_isAlive) then {
                    [player, _display] call AWARE_fnc_updateBodyIndicator;
                };
            };

            private _aceMedicalMenuDisplay = findDisplay 38580;
            private _aceMedicalMenuDisplayNs = uiNamespace getVariable ["ace_medical_gui_menuDisplay", displayNull];
            private _isMedicalMenuOpen = (!isNull _aceMedicalMenuDisplay) || { !isNull _aceMedicalMenuDisplayNs };
            private _isSuggestionVisible = uiNamespace getVariable ["AWARE_MedicalSuggestionsVisible", false];

            private _tabDisplay = [_aceMedicalMenuDisplayNs, _aceMedicalMenuDisplay] select (!isNull _aceMedicalMenuDisplay);

            if (!isNull _tabDisplay) then {
                private _registeredDisplay = uiNamespace getVariable ["AWARE_MedicalSuggestionTabDisplay", displayNull];
                if (_registeredDisplay isNotEqualTo _tabDisplay) then {
                    private _registeredEh = uiNamespace getVariable ["AWARE_MedicalSuggestionTabEH", -1];
                    if (!isNull _registeredDisplay && { _registeredEh >= 0 }) then {
                        _registeredDisplay displayRemoveEventHandler ["KeyDown", _registeredEh];
                    };

                    private _registeredMouseEh = uiNamespace getVariable ["AWARE_MedicalSuggestionTabMouseEH", -1];
                    if (!isNull _registeredDisplay && { _registeredMouseEh >= 0 }) then {
                        _registeredDisplay displayRemoveEventHandler ["MouseButtonDown", _registeredMouseEh];
                    };

                    private _registeredMouseUpEh = uiNamespace getVariable ["AWARE_MedicalSuggestionMouseUpEH", -1];
                    if (!isNull _registeredDisplay && { _registeredMouseUpEh >= 0 }) then {
                        _registeredDisplay displayRemoveEventHandler ["MouseButtonUp", _registeredMouseUpEh];
                    };

                    private _registeredMouseMoveEh = uiNamespace getVariable ["AWARE_MedicalSuggestionMouseMoveEH", -1];
                    if (!isNull _registeredDisplay && { _registeredMouseMoveEh >= 0 }) then {
                        _registeredDisplay displayRemoveEventHandler ["MouseMoving", _registeredMouseMoveEh];
                    };

                    private _tabEh = _tabDisplay displayAddEventHandler ["KeyDown", {
                        params ["_display", "_dikCode"];

                        if !(missionNamespace getVariable ["AWARE_medicalSuggestions_enabled", true]) exitWith { false };

                        private _tabIndex = [2, 3, 4, 5] find _dikCode;
                        if (_tabIndex > -1) then {
                            uiNamespace setVariable ["AWARE_MedicalSuggestionTab", _tabIndex];
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
                            [true] call AWARE_fnc_renderMedicalSuggestions;
                            true
                        } else {
                            private _canDrag = missionNamespace getVariable ["AWARE_medicalSuggestions_draggable", true];
                            private _headerRect = uiNamespace getVariable ["AWARE_MedicalSuggestionHeaderRect", []];
                            if (!_canDrag || { _headerRect isEqualTo [] }) exitWith { false };

                            _headerRect params ["_panelX", "_panelY", "_panelW", "_panelH"];
                            if (_mouseX >= _panelX && { _mouseX <= (_panelX + _panelW) } && { _mouseY >= _panelY } && { _mouseY <= (_panelY + _panelH) }) then {
                                uiNamespace setVariable ["AWARE_MedicalSuggestionDragging", true];
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
                        };

                        false
                    }];

                    private _mouseMoveEh = _tabDisplay displayAddEventHandler ["MouseMoving", {
                        params ["_display", "_deltaX", "_deltaY"];

                        if !(uiNamespace getVariable ["AWARE_MedicalSuggestionDragging", false]) exitWith { false };
                        if !(missionNamespace getVariable ["AWARE_medicalSuggestions_draggable", true]) exitWith {
                            uiNamespace setVariable ["AWARE_MedicalSuggestionDragging", false];
                            false
                        };

                        private _rect = uiNamespace getVariable ["AWARE_MedicalSuggestionPanelRect", [safeZoneX + 0.02, safeZoneY + (0.23 * safeZoneH), 0.46, 0.58 * safeZoneH]];
                        _rect params ["_panelX", "_panelY", "_panelW", "_panelH"];

                        private _nextX = ((_panelX + _deltaX) max safeZoneX) min (safeZoneX + safeZoneW - _panelW);
                        private _nextY = ((_panelY + _deltaY) max safeZoneY) min (safeZoneY + safeZoneH - _panelH);

                        uiNamespace setVariable ["AWARE_MedicalSuggestionPosition", [_nextX, _nextY]];
                        [true] call AWARE_fnc_renderMedicalSuggestions;
                        true
                    }];

                    uiNamespace setVariable ["AWARE_MedicalSuggestionTabDisplay", _tabDisplay];
                    uiNamespace setVariable ["AWARE_MedicalSuggestionTabEH", _tabEh];
                    uiNamespace setVariable ["AWARE_MedicalSuggestionTabMouseEH", _tabMouseEh];
                    uiNamespace setVariable ["AWARE_MedicalSuggestionMouseUpEH", _mouseUpEh];
                    uiNamespace setVariable ["AWARE_MedicalSuggestionMouseMoveEH", _mouseMoveEh];
                };
            };

            private _suggestionsEnabled = missionNamespace getVariable ["AWARE_medicalSuggestions_enabled", true];
            private _autoShowSuggestions = missionNamespace getVariable ["AWARE_medicalSuggestions_autoShow", true];
            private _shouldShowSuggestions = _suggestionsEnabled && { _autoShowSuggestions } && { _isMedicalMenuOpen };

            if (_shouldShowSuggestions != _isSuggestionVisible) then {
                uiNamespace setVariable ["AWARE_MedicalSuggestionsVisible", _shouldShowSuggestions];
                if (_shouldShowSuggestions) then {
                    uiNamespace setVariable ["AWARE_MedicalSuggestionTab", 0];
                };
                [_shouldShowSuggestions] call AWARE_fnc_renderMedicalSuggestions;
            };

            uiSleep 0.15;
        };
    };
};

uiNamespace setVariable ["AWARE_bodyIndicatorLoop", _loopHandle];
