/*
    Function: AWARE_fnc_getSuggestedMedicalProcedures
    Builds tabbed checklist suggestions from current patient state.
*/

params [
    "_unit",
    ["_partStates", []]
];

if (isNull _unit) exitWith {
    uiNamespace setVariable ["AWARE_MedicalSuggestionFocusedBodyPartIndex", -1];
    [
        ["ITEMS", ["[ ] No item guidance available."]],
        ["BODY", ["<t color='#F0B45A'>NO PATIENT DATA</t>", "[ ] No patient selected."]],
        ["PRIORITY", ["[ ] Reopen medical menu after selecting patient."]],
        ["RECHECK", ["[ ] Select patient and reopen medical menu."]]
    ]
};

private _isAceLoaded = isClass (configFile >> "CfgPatches" >> "ace_medical");
if (!_isAceLoaded) exitWith {
    uiNamespace setVariable ["AWARE_MedicalSuggestionFocusedBodyPartIndex", -1];
    [
        ["ITEMS", ["[ ] Use unit standard medical kit."]],
        ["BODY", ["<t color='#F0B45A'>MEDICAL SYSTEM</t>", "[ ] No advanced body-state data."]],
        ["PRIORITY", ["[ ] Advanced medical data not detected.", "[ ] Follow your unit treatment SOP."]],
        ["RECHECK", ["[ ] Reassess manually."]]
    ]
};

private _medic = missionNamespace getVariable ["ACE_player", player];
if (isNull _medic) then {
    _medic = player;
};

private _inventoryItems = (items _medic) + (assignedItems _medic);
private _fnc_hasAnyItem = {
    params ["_classCandidates"];

    private _hasItem = false;
    {
        if (_x in _inventoryItems) exitWith {
            _hasItem = true;
        };
    } forEach _classCandidates;

    _hasItem
};

private _fnc_addRequirement = {
    params ["_requirements", "_displayName", "_classCandidates"];

    private _existingIndex = _requirements findIf { ((_x param [0, ""]) isEqualTo _displayName) };
    if (_existingIndex < 0) then {
        _requirements pushBack [_displayName, _classCandidates];
    };
};

private _fnc_splitRequirements = {
    params ["_requirements"];

    private _available = [];
    private _missing = [];

    {
        _x params ["_displayName", "_classCandidates"];
        if ([_classCandidates] call _fnc_hasAnyItem) then {
            _available pushBack _displayName;
        } else {
            _missing pushBack _displayName;
        };
    } forEach _requirements;

    [_available, _missing]
};

private _fnc_addMissingLines = {
    params ["_lines", "_missing"];

    {
        _lines pushBack format ["      [ ] <t color='#F06A5A'>Required: ""%1""</t>", _x];
    } forEach _missing;
};

private _fnc_addItemGuidance = {
    params ["_availableItems", "_missingItems", "_displayName", "_classCandidates"];

    if ([_classCandidates] call _fnc_hasAnyItem) then {
        if !(_displayName in _availableItems) then {
            _availableItems pushBack _displayName;
        };
    } else {
        if !(_displayName in _missingItems) then {
            _missingItems pushBack _displayName;
        };
    };
};

private _fnc_findPartState = {
    params ["_sourceLabel", "_statePool"];

    private _matches = _statePool select { ((_x param [0, ""]) isEqualTo _sourceLabel) };
    if (_matches isEqualTo []) exitWith { [] };
    _matches select 0
};

