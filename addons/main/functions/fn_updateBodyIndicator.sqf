/*
    Function: AWARE_fnc_updateBodyIndicator
    Updates body part status controls from unit hitpoint damage.
*/

params ["_unit", "_display"];

if (isNull _unit || { isNull _display }) exitWith {};

disableSerialization;

private _detailsByIdc = createHashMap;
private _partStates = [];
private _bodyGroup = _display displayCtrl 5099;

private _bodyParts = [
    ["Head", 5101, ["HitHead", "HitFace", "HitNeck"], "head", 0],
    ["Torso", 5102, ["HitBody", "HitChest", "HitAbdomen", "HitDiaphragm", "HitPelvis"], "body", 1],
    ["Left Hand", 5103, ["HitLeftArm", "HitLeftHand", "HitArms", "HitHands"], "leftarm", 2],
    ["Right Hand", 5104, ["HitRightArm", "HitRightHand", "HitArms", "HitHands"], "rightarm", 3],
    ["Left Leg", 5105, ["HitLeftLeg", "HitLeftFoot", "HitLegs"], "leftleg", 4],
    ["Right Leg", 5106, ["HitRightLeg", "HitRightFoot", "HitLegs"], "rightleg", 5]
];

private _blockX = if (!isNull _bodyGroup) then { 0 } else { safeZoneX + safeZoneW - 0.355 };
private _blockW = [0.325, 0.31] select (!isNull _bodyGroup);
private _currentY = if (!isNull _bodyGroup) then { 0 } else { safeZoneY + (0.32 * safeZoneH) };
private _lineHeight = 0.021 * safeZoneH;
private _blockPadding = 0.005 * safeZoneH;
private _blockGap = 0.006 * safeZoneH;

