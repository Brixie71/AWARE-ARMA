/*
    Function: AWARE_fnc_getSuggestedMedicalProcedures
    Builds tabbed checklist suggestions from current patient state.
*/

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {
    [
        ["FIRST AID", ["[ ] No patient selected.", "[ ] Select a patient and reopen the medical menu."]],
        ["VITALS", ["[ ] No vitals available."]]
    ]
};

private _medic = missionNamespace getVariable ["ACE_player", player];
if (isNull _medic) then {
    _medic = player;
};

private _inventoryItems = [_medic] call AWARE_fnc_getMedicInventoryItems;
private _isAceLoaded = isClass (configFile >> "CfgPatches" >> "ace_medical");

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

private _fnc_appendRequirements = {
    params ["_requirements", "_items"];

    {
        _x params ["_displayName", "_classCandidates"];
        [_requirements, _displayName, _classCandidates] call _fnc_addRequirement;
    } forEach _items;
};

private _fnc_splitRequirements = {
    params ["_requirements", ["_appliedTreatmentKeys", []]];

    private _available = [];
    private _missing = [];

    {
        _x params ["_displayName", "_classCandidates"];
        private _isApplied = [_displayName, _appliedTreatmentKeys] call _fnc_isRequirementApplied;
        private _requiresInventory = _classCandidates isNotEqualTo [];
        private _hasItem = !_requiresInventory || { [_classCandidates] call _fnc_hasAnyItem };
        private _requirementName = [_displayName, _appliedTreatmentKeys, _requiresInventory && { !_hasItem }] call _fnc_formatRequirementName;
        if (_isApplied || { _hasItem }) then {
            _available pushBack _requirementName;
        } else {
            _missing pushBack _requirementName;
        };
    } forEach _requirements;

    [_available, _missing]
};

private _fnc_isRequirementApplied = {
    params ["_displayName", ["_appliedTreatmentKeys", []]];

    if !(_appliedTreatmentKeys isEqualType []) exitWith {
        false
    };

    if (_displayName in _appliedTreatmentKeys) exitWith {
        true
    };

    private _className = switch (_displayName) do {
        case "Field Dressing": { "ACE_fieldDressing" };
        case "Packing Bandage": { "ACE_packingBandage" };
        case "Elastic Bandage": { "ACE_elasticBandage" };
        case "QuikClot": { "ACE_quikclot" };
        case "Bandage": { "AWARE_BandageApplied" };
        case "Tourniquet": { "ACE_tourniquet" };
        case "Splint": { "ACE_splint" };
        case "Chest Seal": { "kat_chestSeal" };
        case "Painkillers": { "ACE_painkillers" };
        case "Morphine": { "ACE_morphine" };
        case "Tourniquet Removal": { "AWARE_TourniquetRemoved" };
        case "Blood Transfusion": { "AWARE_IVApplied" };
        case "IV Fluid / Blood Product": { "AWARE_IVApplied" };
        default { "" };
    };

    if (_className isNotEqualTo "" && { _className in _appliedTreatmentKeys }) exitWith {
        true
    };

    ("AWARE_BandageApplied" in _appliedTreatmentKeys) && {
        _displayName in ["Field Dressing", "Packing Bandage", "Elastic Bandage", "QuikClot", "Bandage"]
    }
};

private _fnc_formatRequirementName = {
    params ["_displayName", ["_appliedTreatmentKeys", []], ["_isMissing", false]];

    if ([_displayName, _appliedTreatmentKeys] call _fnc_isRequirementApplied) then {
        format ["%1 <t color='#9BE28F'>(Applied)</t>", _displayName]
    } else {
        if (_isMissing) then {
            format ["%1 <t color='#F06A5A'>(Required)</t>", _displayName]
        } else {
            _displayName
        }
    }
};

private _fnc_hasAllRequirementsApplied = {
    params ["_requirements", ["_appliedTreatmentKeys", []]];

    (_requirements findIf {
        _x params ["_displayName"];
        !([_displayName, _appliedTreatmentKeys] call _fnc_isRequirementApplied)
    }) < 0
};

private _fnc_hasAnyRequirementApplied = {
    params ["_requirements", ["_appliedTreatmentKeys", []]];

    (_requirements findIf {
        _x params ["_displayName"];
        [_displayName, _appliedTreatmentKeys] call _fnc_isRequirementApplied
    }) >= 0
};

private _fnc_mergeTreatmentKeys = {
    params ["_baseKeys", "_extraKeys"];

    private _merged = +_baseKeys;
    {
        [_merged, _x] call _fnc_addUniqueString;
    } forEach _extraKeys;

    _merged
};