private _fnc_partSummary = {
    params ["_displayName", "_sourceLabel", "_partType", "_statePool", "_isUnconscious", ["_aceBodyPartIndex", -1]];

    private _state = [_sourceLabel, _statePool] call _fnc_findPartState;
    private _damageValue = _state param [1, 0];
    private _bleedRatio = _state param [2, 0];
    private _hasFracture = _state param [3, false];
    private _hasTourniquet = _state param [4, false];
    private _openWoundsCount = _state param [6, 0];
    private _woundDetails = _state param [7, []];

    private _requirements = [];
    private _actions = [];
    private _woundOperations = [];
    private _statusParts = [];
    private _woundAmountTotal = 0;
    private _largeWounds = 0;
    private _mediumWounds = 0;
    private _bleedingWounds = 0;
    private _penetratingWounds = 0;

    if (_bleedRatio > 0.35) then {
        _statusParts pushBack "heavy bleeding";
        if (_partType in ["arm", "leg"]) then {
            if (!_hasTourniquet) then {
                [_requirements, "Tourniquet", ["ACE_tourniquet"]] call _fnc_addRequirement;
                _actions pushBack "Apply tourniquet high and tight if bleeding is life-threatening.";
            } else {
                _actions pushBack "Confirm tourniquet is still controlling bleeding.";
            };
        };
        [_requirements, "Packing Bandage", ["ACE_packingBandage", "ACE_fieldDressing", "ACE_elasticBandage", "ACE_quikclot"]] call _fnc_addRequirement;
        [_requirements, "Elastic Bandage", ["ACE_elasticBandage", "ACE_packingBandage", "ACE_fieldDressing", "ACE_quikclot"]] call _fnc_addRequirement;
        _actions pushBack "Pack wound and bandage until bleeding is controlled.";
    } else {
        if (_bleedRatio > 0.01 || { _openWoundsCount > 0 }) then {
            _statusParts pushBack "bleeding";
            [_requirements, "Packing Bandage", ["ACE_packingBandage", "ACE_fieldDressing", "ACE_elasticBandage", "ACE_quikclot"]] call _fnc_addRequirement;
            [_requirements, "Elastic Bandage", ["ACE_elasticBandage", "ACE_packingBandage", "ACE_fieldDressing", "ACE_quikclot"]] call _fnc_addRequirement;
            _actions pushBack "Bandage and recheck until bleeding stops.";
        };
    };

    if (_openWoundsCount > 0) then {
        _statusParts pushBack format ["open wound/gunshot x%1", _openWoundsCount];
    };

    {
        _x params ["_woundName", "_woundSize", "_amount", "_bleeding", "_damage", "_woundCategory"];

        private _operationPrefix = _woundName;
        private _woundNameLower = toLower _woundName;
        _woundAmountTotal = _woundAmountTotal + _amount;
        if (_woundCategory >= 2) then {
            _largeWounds = _largeWounds + 1;
        } else {
            if (_woundCategory == 1) then {
                _mediumWounds = _mediumWounds + 1;
            };
        };
        if (_bleeding > 0.01) then {
            _bleedingWounds = _bleedingWounds + 1;
        };
        if (("velocity" in _woundNameLower) || { "puncture" in _woundNameLower } || { "avulsion" in _woundNameLower }) then {
            _penetratingWounds = _penetratingWounds + 1;
        };

        switch (true) do {
            case (_bleeding > 0.35 || { _woundCategory >= 2 }): {
                _woundOperations pushBack format ["%1: pack wound with Packing Bandage or QuikClot.", _operationPrefix];
                _woundOperations pushBack format ["%1: secure with Elastic Bandage and recheck bleeding.", _operationPrefix];
            };
            case (_bleeding > 0.01): {
                _woundOperations pushBack format ["%1: bandage and recheck until bleeding stops.", _operationPrefix];
            };
            default {
                _woundOperations pushBack format ["%1: monitor and reassess.", _operationPrefix];
            };
        };

        if (_partType isEqualTo "torso" && { ("velocity" in _woundNameLower) || { "puncture" in _woundNameLower } }) then {
            _woundOperations pushBack format ["%1: apply chest seal if penetrating torso wound is present.", _operationPrefix];
        };
    } forEach _woundDetails;

    if (_damageValue > 0.7) then {
        _statusParts pushBack "severe trauma";
    } else {
        if (_damageValue > 0.35) then {
            _statusParts pushBack "moderate trauma";
        } else {
            if (_damageValue > 0.01) then {
                _statusParts pushBack "minor trauma";
            };
        };
    };

    if (_partType isEqualTo "torso" && { _openWoundsCount > 0 || { _bleedRatio > 0.01 } || { _damageValue > 0.35 } }) then {
        [_requirements, "Chest Seal", ["kat_chestSeal"]] call _fnc_addRequirement;
        _actions pushBack "Seal penetrating chest wounds and reassess breathing.";
        if (_damageValue > 0.35) then {
            [_requirements, "Needle Decompression Kit", ["kat_ncdKit", "kat_aatKit"]] call _fnc_addRequirement;
            _actions pushBack "If breathing worsens, assess for decompression per SOP.";
        };
    };

    if (_partType isEqualTo "head" && { _isUnconscious }) then {
        [_requirements, "Airway Adjunct", ["kat_guedel", "kat_larynx"]] call _fnc_addRequirement;
        _actions pushBack "Open airway and monitor respirations.";
    };

    if (_hasFracture) then {
        _statusParts pushBack "fracture";
        [_requirements, "Splint", ["ACE_splint"]] call _fnc_addRequirement;
        _actions pushBack "Splint after bleeding control.";
    };

    if (_hasTourniquet) then {
        _statusParts pushBack "tourniquet applied";
    };

    private _isActionable = (_bleedRatio > 0.01) || { _openWoundsCount > 0 } || { _hasFracture } || { _hasTourniquet } || { _partType isEqualTo "head" && { _isUnconscious } };
    private _severity = (_bleedRatio * 30) + (_damageValue * 8) + (_openWoundsCount * 3) + (_woundAmountTotal * 0.15) + (_largeWounds * 6) + (_mediumWounds * 3) + (_bleedingWounds * 4);

    if (_bleedRatio > 0.35) then {
        _severity = _severity + 100;
    } else {
        if (_bleedRatio > 0.01) then {
            _severity = _severity + 60;
        };
    };
    if (_partType isEqualTo "torso" && { _penetratingWounds > 0 || { _bleedRatio > 0.01 } }) then {
        _severity = _severity + 35;
    };
    if (_partType isEqualTo "head" && { _isUnconscious || { _damageValue > 0.35 } || { _openWoundsCount > 0 } }) then {
        _severity = _severity + 30;
    };
    if (_hasFracture) then {
        _severity = _severity + 12;
    };
    if (_hasTourniquet) then {
        _severity = _severity + 3;
    };

    private _isInjured = _isActionable && { _severity > 0.05 };
    private _status = "stable";
    if (_statusParts isNotEqualTo []) then {
        _status = _statusParts joinString ", ";
    };

    private _action = "Monitor and reassess.";
    if (_actions isNotEqualTo []) then {
        _action = _actions joinString " ";
    };
    private _operations = +_woundOperations;
    {
        if !(_x in _operations) then {
            _operations pushBack _x;
        };
    } forEach _actions;
    if (_operations isEqualTo []) then {
        _operations pushBack "Monitor and reassess.";
    };

    private _priorityColor = "#9BE28F";
    if (_bleedRatio > 0.35 || { _damageValue > 0.7 }) then {
        _priorityColor = "#F06A5A";
    } else {
        if (_bleedRatio > 0.01 || { _damageValue > 0.35 } || { _hasFracture }) then {
            _priorityColor = "#F0B45A";
        };
    };

    [
        _displayName,
        _status,
        _requirements,
        _action,
        _priorityColor,
        _bleedRatio,
        _damageValue,
        _hasFracture,
        _openWoundsCount,
        _severity,
        _hasTourniquet,
        _isInjured,
        _operations,
        _woundDetails,
        _aceBodyPartIndex,
        _partType
    ]
};

