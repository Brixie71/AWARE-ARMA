/*
    Function: AWARE_fnc_getBodyPartStatus
    Returns [damageRatio, bleedRatio, hasFracture, hasTourniquet, usedAce, openWounds, woundDetails].
*/

params [
    "_unit",
    "_hitpointCandidates",
    ["_aceBodyPart", ""],
    ["_aceBodyPartIndex", -1]
];

if (isNull _unit) exitWith { [0, 0, false, false, false, 0, []] };

private _isAceLoaded = isClass (configFile >> "CfgPatches" >> "ace_medical");
private _canUseAce = _isAceLoaded && { _aceBodyPartIndex >= 0 } && { _aceBodyPart != "" };

if (_canUseAce) then {
    private _bodyPartDamage = _unit getVariable ["ace_medical_bodyPartDamage", [0, 0, 0, 0, 0, 0]];
    if (_bodyPartDamage isEqualType [] && { count _bodyPartDamage > _aceBodyPartIndex }) then {
        private _fractures = _unit getVariable ["ace_medical_fractures", [0, 0, 0, 0, 0, 0]];
        private _tourniquets = _unit getVariable ["ace_medical_tourniquets", [0, 0, 0, 0, 0, 0]];
        private _openWoundsContainer = _unit getVariable ["ace_medical_openWounds", createHashMap];
        private _openWounds = [];
        if (_openWoundsContainer isEqualType createHashMap) then {
            _openWounds = _openWoundsContainer getOrDefault [toLower _aceBodyPart, []];
        };

        if !(_openWounds isEqualType []) then {
            _openWounds = [];
        };

        private _fnc_woundBaseName = {
            params ["_className"];

            private _classNameLower = toLower _className;
            switch (true) do {
                case ("velocity" in _classNameLower): { "Velocity Wound" };
                case ("avulsion" in _classNameLower): { "Avulsion" };
                case ("puncture" in _classNameLower): { "Puncture Wound" };
                case ("laceration" in _classNameLower): { "Laceration" };
                case ("crush" in _classNameLower): { "Crush Injury" };
                case ("cut" in _classNameLower): { "Cut" };
                case ("abrasion" in _classNameLower): { "Abrasion" };
                case ("contusion" in _classNameLower): { "Contusion" };
                default { _className };
            };
        };

        private _fnc_decodeWound = {
            params ["_woundClassId"];

            private _classId = _woundClassId;
            if !(_classId isEqualType 0) exitWith {
                private _fallback = str _classId;
                [_fallback, "", 0, _fallback]
            };

            private _category = floor (_classId % 10);
            private _classIndex = floor (_classId / 10);
            private _suffix = ["Minor", "Medium", "Large"] param [_category, "Minor"];
            private _woundClassNames = missionNamespace getVariable ["ace_medical_damage_woundClassNames", []];
            private _className = _woundClassNames param [_classIndex, "Wound"];
            private _woundNameKey = format ["STR_ACE_medical_damage_%1_%2", _className, _suffix];
            private _woundName = localize _woundNameKey;

            if (_woundName == "" || { _woundName == _woundNameKey }) then {
                _woundName = format ["%1 %2", _suffix, [_className] call _fnc_woundBaseName];
            };

            [_woundName, _suffix, _category, _className]
        };

        private _traumaScore = (_bodyPartDamage param [_aceBodyPartIndex, 0]) max 0;
        private _bleedScore = 0;
        private _woundDamageScore = 0;
        private _woundDetails = [];

        {
            private _amount = (_x param [1, 0]) max 0;
            if (_amount > 0) then {
                private _bleeding = (_x param [2, 0]) max 0;
                private _damage = (_x param [3, 0]) max 0;
                _bleedScore = _bleedScore + _bleeding * _amount;
                _woundDamageScore = _woundDamageScore + _damage * _amount;
                private _woundInfo = [_x param [0, 0]] call _fnc_decodeWound;
                _woundInfo params ["_woundName", "_woundSize", "_woundCategory", "_woundClassName"];
                _woundDetails pushBack [
                    _woundName,
                    _woundSize,
                    _amount,
                    _bleeding,
                    _damage,
                    _woundCategory,
                    _x param [0, 0],
                    _woundClassName
                ];
            };
        } forEach _openWounds;
        private _openWoundsCount = count (_openWounds select { ((_x param [1, 0]) max 0) > 0 });

        private _hasFracture = (_fractures param [_aceBodyPartIndex, 0]) == 1;
        private _hasTourniquet = (_tourniquets param [_aceBodyPartIndex, 0]) > 0;
        private _defaultDamageThreshold = if (isPlayer _unit) then {
            missionNamespace getVariable ["ace_medical_playerDamageThreshold", 1]
        } else {
            missionNamespace getVariable ["ace_medical_AIDamageThreshold", 1]
        };

        private _damageThreshold = _unit getVariable ["ace_medical_damageThreshold", _defaultDamageThreshold];
        private _limpingDamageThreshold = missionNamespace getVariable ["ace_medical_const_limpingDamageThreshold", 0.3];
        private _fractureDamageThreshold = missionNamespace getVariable ["ace_medical_const_fractureDamageThreshold", 0.5];
        private _limbDamageThreshold = missionNamespace getVariable ["ace_medical_limbDamageThreshold", 0];
        private _useLimbDamageSetting = missionNamespace getVariable ["ace_medical_useLimbDamage", 0];
        private _useLimbDamage = [false, !isPlayer _unit, true] param [_useLimbDamageSetting, false];

        private _partThreshold = _damageThreshold max 0.01;
        switch (true) do {
            case (_aceBodyPartIndex > 3): {
                if (_limbDamageThreshold != 0 && { _useLimbDamage }) then {
                    _partThreshold = (_damageThreshold * _limbDamageThreshold) max 0.01;
                } else {
                    _partThreshold = (_limpingDamageThreshold * 4) max 0.01;
                };
            };
            case (_aceBodyPartIndex > 1): {
                if (_limbDamageThreshold != 0 && { _useLimbDamage }) then {
                    _partThreshold = (_damageThreshold * _limbDamageThreshold) max 0.01;
                } else {
                    _partThreshold = (_fractureDamageThreshold * 4) max 0.01;
                };
            };
            case (_aceBodyPartIndex == 0): {
                _partThreshold = (_damageThreshold * 1.25) max 0.01;
            };
            default {
                _partThreshold = (_damageThreshold * 1.5) max 0.01;
            };
        };

        private _damageRatio = (_traumaScore / _partThreshold) min 1;
        _damageRatio = _damageRatio max ((_woundDamageScore * 0.45) min 1);
        if (_hasFracture) then {
            _damageRatio = _damageRatio + 0.2;
        };
        if (_hasTourniquet) then {
            _damageRatio = _damageRatio + 0.05;
        };

        private _bleedRatio = (_bleedScore / 0.5) min 1;
        _damageRatio = (_damageRatio max 0) min 1;

        [_damageRatio, _bleedRatio, _hasFracture, _hasTourniquet, true, _openWoundsCount, _woundDetails]
    } else {
        private _fallbackDamage = [_unit, _hitpointCandidates] call AWARE_fnc_getBodyPartDamage;
        [_fallbackDamage, 0, false, false, false, 0, []]
    };
} else {
    private _fallbackDamage = [_unit, _hitpointCandidates] call AWARE_fnc_getBodyPartDamage;
    [_fallbackDamage, 0, false, false, false, 0, []]
};