private _fnc_addPartAppliedKeys = {
    params ["_keys", "_bodyPartKey", "_requirements"];

    {
        [_keys, _x] call _fnc_addUniqueString;
        [_keys, format ["%1:%2", _x, _bodyPartKey]] call _fnc_addUniqueString;
    } forEach _requirements;

    _keys
};

private _fnc_getArrayValue = {
    params ["_values", "_index", "_defaultValue"];

    if (_values isEqualType [] && { (count _values) > _index }) exitWith {
        _values select _index
    };

    _defaultValue
};

private _fnc_getBodyPartWounds = {
    params ["_target", "_bodyPartKey", "_storeVariable", "_fallbackFunction"];

    private _wounds = [];

    if !(isNil _fallbackFunction) then {
        private _fnc = missionNamespace getVariable [_fallbackFunction, {}];
        _wounds = [_target, _bodyPartKey] call _fnc;
    } else {
        private _woundStore = _target getVariable [_storeVariable, createHashMap];
        if (_woundStore isEqualType createHashMap) then {
            _wounds = _woundStore getOrDefault [_bodyPartKey, []];
        };
    };

    if !(_wounds isEqualType []) then {
        _wounds = [];
    };

    _wounds
};

private _fnc_hasWounds = {
    params ["_wounds"];

    (_wounds isEqualType []) && { _wounds isNotEqualTo [] }
};

private _fnc_hasBleedingWounds = {
    params ["_wounds"];

    (_wounds findIf {
        _x isEqualType [] && { (count _x) > 2 } && { (_x select 2) isEqualType 0 } && { (_x select 2) > 0 }
    }) >= 0
};

private _fnc_getMaxWoundDamage = {
    params ["_wounds"];

    private _maxDamage = 0;
    {
        if (_x isEqualType [] && { (count _x) > 3 } && { (_x select 3) isEqualType 0 }) then {
            _maxDamage = _maxDamage max (_x select 3);
        };
    } forEach _wounds;

    _maxDamage
};

private _fnc_addUseMissingLines = {
    params ["_lines", "_requirements", ["_indent", "    "], ["_appliedTreatments", []], ["_appliedTreatmentKeys", []]];

    private _split = [_requirements, _appliedTreatmentKeys] call _fnc_splitRequirements;
    _split params ["_available", "_missing"];

    if (_appliedTreatments isNotEqualTo []) then {
        _lines pushBack format ["%1<t color='#9BE28F'>APPLIED: %2</t>", _indent, _appliedTreatments joinString ", "];
    };
    if (_available isNotEqualTo []) then {
        _lines pushBack format ["%1ITEM: %2", _indent, _available joinString ", "];
    };
    if (_missing isNotEqualTo []) then {
        _lines pushBack format ["%1<t color='#F06A5A'>MISSING: %2</t>", _indent, _missing joinString ", "];
    };
};

private _fnc_addNowRequirementLines = {
    params ["_lines", "_requirements", ["_indent", "    "], ["_appliedTreatments", []], ["_appliedTreatmentKeys", []]];

    private _split = [_requirements, _appliedTreatmentKeys] call _fnc_splitRequirements;
    _split params ["_available", "_missing"];

    {
        _lines pushBack format ["%1ITEM: %2", _indent, _x];
    } forEach _available;
    {
        _lines pushBack format ["%1ITEM: %2", _indent, _x];
    } forEach _missing;
};

private _fnc_buildNowProcedureRow = {
    params ["_heading", "_action", "_requirements", ["_appliedTreatments", []], ["_appliedTreatmentKeys", []]];

    private _rowLines = [
        _heading,
        format ["    DO: %1", _action]
    ];
    [_rowLines, _requirements, "    ", _appliedTreatments, _appliedTreatmentKeys] call _fnc_addNowRequirementLines;

    _rowLines
};

private _fnc_addUniqueString = {
    params ["_values", "_value"];

    if (_value isEqualType "" && { _value isNotEqualTo "" } && { !(_value in _values) }) then {
        _values pushBack _value;
    };
};

private _tourniquetRequirements = [];
[_tourniquetRequirements, "Tourniquet", ["ACE_tourniquet"]] call _fnc_addRequirement;

private _splintRequirements = [];
[_splintRequirements, "Splint", ["ACE_splint"]] call _fnc_addRequirement;

private _bleedRequirements = [];
[_bleedRequirements, "Packing Bandage", ["ACE_packingBandage", "ACE_fieldDressing", "ACE_elasticBandage", "ACE_quikclot"]] call _fnc_addRequirement;

private _tourniquetRemovalRequirements = [];
[_tourniquetRemovalRequirements, "Tourniquet Removal", []] call _fnc_addRequirement;

private _chestSealRequirements = [];
[_chestSealRequirements, "Chest Seal", ["kat_chestSeal"]] call _fnc_addRequirement;