{
    _x params ["_label", "_idc", "_hitpoints", "_aceBodyPart", "_aceIndex"];

    private _status = [_unit, _hitpoints, _aceBodyPart, _aceIndex] call AWARE_fnc_getBodyPartStatus;
    _status params ["_damageValue", "_bleedRatio", "_hasFracture", "_hasTourniquet", "_usedAce", "_openWoundsCount", "_woundDetails"];
    private _isBleeding = _bleedRatio > 0.01;
    private _control = if (!isNull _bodyGroup) then {
        _bodyGroup controlsGroupCtrl _idc
    } else {
        _display displayCtrl _idc
    };
    private _color = [0.45, 0.45, 0.45, 0.8];
    private _traumaText = "None";
    switch (true) do {
        case (_damageValue > 0.7): {
            _color = [0.78, 0.11, 0.11, 0.95];
            _traumaText = "Severe";
        };
        case (_damageValue > 0.35): {
            _color = [0.9, 0.34, 0.12, 0.9];
            _traumaText = "Moderate";
        };
        case (_damageValue > 0.01): {
            _color = [0.86, 0.61, 0.12, 0.85];
            _traumaText = "Minor";
        };
        default {
            _traumaText = "None";
        };
    };

    private _bleedText = "None";
    if (_usedAce) then {
        switch (true) do {
            case (_bleedRatio > 0.7): {
                _bleedText = "Critical";
            };
            case (_bleedRatio > 0.35): {
                _bleedText = "Heavy";
            };
            case (_bleedRatio > 0.01): {
                _bleedText = "Light";
            };
            default {
                _bleedText = "None";
            };
        };

        if (_isBleeding) then {
            if (_bleedRatio > 0.7) then {
                _color = [0.85, 0.2, 0.2, 0.9];
            } else {
                if (_bleedRatio > 0.35) then {
                    _color = [0.9, 0.5, 0.1, 0.9];
                } else {
                    _color = [0.88, 0.74, 0.18, 0.9];
                };
            };
        };
    };

    private _activeIndicators = [];
    if (_usedAce) then {
        private _painValue = (((_unit getVariable ["ace_medical_pain", 0]) - (_unit getVariable ["ace_medical_painSuppress", 0])) max 0) min 1;
        private _isInPain = _painValue > 0.15;
        private _isLosingBlood = (_unit getVariable ["ace_medical_woundBleeding", 0]) > 0.01;
        private _isLowBlood = (_unit getVariable ["ace_medical_bloodVolume", 6]) < 5.1;

        if (_isBleeding) then {
            _activeIndicators pushBack "Bleeding";
        };
        if (_isInPain && { _damageValue > 0.01 || _isBleeding || _hasFracture }) then {
            _activeIndicators pushBack "In Pain";
        };
        if (_isLosingBlood && { _isBleeding }) then {
            _activeIndicators pushBack "Losing Blood";
        };
        if (_isLowBlood && { _isBleeding || _damageValue > 0.01 }) then {
            _activeIndicators pushBack "Low Blood Volume";
        };
        if (_hasFracture) then {
            _activeIndicators pushBack "Fractured";
        };
        if (_hasTourniquet) then {
            _activeIndicators pushBack "Tourniquet Applied";
        };
        if (_openWoundsCount > 0) then {
            _activeIndicators pushBack format ["Open Wounds x%1", _openWoundsCount];
        };
        if (_traumaText != "None") then {
            _activeIndicators pushBack format ["%1 Trauma", _traumaText];
        };
    } else {
        if (_traumaText != "None") then {
            _activeIndicators pushBack format ["%1 Injury", _traumaText];
        };
    };

    if (_activeIndicators isEqualTo []) then {
        _activeIndicators pushBack "Normal";
    };

    private _displayLines = [_label];
    {
        _displayLines pushBack format ["- %1", _x];
    } forEach _activeIndicators;

    private _detailRows = [_label];
    {
        _detailRows pushBack _x;
    } forEach _activeIndicators;

    _detailsByIdc set [str _idc, _detailRows];
    _partStates pushBack [_label, _damageValue, _bleedRatio, _hasFracture, _hasTourniquet, _usedAce, _openWoundsCount, _woundDetails];

    if !(isNull _control) then {
        private _blockHeight = ((count _displayLines) * _lineHeight) + (2 * _blockPadding);
        _control ctrlSetPosition [_blockX, _currentY, _blockW, _blockHeight];
        _control ctrlCommit 0;
        _control ctrlSetBackgroundColor _color;
        _control ctrlSetText (_displayLines joinString "\n");
        _currentY = _currentY + _blockHeight + _blockGap;
    };
} forEach _bodyParts;

private _suggestionLines = [_unit, _partStates] call AWARE_fnc_getSuggestedMedicalProcedures;
uiNamespace setVariable ["AWARE_MedicalSuggestionLines", _suggestionLines];
uiNamespace setVariable ["AWARE_MedicalSuggestionPartStates", _partStates];

private _badgeX = _blockX;
private _badgeW = _blockW;
private _badgeH = 0.034;
private _badgeGap = 0.006 * safeZoneH;
private _statusY = _currentY + _badgeGap;

private _unconsciousControl = if (!isNull _bodyGroup) then {
    _bodyGroup controlsGroupCtrl 5108
} else {
    _display displayCtrl 5108
};
if (!isNull _unconsciousControl) then {
    _unconsciousControl ctrlSetPosition [_badgeX, _statusY, _badgeW, _badgeH];
    _unconsciousControl ctrlCommit 0;
};

private _deadControl = if (!isNull _bodyGroup) then {
    _bodyGroup controlsGroupCtrl 5107
} else {
    _display displayCtrl 5107
};
if (!isNull _deadControl) then {
    _deadControl ctrlSetPosition [_badgeX, _statusY + _badgeH + 0.006, _badgeW, _badgeH];
    _deadControl ctrlCommit 0;
};

uiNamespace setVariable ["AWARE_BodyIndicatorDetails", _detailsByIdc];

if (uiNamespace getVariable ["AWARE_MedicalSuggestionsVisible", false]) then {
    [true] call AWARE_fnc_renderMedicalSuggestions;
};
