/*
    Function: AWARE_fnc_startMedicalSuggestions
    Starts the client-side HUD loop for the medical checklist extension.
*/

if (!hasInterface) exitWith {};

private _runningHandle = uiNamespace getVariable ["AWARE_medicalSuggestionLoop", scriptNull];
if (!isNull _runningHandle && { !scriptDone _runningHandle }) exitWith {};

private _loopHandle = [] spawn {
    disableSerialization;
    waitUntil { !isNull findDisplay 46 };

    private _medicalExtLayer = ["AWARE_MedicalExtLayer"] call BIS_fnc_rscLayer;
    private _nextSuggestionUpdate = 0;

    while { true } do {
        if (isNull player) then {
            uiSleep 0.25;
        } else {
            private _extensionDisplay = uiNamespace getVariable ["AWARE_MedicalSuggestionExtension", displayNull];
            if (isNull _extensionDisplay) then {
                _medicalExtLayer cutRsc ["AWARE_MedicalSuggestionExtension", "PLAIN"];
                _extensionDisplay = uiNamespace getVariable ["AWARE_MedicalSuggestionExtension", displayNull];
                if (!isNull _extensionDisplay) then {
                    uiNamespace setVariable ["AWARE_MedicalSuggestionsVisible", false];
                    [false] call AWARE_fnc_renderMedicalSuggestions;
                };
            };

            private _medicalMenuDisplay = [] call AWARE_fnc_getMedicalMenuDisplay;
            private _isMedicalMenuOpen = !isNull _medicalMenuDisplay;
            private _isSuggestionVisible = uiNamespace getVariable ["AWARE_MedicalSuggestionsVisible", false];

            private _medicalTarget = [] call AWARE_fnc_getMedicalTarget;
            if (isNull _medicalTarget) then {
                _medicalTarget = player;
            };

            private _previousMedicalTarget = uiNamespace getVariable ["AWARE_MedicalSuggestionTarget", objNull];
            private _targetChanged = _previousMedicalTarget isNotEqualTo _medicalTarget;
            if (_targetChanged) then {
                uiNamespace setVariable ["AWARE_MedicalSuggestionTarget", _medicalTarget];
                uiNamespace setVariable ["AWARE_MedicalSuggestionTab", 0];
                uiNamespace setVariable ["AWARE_MedicalSuggestionScrollOffset", 0];
                _nextSuggestionUpdate = 0;
            };

            private _refreshInterval = [0.85, 0.15] select (_isMedicalMenuOpen || { _isSuggestionVisible });
            if (diag_tickTime >= _nextSuggestionUpdate) then {
                private _suggestionLines = [_medicalTarget] call AWARE_fnc_getSuggestedMedicalProcedures;
                uiNamespace setVariable ["AWARE_MedicalSuggestionLines", _suggestionLines];
                if (_isSuggestionVisible) then {
                    [true] call AWARE_fnc_renderMedicalSuggestions;
                };
                _nextSuggestionUpdate = diag_tickTime + _refreshInterval;
            };

            [_medicalMenuDisplay] call AWARE_fnc_registerMedicalSuggestionInput;

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

uiNamespace setVariable ["AWARE_medicalSuggestionLoop", _loopHandle];