private _painkillerRequirements = [];
[_painkillerRequirements, "Painkillers", ["ACE_painkillers", "ACE_painkillers_Item", "kat_Painkiller", "kat_Painkillers"]] call _fnc_addRequirement;

private _morphineRequirements = [];
[_morphineRequirements, "Morphine", ["ACE_morphine"]] call _fnc_addRequirement;

private _bloodTransfusionRequirements = [];
[_bloodTransfusionRequirements, "Blood Transfusion", ["ACE_bloodIV", "ACE_bloodIV_500", "ACE_bloodIV_250", "ACE_plasmaIV", "ACE_plasmaIV_500", "ACE_plasmaIV_250", "ACE_salineIV", "ACE_salineIV_500", "ACE_salineIV_250", "kat_bloodIV_O", "kat_bloodIV_O_500", "kat_bloodIV_O_250", "kat_bloodIV_A", "kat_bloodIV_A_500", "kat_bloodIV_A_250", "kat_bloodIV_B", "kat_bloodIV_B_500", "kat_bloodIV_B_250", "kat_bloodIV_AB", "kat_bloodIV_AB_500", "kat_bloodIV_AB_250"]] call _fnc_addRequirement;

private _airwayRequirements = [];
[_airwayRequirements, "Airway Adjunct", ["kat_guedel", "kat_larynx"]] call _fnc_addRequirement;

private _airwaySuctionRequirements = [];
[_airwaySuctionRequirements, "Airway Suction", ["kat_accuvac", "kat_suction"]] call _fnc_addRequirement;

private _ivRequirements = [];
[_ivRequirements, "IV Fluid / Blood Product", ["ACE_bloodIV", "ACE_bloodIV_500", "ACE_bloodIV_250", "ACE_plasmaIV", "ACE_plasmaIV_500", "ACE_plasmaIV_250", "ACE_salineIV", "ACE_salineIV_500", "ACE_salineIV_250", "kat_bloodIV_O", "kat_bloodIV_A", "kat_bloodIV_B", "kat_bloodIV_AB"]] call _fnc_addRequirement;

private _basicRequirements = [];
[_basicRequirements, "Bandage", ["ACE_fieldDressing", "ACE_packingBandage", "ACE_elasticBandage", "ACE_quikclot"]] call _fnc_addRequirement;
[_basicRequirements, "Tourniquet", ["ACE_tourniquet"]] call _fnc_addRequirement;

if (!_isAceLoaded) exitWith {
    private _nowLines = [
        "<t size='1.12' color='#9AD7FF'>FIRST AID</t>",
        "Advanced medical data is not detected.",
        "[ ] Use unit standard medical kit.",
        "[ ] Treat obvious bleeding, airway, and shock per SOP."
    ];
    [_nowLines, _basicRequirements] call _fnc_addNowRequirementLines;
    _nowLines pushBack "<t size='1.12' color='#9AD7FF'>ON SCENE</t>";
    _nowLines pushBack "Scan casualties. Treat lifesaving threats only.";
    _nowLines pushBack "Order: M bleed, A airway, R breathing, C shock, H cover.";
    _nowLines pushBack "[ ] Triage casualties.";
    _nowLines pushBack "[ ] Treat lifesaving threats only.";
    _nowLines pushBack "[ ] Mark and move to the next patient.";

    [
        ["FIRST AID", _nowLines],
        ["VITALS", ["<t size='1.12' color='#9AD7FF'>VITALS</t>", "[ ] Response: unknown", "[ ] Pain: unknown", "[ ] Heart Rate: unknown", "[ ] Blood Pressure: unknown", "[ ] Breathing: unknown", "[ ] Blood: unknown"]]
    ]
};

private _lifeState = lifeState _unit;
private _isDead = (!alive _unit) || { _lifeState in ["DEAD", "DEAD-RESPAWN"] };
private _isUnconscious = !_isDead && {
    (_unit getVariable ["ACE_isUnconscious", false]) || { _lifeState == "INCAPACITATED" }
};
private _isCardiacArrest = _unit getVariable ["ace_medical_inCardiacArrest", false];
private _bleedRate = _unit getVariable ["ace_medical_woundBleeding", 0];
private _isBleeding = _bleedRate > 0.01;
private _bloodVolume = _unit getVariable ["ace_medical_bloodVolume", 6];
private _heartRate = _unit getVariable ["ace_medical_heartRate", -1];
private _painValue = (((_unit getVariable ["ace_medical_pain", 0]) - (_unit getVariable ["ace_medical_painSuppress", 0])) max 0) min 1;
private _isAirwayObstructed = _unit getVariable ["kat_airway_obstruction", false];
private _isAirwayOccluded = _unit getVariable ["kat_airway_occluded", false];
private _isAirwayOverstretched = _unit getVariable ["kat_airway_overstretch", false];
private _isAirwayRecovery = _unit getVariable ["kat_airway_recovery", false];
private _airwayItem = _unit getVariable ["kat_airway_airway_item", ""];
private _isAirwayManaged = _isAirwayOverstretched || { _isAirwayRecovery } || { _airwayItem isNotEqualTo "" };
private _needsAirwayAction = _isUnconscious && {
    _isAirwayOccluded || { _isAirwayObstructed && { !_isAirwayManaged } }
};

