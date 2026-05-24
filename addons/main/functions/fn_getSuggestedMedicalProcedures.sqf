/*
    Function: AWARE_fnc_getSuggestedMedicalProcedures
    Builds tabbed checklist suggestions from current patient state.
*/

params [
    "_unit",
    ["_partStates", []]
];

if (isNull _unit) exitWith {
    [
        ["BODY", ["<t color='#F0B45A'>NO PATIENT DATA</t>", "[ ] No patient selected."]],
        ["PRIORITY", ["[ ] Reopen medical menu after selecting patient."]],
        ["ITEMS", ["[ ] No item guidance available."]],
        ["RECHECK", ["[ ] Select patient and reopen medical menu."]]
    ]
};

private _isAceLoaded = isClass (configFile >> "CfgPatches" >> "ace_medical");
if (!_isAceLoaded) exitWith {
    [
        ["BODY", ["<t color='#F0B45A'>MEDICAL SYSTEM</t>", "[ ] No advanced body-state data."]],
        ["PRIORITY", ["[ ] Advanced medical data not detected.", "[ ] Follow your unit treatment SOP."]],
        ["ITEMS", ["[ ] Use unit standard medical kit."]],
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

private _fnc_findPartState = {
    params ["_sourceLabel", "_statePool"];

    private _matches = _statePool select { ((_x param [0, ""]) isEqualTo _sourceLabel) };
    if (_matches isEqualTo []) exitWith { [] };
    _matches select 0
};

private _fnc_partSummary = {
    params ["_displayName", "_sourceLabel", "_partType", "_statePool", "_isUnconscious"];

    private _state = [_sourceLabel, _statePool] call _fnc_findPartState;
    private _damageValue = _state param [1, 0];
    private _bleedRatio = _state param [2, 0];
    private _hasFracture = _state param [3, false];
    private _hasTourniquet = _state param [4, false];
    private _openWoundsCount = _state param [6, 0];

    private _requirements = [];
    private _actions = [];
    private _statusParts = [];

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

    private _severity = (_bleedRatio * 5) + (_damageValue * 3) + (_openWoundsCount * 0.35);
    if (_hasFracture) then {
        _severity = _severity + 1;
    };
    if (_hasTourniquet) then {
        _severity = _severity + 0.35;
    };

    private _isInjured = _severity > 0.05;
    private _status = "stable";
    if (_statusParts isNotEqualTo []) then {
        _status = _statusParts joinString ", ";
    };

    private _action = "Monitor and reassess.";
    if (_actions isNotEqualTo []) then {
        _action = _actions joinString " ";
    };
    private _operations = +_actions;
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
        _operations
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
    private _row = [_x select 0, _x select 1, _x select 2, _partStates, _isUnconscious] call _fnc_partSummary;
    if (_row param [11, false]) then {
        _injuryRowsForSort pushBack [(_row param [9, 0]), _row];
    };
} forEach [
    ["Head", "Head", "head"],
    ["Torso", "Torso", "torso"],
    ["Left Arm", "Left Hand", "arm"],
    ["Right Arm", "Right Hand", "arm"],
    ["Left Foot", "Left Leg", "leg"],
    ["Right Foot", "Right Leg", "leg"]
];

_injuryRowsForSort sort false;

private _injuredPartRows = [];
{
    _injuredPartRows pushBack (_x select 1);
} forEach _injuryRowsForSort;

private _marchLines = [
    _unit,
    _injuredPartRows,
    _bloodStatus,
    _bloodAction,
    _bloodRequirements,
    _isUnconscious,
    _isCardiacArrest,
    _isLosingBlood,
    _inventoryItems
] call AWARE_fnc_getPriorityMedicalWorkflow;

private _bodyLines = ["<t size='1.12' color='#9AD7FF'>BODY PART CHECKLIST</t>"];
if (_injuredPartRows isEqualTo []) then {
    _bodyLines pushBack "[ ] No wounded body parts currently need checklist actions.";
} else {
    {
        _x params ["_name", "_status", "_requirements", "_action", "_color", "_bleedRatio", "_damageValue", "_hasFracture", "_openWoundsCount", "_severity", "_hasTourniquet", "_isInjured", "_operations"];
        private _split = [_requirements] call _fnc_splitRequirements;
        _split params ["_available", "_missing"];

        _bodyLines pushBack format ["<t align='left' color='%1'>[ ] %2</t>", _color, toUpper _name];
        _bodyLines pushBack format ["  - Status: %1", _status];
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
    } forEach _injuredPartRows;
};

private _itemLines = ["<t size='1.12' color='#9AD7FF'>ITEMS AVAILABLE / REQUIRED</t>"];
private _hasItemGuidance = false;

if (_bloodRequirements isNotEqualTo []) then {
    private _split = [_bloodRequirements] call _fnc_splitRequirements;
    _split params ["_available", "_missing"];
    _itemLines pushBack format ["<t color='#F0B45A'>[ ] Blood volume:</t> %1", _bloodStatus];
    _itemLines pushBack format ["    - Procedure: %1", _bloodAction];
    if (_available isNotEqualTo []) then {
        _itemLines pushBack format ["    - Use from kit: %1", _available joinString ", "];
    };
    [_itemLines, _missing] call _fnc_addMissingLines;
    _hasItemGuidance = true;
};

if (_isLosingBlood) then {
    _itemLines pushBack "[ ] Active bleed: control bleeding before volume replacement.";
    _hasItemGuidance = true;
};
if (_painValue > 0.4) then {
    _itemLines pushBack "[ ] Pain: treat per SOP after life threats are stable.";
    _hasItemGuidance = true;
};

{
    _x params ["_name", "_status", "_requirements", "_action", "_color"];
    if (_requirements isNotEqualTo []) then {
        private _split = [_requirements] call _fnc_splitRequirements;
        _split params ["_available", "_missing"];
        _itemLines pushBack format ["<t color='%1'>[ ] %2:</t> %3", _color, _name, _status];
        if (_available isNotEqualTo []) then {
            _itemLines pushBack format ["    - Use from kit: %1", _available joinString ", "];
        };
        [_itemLines, _missing] call _fnc_addMissingLines;
        _hasItemGuidance = true;
    };
} forEach _injuredPartRows;

if (!_hasItemGuidance) then {
    _itemLines pushBack "[ ] No specific medical item requirement detected from current injuries.";
};

private _recheckLines = [
    "<t size='1.12' color='#9AD7FF'>REASSESSMENT</t>",
    "[ ] Recheck bleeding after every bandage or tourniquet.",
    "[ ] Recheck airway and breathing after torso/head treatment.",
    "[ ] Recheck pulse/BP after fluids or blood.",
    "[ ] Splints: confirm pain reduction and limb pulse.",
    "[ ] Tourniquets: review only if SOP and condition allow.",
    "[ ] Final pass: vitals, pain, wounds, fractures, evacuation."
];

[
    ["BODY", _bodyLines],
    ["PRIORITY", _marchLines],
    ["ITEMS", _itemLines],
    ["RECHECK", _recheckLines]
]