private _isUnconscious = (_unit getVariable ["ACE_isUnconscious", false]) || { lifeState _unit == "INCAPACITATED" };
private _isCardiacArrest = _unit getVariable ["ace_medical_inCardiacArrest", false];
private _isLosingBlood = (_unit getVariable ["ace_medical_woundBleeding", 0]) > 0.01;
private _bloodVolume = _unit getVariable ["ace_medical_bloodVolume", 6];
private _painValue = (((_unit getVariable ["ace_medical_pain", 0]) - (_unit getVariable ["ace_medical_painSuppress", 0])) max 0) min 1;

private _bloodRequirements = [];
private _bloodStatus = "Normal";
private _bloodAction = "Reassess after each treatment.";
switch (true) do {
    case (_bloodVolume < 3.6): {
        _bloodStatus = "Critical";
        [_bloodRequirements, "IV Fluid / Blood Product", ["ACE_bloodIV", "ACE_bloodIV_500", "ACE_bloodIV_250", "ACE_plasmaIV", "ACE_plasmaIV_500", "ACE_plasmaIV_250", "ACE_salineIV", "ACE_salineIV_500", "ACE_salineIV_250", "kat_bloodIV_O", "kat_bloodIV_A", "kat_bloodIV_B", "kat_bloodIV_AB"]] call _fnc_addRequirement;
        _bloodAction = "Replace volume aggressively after active bleeding is controlled.";
    };
    case (_bloodVolume < 4.2): {
        _bloodStatus = "Severe loss";
        [_bloodRequirements, "IV Fluid / Blood Product", ["ACE_bloodIV", "ACE_bloodIV_500", "ACE_bloodIV_250", "ACE_plasmaIV", "ACE_plasmaIV_500", "ACE_plasmaIV_250", "ACE_salineIV", "ACE_salineIV_500", "ACE_salineIV_250", "kat_bloodIV_O", "kat_bloodIV_A", "kat_bloodIV_B", "kat_bloodIV_AB"]] call _fnc_addRequirement;
        _bloodAction = "Prioritize blood products and monitor pulse/BP.";
    };
    case (_bloodVolume < 5.1): {
        _bloodStatus = "Low";
        [_bloodRequirements, "IV Fluid / Blood Product", ["ACE_bloodIV", "ACE_bloodIV_500", "ACE_bloodIV_250", "ACE_plasmaIV", "ACE_plasmaIV_500", "ACE_plasmaIV_250", "ACE_salineIV", "ACE_salineIV_500", "ACE_salineIV_250", "kat_bloodIV_O", "kat_bloodIV_A", "kat_bloodIV_B", "kat_bloodIV_AB"]] call _fnc_addRequirement;
        _bloodAction = "Start fluids after active bleeding is controlled.";
    };
};