private _trackedAppliedItems = _unit getVariable ["AWARE_appliedMedicalItems", []];
if !(_trackedAppliedItems isEqualType []) then {
    _trackedAppliedItems = [];
};

private _appliedTreatmentKeys = +_trackedAppliedItems;
private _trackedTreatmentMap = [
    ["Field Dressing", "ACE_fieldDressing", ["fielddressing", "ace_fielddressing", "field dressing"]],
    ["Packing Bandage", "ACE_packingBandage", ["packingbandage", "ace_packingbandage", "packing bandage"]],
    ["Elastic Bandage", "ACE_elasticBandage", ["elasticbandage", "ace_elasticbandage", "elastic bandage"]],
    ["QuikClot", "ACE_quikclot", ["quikclot", "ace_quikclot"]],
    ["Tourniquet", "ACE_tourniquet", ["applytourniquet", "tourniquet", "ace_tourniquet"]],
    ["Splint", "ACE_splint", ["splint", "ace_splint"]],
    ["Chest Seal", "kat_chestSeal", ["chestseal", "chest seal", "kat_chestseal"]],
    ["Painkillers", "ACE_painkillers", ["painkiller", "painkillers", "ace_painkillers", "ace_painkillers_item"]],
    ["Morphine", "ACE_morphine", ["morphine", "ace_morphine"]],
    ["Blood Transfusion", "AWARE_IVApplied", ["bloodiv", "bloodiv_500", "bloodiv_250", "plasmaiv", "plasmaiv_500", "plasmaiv_250", "salineiv", "salineiv_500", "salineiv_250", "ace_bloodiv", "ace_bloodiv_500", "ace_bloodiv_250", "ace_plasmaiv", "ace_plasmaiv_500", "ace_plasmaiv_250", "ace_salineiv", "ace_salineiv_500", "ace_salineiv_250", "aware_ivapplied"]]
];

{
    _x params ["_label", "_className", "_rawNames"];

    private _isTracked = (_label in _trackedAppliedItems) || { _className in _trackedAppliedItems };
    if (!_isTracked) then {
        {
            if (_x isEqualType "" && { (toLower _x) in _rawNames }) exitWith {
                _isTracked = true;
            };
        } forEach _trackedAppliedItems;
    };

    if (_isTracked) then {
        [_appliedTreatmentKeys, _label] call _fnc_addUniqueString;
        [_appliedTreatmentKeys, _className] call _fnc_addUniqueString;
    };
} forEach _trackedTreatmentMap;

if !(isNil "ace_medical_fnc_getIVs") then {
    private _ivs = [_unit] call ace_medical_fnc_getIVs;
    if (_ivs isEqualType [] && { _ivs isNotEqualTo [] }) then {
        [_appliedTreatmentKeys, "AWARE_IVApplied"] call _fnc_addUniqueString;
        [_appliedTreatmentKeys, "IV Fluid / Blood Product"] call _fnc_addUniqueString;
        [_appliedTreatmentKeys, "Blood Transfusion"] call _fnc_addUniqueString;
    };
};

private _medications = _unit getVariable ["ace_medical_medications", []];
if (_medications isEqualType []) then {
    {
        private _medicationValues = [_x];
        if (_x isEqualType []) then {
            _medicationValues = _x;
        };
        {
            if (_x isEqualType "") then {
                switch (toLower _x) do {
                    case "morphine";
                    case "ace_morphine": {
                        [_appliedTreatmentKeys, "ACE_morphine"] call _fnc_addUniqueString;
                        [_appliedTreatmentKeys, "Morphine"] call _fnc_addUniqueString;
                    };
                    case "painkiller";
                    case "painkillers";
                    case "ace_painkillers";
                    case "ace_painkillers_item": {
                        [_appliedTreatmentKeys, "ACE_painkillers"] call _fnc_addUniqueString;
                        [_appliedTreatmentKeys, "Painkillers"] call _fnc_addUniqueString;
                    };
                };
            };
        } forEach _medicationValues;
    } forEach _medications;
};

private _tourniquetValues = _unit getVariable ["ace_medical_tourniquets", [0, 0, 0, 0, 0, 0]];
private _fractureValues = _unit getVariable ["ace_medical_fractures", [0, 0, 0, 0, 0, 0]];
private _bodyPartDefinitions = [
    ["head", "Head", 0, false],
    ["body", "Torso", 1, false],
    ["leftarm", "Left Arm", 2, true],
    ["rightarm", "Right Arm", 3, true],
    ["leftleg", "Left Leg/Foot", 4, true],
    ["rightleg", "Right Leg/Foot", 5, true]
];
private _bodyPartStates = [];
private _hasAnyOpenWounds = false;
private _hasAnyBandagedWounds = false;

{
    _x params ["_bodyPartKey", "_bodyPartLabel", "_bodyPartIndex", "_isLimb"];

    private _openWounds = [_unit, _bodyPartKey, "ace_medical_openWounds", "ace_medical_fnc_getOpenWounds"] call _fnc_getBodyPartWounds;
    private _bandagedWounds = [_unit, _bodyPartKey, "ace_medical_bandagedWounds", "ace_medical_fnc_getBandagedWounds"] call _fnc_getBodyPartWounds;
    private _hasOpenWounds = [_openWounds] call _fnc_hasWounds;
    private _hasBandagedWounds = [_bandagedWounds] call _fnc_hasWounds;
    private _hasBleedingWounds = [_openWounds] call _fnc_hasBleedingWounds;

    if (_hasOpenWounds && { _isBleeding } && { !_hasBleedingWounds }) then {
        _hasBleedingWounds = true;
    };

    private _tourniquetValue = [_tourniquetValues, _bodyPartIndex, 0] call _fnc_getArrayValue;
    private _hasTourniquet = (_tourniquetValue isEqualType 0) && { _tourniquetValue > 0 };
    private _fractureValue = [_fractureValues, _bodyPartIndex, 0] call _fnc_getArrayValue;
    private _hasFracture = (_fractureValue isEqualType 0) && { _fractureValue == 1 };
    private _isSplinted = (_fractureValue isEqualType 0) && { _fractureValue < 0 };
    private _maxWoundDamage = [_openWounds + _bandagedWounds] call _fnc_getMaxWoundDamage;

    if (_hasOpenWounds) then {
        _hasAnyOpenWounds = true;
    };
    if (_hasBandagedWounds) then {
        _hasAnyBandagedWounds = true;
    };

    _bodyPartStates pushBack [
        _bodyPartKey,
        _bodyPartLabel,
        _bodyPartIndex,
        _isLimb,
        _hasOpenWounds,
        _hasBleedingWounds,
        _hasBandagedWounds,
        _hasTourniquet,
        _hasFracture,
        _isSplinted,
        _maxWoundDamage
    ];
} forEach _bodyPartDefinitions;

if (_hasAnyBandagedWounds) then {
    [_appliedTreatmentKeys, "AWARE_BandageApplied"] call _fnc_addUniqueString;
};
private _hasAnyTourniquet = (_bodyPartStates findIf { _x param [7, false] }) >= 0;
if (_hasAnyTourniquet) then {
    [_appliedTreatmentKeys, "ACE_tourniquet"] call _fnc_addUniqueString;
    [_appliedTreatmentKeys, "Tourniquet"] call _fnc_addUniqueString;
};

private _isKatBreathingLoaded = isClass (configFile >> "CfgPatches" >> "kat_breathing");
private _hasKatChestInjury = false;
{
    private _value = _unit getVariable [_x, false];
    if ((_value isEqualType true && { _value }) || { _value isEqualType 0 && { _value > 0 } } || { _value isEqualType [] && { _value isNotEqualTo [] } }) exitWith {
        _hasKatChestInjury = true;
    };
} forEach ["kat_breathing_deepPenetratingInjury", "kat_breathing_pneumothorax", "kat_breathing_hemopneumothorax", "kat_breathing_tensionpneumothorax"];

private _chestSealState = _unit getVariable ["kat_breathing_activeChestSeal", false];
private _hasChestSealApplied = (_chestSealState isEqualType true && { _chestSealState }) || { _chestSealState isEqualType 0 && { _chestSealState > 0 } } || { _chestSealState isEqualType [] && { _chestSealState isNotEqualTo [] } } || { "kat_chestSeal" in _appliedTreatmentKeys };
if (_hasChestSealApplied) then {
    [_appliedTreatmentKeys, "kat_chestSeal"] call _fnc_addUniqueString;
    [_appliedTreatmentKeys, "Chest Seal"] call _fnc_addUniqueString;
};