private _injuryRowsForSort = [];
{
    private _row = [_x select 0, _x select 1, _x select 2, _partStates, _isUnconscious, _x select 3] call _fnc_partSummary;
    if (_row param [11, false]) then {
        _injuryRowsForSort pushBack [(_row param [9, 0]), _row];
    };
} forEach [
    ["Head", "Head", "head", 0],
    ["Torso", "Torso", "torso", 1],
    ["Left Arm", "Left Hand", "arm", 2],
    ["Right Arm", "Right Hand", "arm", 3],
    ["Left Leg", "Left Leg", "leg", 4],
    ["Right Leg", "Right Leg", "leg", 5]
];

_injuryRowsForSort sort false;

private _injuredPartRows = [];
{
    _injuredPartRows pushBack (_x select 1);
} forEach _injuryRowsForSort;

private _focusedPartRows = [];
if (_injuredPartRows isNotEqualTo []) then {
    _focusedPartRows pushBack (_injuredPartRows select 0);
};

private _focusedBodyPartIndex = -1;
if (_focusedPartRows isNotEqualTo []) then {
    _focusedBodyPartIndex = (_focusedPartRows select 0) param [14, -1];
};
uiNamespace setVariable ["AWARE_MedicalSuggestionFocusedBodyPartIndex", _focusedBodyPartIndex];

private _marchLines = [
    _unit,
    _focusedPartRows,
    _bloodStatus,
    _bloodAction,
    _bloodRequirements,
    _isUnconscious,
    _isCardiacArrest,
    _isLosingBlood,
    _inventoryItems
] call AWARE_fnc_getPriorityMedicalWorkflow;

private _bodyLines = [format ["<t size='1.12' color='#9AD7FF'>%1</t>", localize "STR_AWARE_BODY_PART_CHECKLIST"]];
if (_focusedPartRows isEqualTo []) then {
    _bodyLines pushBack "[ ] No wounded body parts currently need checklist actions.";
} else {
    private _selectedBodyPartIndex = missionNamespace getVariable ["ace_medical_gui_selectedBodyPart", -1];
    private _selectedBodyPartNames = ["Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"];
    {
        _x params ["_name", "_status", "_requirements", "_action", "_color", "_bleedRatio", "_damageValue", "_hasFracture", "_openWoundsCount", "_severity", "_hasTourniquet", "_isInjured", "_operations", "_woundDetails"];
        private _split = [_requirements] call _fnc_splitRequirements;
        _split params ["_available", "_missing"];

        _bodyLines pushBack format ["<t color='%1'>★ %2: %3</t>", _color, localize "STR_AWARE_ACTIVE_PRIORITY", toUpper _name];
        _bodyLines pushBack format ["<t color='%1'>  ► Recommended: Treat this body part first ◄</t>", _color];
        _bodyLines pushBack format ["  - %1", localize "STR_AWARE_ADVANCE_HINT"];
        _bodyLines pushBack format ["<t align='left' color='%1'>[ ] %2</t>", _color, toUpper _name];
        _bodyLines pushBack format ["  - Status: %1", _status];
        if (_woundDetails isNotEqualTo []) then {
            _bodyLines pushBack "  - Wounds:";
            {
                _x params ["_woundName", "_woundSize", "_amount"];
                private _amountText = if (_amount >= 1) then {
                    format ["%1x", ceil _amount]
                } else {
                    "Partial"
                };
                _bodyLines pushBack format ["      - %1 %2", _amountText, _woundName];
            } forEach _woundDetails;
        };
        _bodyLines pushBack "  - Medical operations:";
        {
            _bodyLines pushBack format ["      [ ] %1", _x];
        } forEach _operations;
        if (_available isNotEqualTo []) then {
            _bodyLines pushBack "  - Use from kit:";
            {
                _bodyLines pushBack format ["      [ ] %1", _x];
            } forEach _available;
        };
        [_bodyLines, _missing] call _fnc_addMissingLines;
    } forEach _focusedPartRows;
};