private _bloodStatus = "Normal";
private _bloodAction = "Reassess after each treatment.";
private _ivRequired = false;
switch (true) do {
    case (_bloodVolume < 3.6): {
        _bloodStatus = "Critical";
        _bloodAction = "Give blood transfusion after bleeding is controlled.";
        _ivRequired = true;
    };
    case (_bloodVolume < 4.2): {
        _bloodStatus = "Severe loss";
        _bloodAction = "Prioritize blood transfusion and monitor pulse/BP.";
        _ivRequired = true;
    };
    case (_bloodVolume < 5.1): {
        _bloodStatus = "Low";
        _bloodAction = "Prepare blood transfusion after bleeding is controlled.";
        _ivRequired = true;
    };
};

private _nowLines = [
    "<t size='1.12' color='#9AD7FF'>FIRST AID</t>"
];
private _hasImmediateAction = false;
private _orderedTreatmentSteps = [];
private _nowTreatmentRows = [];
private _hasLifeThreatTreatmentRows = false;

private _fnc_addOrderedTreatmentStep = {
    params ["_heading", "_action", "_requirements", ["_appliedKeys", []], ["_isLifeThreat", true]];

    if (_requirements isEqualTo []) exitWith {};
    if ([_requirements, _appliedKeys] call _fnc_hasAllRequirementsApplied) exitWith {};

    _orderedTreatmentSteps pushBack [_heading, _action, _requirements, [], _appliedKeys];
    if (_isLifeThreat) then {
        _hasLifeThreatTreatmentRows = true;
    };
};

if (_isDead) then {
    _nowLines pushBack "<t color='#F06A5A'>Patient is dead. Confirm per SOP.</t>";
    _hasImmediateAction = true;
} else {
    if (_isCardiacArrest) then {
        _nowLines pushBack "<t color='#F06A5A'>CPR NOW.</t>";
        _nowLines pushBack "    DO: Start CPR. Control active bleeding when possible.";
        _hasImmediateAction = true;
    };

    {
        _x params [
            "_bodyPartKey",
            "_bodyPartLabel",
            "_bodyPartIndex",
            "_isLimb",
            "_hasOpenWounds",
            "_hasBleedingWounds",
            "_hasBandagedWounds",
            "_hasTourniquet",
            "_hasFracture",
            "_isSplinted",
            "_maxWoundDamage"
        ];

        if (_isLimb && { _hasOpenWounds || { _hasFracture } || { _hasTourniquet } }) then {
            private _rowRequirements = [];
            private _rowKeys = [_appliedTreatmentKeys, []] call _fnc_mergeTreatmentKeys;

            if (_hasTourniquet) then {
                [_rowKeys, _bodyPartKey, ["ACE_tourniquet", "Tourniquet"]] call _fnc_addPartAppliedKeys;
            };
            if (_isSplinted) then {
                [_rowKeys, _bodyPartKey, ["ACE_splint", "Splint"]] call _fnc_addPartAppliedKeys;
            };
            if (_hasBandagedWounds) then {
                [_rowKeys, _bodyPartKey, ["AWARE_BandageApplied", "Packing Bandage"]] call _fnc_addPartAppliedKeys;
            };

            if ((_hasOpenWounds && { _hasBleedingWounds || { _isBleeding } || { _hasTourniquet } }) || { _hasTourniquet && { !_hasBandagedWounds } }) then {
                [_rowRequirements, _tourniquetRequirements] call _fnc_appendRequirements;
            };
            if (_hasFracture || { _isSplinted }) then {
                [_rowRequirements, _splintRequirements] call _fnc_appendRequirements;
            };
            if (_hasOpenWounds || { _hasTourniquet && { !_hasBandagedWounds } }) then {
                [_rowRequirements, _bleedRequirements] call _fnc_appendRequirements;
            };
            if (_hasTourniquet && { _hasBandagedWounds }) then {
                [_rowRequirements, _tourniquetRemovalRequirements] call _fnc_appendRequirements;
            };

            private _limbHeading = format ["<t color='#F06A5A'>M - %1 %2</t>", toUpper _bodyPartLabel, ["WOUND", "BLEEDING"] select (_hasBleedingWounds || { _isBleeding } || { _hasTourniquet })];
            private _limbAction = "Apply in order: tourniquet, splint if fractured, then pack and bandage.";
            if (!_hasOpenWounds && { _hasFracture }) then {
                _limbHeading = format ["<t color='#F0B45A'>H - %1 FRACTURE</t>", toUpper _bodyPartLabel];
                _limbAction = "Apply splint to fractured limb.";
            } else {
                if (_hasTourniquet && { _hasBandagedWounds }) then {
                    _limbAction = "Bandage is on. Remove tourniquet as soon as possible and recheck bleeding.";
                } else {
                    if (_hasTourniquet) then {
                        _limbAction = "Tourniquet is on. Splint if fractured, then pack and bandage.";
                    };
                };
            };

            [
                _limbHeading,
                _limbAction,
                _rowRequirements,
                _rowKeys,
                true
            ] call _fnc_addOrderedTreatmentStep;
        };
    } forEach _bodyPartStates;

    private _torsoStateIndex = _bodyPartStates findIf { (_x param [0, ""]) isEqualTo "body" };
    if (_torsoStateIndex >= 0) then {
        private _torsoState = _bodyPartStates select _torsoStateIndex;
        _torsoState params [
            "_bodyPartKey",
            "_bodyPartLabel",
            "_bodyPartIndex",
            "_isLimb",
            "_hasOpenWounds",
            "_hasBleedingWounds",
            "_hasBandagedWounds",
            "_hasTourniquet",
            "_hasFracture",
            "_isSplinted",
            "_maxWoundDamage"
        ];

        private _needsChestSeal = _isKatBreathingLoaded && {
            !_hasChestSealApplied && {
                _hasKatChestInjury || { _hasOpenWounds && { _maxWoundDamage >= 0.35 } } || { _hasBandagedWounds && { _maxWoundDamage >= 0.35 } }
            }
        };

        if (_hasOpenWounds || { _needsChestSeal }) then {
            private _rowRequirements = [];
            private _rowKeys = [_appliedTreatmentKeys, []] call _fnc_mergeTreatmentKeys;

            if (_hasBandagedWounds) then {
                [_rowKeys, _bodyPartKey, ["AWARE_BandageApplied", "Packing Bandage"]] call _fnc_addPartAppliedKeys;
            };
            if (_hasOpenWounds || { _hasBandagedWounds }) then {
                [_rowRequirements, _bleedRequirements] call _fnc_appendRequirements;
            };
            if (_needsChestSeal || { _hasChestSealApplied }) then {
                [_rowRequirements, _chestSealRequirements] call _fnc_appendRequirements;
            };

            [
                "<t color='#F06A5A'>M/R - TORSO WOUND</t>",
                "Pack and bandage torso wound first. Apply chest seal after bandaging if penetrating chest injury is present.",
                _rowRequirements,
                _rowKeys,
                true
            ] call _fnc_addOrderedTreatmentStep;
        };
    };

    private _needsGenericBleedFollowUp = !_hasAnyOpenWounds && { _isBleeding || { _hasAnyTourniquet && { !_hasAnyBandagedWounds } } };
    if (_needsGenericBleedFollowUp) then {
        private _genericBleedRequirements = [];
        [_genericBleedRequirements, _tourniquetRequirements] call _fnc_appendRequirements;
        [_genericBleedRequirements, _bleedRequirements] call _fnc_appendRequirements;

        [
            "<t color='#F06A5A'>M - ACTIVE BLEEDING</t>",
            "Find wound source. Apply tourniquet first, then pack and bandage.",
            _genericBleedRequirements,
            _appliedTreatmentKeys,
            true
        ] call _fnc_addOrderedTreatmentStep;
    };

    if (!_hasAnyOpenWounds && { _hasAnyTourniquet && { _hasAnyBandagedWounds } }) then {
        [
            "<t color='#F0B45A'>M - TOURNIQUET FOLLOW-UP</t>",
            "Bandage is on. Remove tourniquet as soon as possible and recheck bleeding.",
            _tourniquetRemovalRequirements,
            _appliedTreatmentKeys,
            true
        ] call _fnc_addOrderedTreatmentStep;
    };

    if (_needsAirwayAction) then {
        private _airwayAction = "Use airway adjunct or position airway, then reassess breathing.";
        private _airwayRequirementSet = _airwayRequirements;
        if (_isAirwayOccluded) then {
            _airwayAction = "Clear airway occlusion with suction, then reassess breathing.";
            _airwayRequirementSet = _airwaySuctionRequirements;
        };

        [
            "<t color='#F0B45A'>A - AIRWAY</t>",
            _airwayAction,
            _airwayRequirementSet,
            _appliedTreatmentKeys,
            true
        ] call _fnc_addOrderedTreatmentStep;
    };

    if (_ivRequired) then {
        [
            format ["<t color='#F0B45A'>C - SHOCK: %1</t>", _bloodStatus],
            _bloodAction,
            _bloodTransfusionRequirements,
            _appliedTreatmentKeys,
            true
        ] call _fnc_addOrderedTreatmentStep;
    };

    if (_painValue > 0.15) then {
        private _painRequirements = [];
        [_painRequirements, _painkillerRequirements] call _fnc_appendRequirements;

        private _treatedLimbIndex = _bodyPartStates findIf {
            (_x param [3, false]) && { (_x param [6, false]) || { (_x param [7, false]) } || { (_x param [9, false]) } }
        };
        if (_treatedLimbIndex >= 0) then {
            [_painRequirements, _morphineRequirements] call _fnc_appendRequirements;
        };

        [
            "<t color='#F0B45A'>H - PAIN CONTROL</t>",
            "After lifesaving treatment, give painkillers. Use morphine for treated painful limb injuries.",
            _painRequirements,
            _appliedTreatmentKeys,
            false
        ] call _fnc_addOrderedTreatmentStep;
    };

    {
        _x params ["_heading", "_action", "_requirements", "_appliedTreatments", "_appliedTreatmentKeys"];
        _nowTreatmentRows pushBack ([
            _heading,
            _action,
            _requirements,
            _appliedTreatments,
            _appliedTreatmentKeys
        ] call _fnc_buildNowProcedureRow);
    } forEach _orderedTreatmentSteps;

    {
        private _rowLines = _x;
        {
            _nowLines pushBack _x;
        } forEach _rowLines;
    } forEach _nowTreatmentRows;

    if (_nowTreatmentRows isNotEqualTo []) then {
        _hasImmediateAction = true;
    };

    if (!_hasImmediateAction) then {
        _nowLines pushBack "No immediate checklist action detected.";
        _nowLines pushBack "Check vitals. Mark casualty. Move to next patient.";
    };
};