private _itemLines = [format ["<t size='1.12' color='#9AD7FF'>%1</t>", localize "STR_AWARE_ITEMS_AVAILABLE_REQUIRED"]];
private _hasItemGuidance = false;
private _ivRequired = _bloodRequirements isNotEqualTo [];
private _ivClassCandidates = ["ACE_bloodIV", "ACE_bloodIV_500", "ACE_bloodIV_250", "ACE_plasmaIV", "ACE_plasmaIV_500", "ACE_plasmaIV_250", "ACE_salineIV", "ACE_salineIV_500", "ACE_salineIV_250", "kat_bloodIV_O", "kat_bloodIV_A", "kat_bloodIV_B", "kat_bloodIV_AB"];
private _painClassCandidates = ["ACE_morphine", "kat_Painkiller", "kat_nalbuphine"];

/* Get priority body part name for item highlighting */
private _priorityBodyPartName = "";
if (_focusedPartRows isNotEqualTo []) then {
    _priorityBodyPartName = _focusedPartRows select 0 param [0, ""];
};

{
    private _name = _x param [0, ""];
    private _requirements = _x param [2, []];
    private _color = _x param [4, "#9BE28F"];
    private _rowIndex = _forEachIndex;
    private _availableItems = [];
    private _missingItems = [];
    private _isPriority = (_name isEqualTo _priorityBodyPartName);

    {
        _x params ["_displayName", "_classCandidates"];
        [_availableItems, _missingItems, _displayName, _classCandidates] call _fnc_addItemGuidance;
    } forEach _requirements;

    if (_painValue > 0.4 && { _rowIndex == 0 }) then {
        [_availableItems, _missingItems, "Painkillers", _painClassCandidates] call _fnc_addItemGuidance;
    };

    if (_ivRequired && { _rowIndex == 0 }) then {
        [_availableItems, _missingItems, "IV Blood / Fluid", _ivClassCandidates] call _fnc_addItemGuidance;
    };

    if (_availableItems isNotEqualTo [] || { _missingItems isNotEqualTo [] }) then {
        private _priorityMarker = ["", "★ "] select (_isPriority);
        _itemLines pushBack format ["<t color='%1'>%2%3</t>", _color, _priorityMarker, toUpper _name];
        if (_isPriority) then {
            _itemLines pushBack "  ► Use these items now ◄";
        } else {
            _itemLines pushBack "  (Use after priority treatment)";
        };
        _itemLines pushBack "      [ ] Available:";
        {
            _itemLines pushBack format ["            [ ] %1", _x];
        } forEach _availableItems;

        if (_missingItems isNotEqualTo []) then {
            _itemLines pushBack format ["      - <t color='#F06A5A'>Required Items: %1</t>", _missingItems joinString ", "];
        };

        _hasItemGuidance = true;
    };
} forEach _injuredPartRows;

if (!_hasItemGuidance && { _ivRequired }) then {
    _itemLines pushBack "<t color='#F0B45A'>CIRCULATION</t>";
    if ([_ivClassCandidates] call _fnc_hasAnyItem) then {
        _itemLines pushBack "      [ ] IV Blood / Fluid";
    } else {
        _itemLines pushBack "      - <t color='#F06A5A'>Required Items: IV Blood / Fluid</t>";
    };
    _hasItemGuidance = true;
};

if (!_hasItemGuidance) then {
    _itemLines pushBack "[ ] No body-part item requirement detected from current injuries.";
};

private _recheckLines = [
    format ["<t size='1.12' color='#9AD7FF'>%1</t>", localize "STR_AWARE_REASSESSMENT"],
    "[ ] Recheck bleeding after every bandage or tourniquet.",
    "[ ] Recheck airway and breathing after torso/head treatment.",
    "[ ] Recheck pulse/BP after fluids or blood.",
    "[ ] Splints: confirm pain reduction and limb pulse.",
    "[ ] Tourniquets: review only if SOP and condition allow.",
    "[ ] Final pass: vitals, pain, wounds, fractures, evacuation."
];

[
    ["ITEMS", _itemLines],
    ["BODY", _bodyLines],
    ["PRIORITY", _marchLines],
    ["RECHECK", _recheckLines]
]