_nowLines pushBack "<t size='1.12' color='#9AD7FF'>ON SCENE</t>";
_nowLines pushBack "Scan casualties. Treat lifesaving threats only.";
_nowLines pushBack "Order: M bleed, A airway, R breathing, C shock, H cover.";

if (_isCardiacArrest) then {
    _nowLines pushBack "[ ] Begin CPR.";
};
if (_isBleeding) then {
    _nowLines pushBack "[ ] Control active bleeding.";
};
if (_needsAirwayAction) then {
    _nowLines pushBack "[ ] Treat airway problem and monitor breathing.";
};
if (_ivRequired) then {
    _nowLines pushBack format ["[ ] Treat shock: %1.", _bloodStatus];
};
if (!_isCardiacArrest && { !_isBleeding } && { !_needsAirwayAction } && { !_ivRequired }) then {
    _nowLines pushBack "[ ] No urgent ACE status detected.";
    _nowLines pushBack "[ ] Check pulse, blood pressure, pain, and responsiveness.";
};
_nowLines pushBack "[ ] Cover casualty and prepare movement.";

private _responseStatus = "Responsive";
if (_isDead) then {
    _responseStatus = "Dead";
} else {
    if (_isUnconscious) then {
        _responseStatus = "Unresponsive";
    };
};
private _responseText = format ["Response: %1", _responseStatus];
private _painText = format ["Pain: %1%2", round (_painValue * 100), "%"];
private _heartRateText = if (_heartRate >= 0) then {
    format ["Heart Rate: %1", round _heartRate]
} else {
    "Heart Rate: unknown"
};
private _bloodPressure = _unit getVariable ["ace_medical_bloodPressure", []];
if (!(_bloodPressure isEqualType []) || { (count _bloodPressure) < 2 }) then {
    if !(isNil "ace_medical_status_fnc_getBloodPressure") then {
        _bloodPressure = [_unit] call ace_medical_status_fnc_getBloodPressure;
    };
};
private _bloodPressureText = if (_bloodPressure isEqualType [] && { (count _bloodPressure) >= 2 } && { (_bloodPressure select 0) isEqualType 0 } && { (_bloodPressure select 1) isEqualType 0 }) then {
    private _diastolicPressure = round (_bloodPressure select 0);
    private _systolicPressure = round (_bloodPressure select 1);
    format ["Blood Pressure: %1/%2", _systolicPressure, _diastolicPressure]
} else {
    "Blood Pressure: unknown"
};
private _breathingRate = 15;
{
    private _candidateBreathingRate = _unit getVariable [_x, -1];
    if (_candidateBreathingRate isEqualType 0 && { _candidateBreathingRate >= 0 }) exitWith {
        _breathingRate = _candidateBreathingRate;
    };
} forEach ["kat_breathing_breathRate", "kat_vitals_breathRate", "kat_breathing_respiratoryRate", "kat_vitals_respiratoryRate"];
private _breathingText = ["Breathing: Normal", "Breathing: Rapid"] select (_breathingRate > 25);
private _bloodText = format ["Blood: %1", _bloodStatus];

private _recheckLines = [
    "<t size='1.12' color='#9AD7FF'>VITALS</t>",
    format ["[ ] %1", _responseText],
    format ["[ ] %1", _painText],
    format ["[ ] %1", _heartRateText],
    format ["[ ] %1", _bloodPressureText],
    format ["[ ] %1", _breathingText],
    format ["[ ] %1", _bloodText]
];

[
    ["FIRST AID", _nowLines],
    ["VITALS", _recheckLines]
]
