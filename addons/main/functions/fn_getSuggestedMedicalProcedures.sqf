/*
    Function: AWARE_fnc_getSuggestedMedicalProcedures
    Builds tabbed checklist suggestions from current patient state.
*/

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {
    [
        ["NOW", ["[ ] No patient selected."]],
        ["FIRST", ["[ ] Select a patient and reopen the medical menu."]],
        ["TRANSPORT", ["[ ] No transport guidance available."]],
        ["RECHECK", ["[ ] No recheck guidance available."]]
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

private _fnc_addUseMissingLines = {
    params ["_lines", "_requirements", ["_indent", "    "], ["_appliedTreatments", []]];

    private _split = [_requirements] call _fnc_splitRequirements;
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
    params ["_lines", "_requirements", ["_indent", "    "], ["_appliedTreatments", []]];

    private _split = [_requirements] call _fnc_splitRequirements;
    _split params ["_available", "_missing"];

    if (_appliedTreatments isNotEqualTo []) then {
        _lines pushBack format ["%1<t color='#9BE28F'>APPLIED: %2</t>", _indent, _appliedTreatments joinString ", "];
    };
    {
        _lines pushBack format ["%1ITEM: %2", _indent, _x];
    } forEach _available;
    {
        _lines pushBack format ["%1<t color='#F06A5A'>Required Item: %2</t>", _indent, _x];
    } forEach _missing;
};

private _fnc_buildNowProcedureRow = {
    params ["_heading", "_action", "_requirements", ["_appliedTreatments", []]];

    private _rowLines = [
        _heading,
        format ["    DO: %1", _action]
    ];
    [_rowLines, _requirements, "    ", _appliedTreatments] call _fnc_addNowRequirementLines;

    _rowLines
};

private _bleedRequirements = [];
[_bleedRequirements, "Packing Bandage", ["ACE_packingBandage", "ACE_fieldDressing", "ACE_elasticBandage", "ACE_quikclot"]] call _fnc_addRequirement;
[_bleedRequirements, "Elastic Bandage", ["ACE_elasticBandage", "ACE_packingBandage", "ACE_fieldDressing", "ACE_quikclot"]] call _fnc_addRequirement;

private _airwayRequirements = [];
[_airwayRequirements, "Airway Adjunct", ["kat_guedel", "kat_larynx"]] call _fnc_addRequirement;

private _ivRequirements = [];
[_ivRequirements, "IV Fluid / Blood Product", ["ACE_bloodIV", "ACE_bloodIV_500", "ACE_bloodIV_250", "ACE_plasmaIV", "ACE_plasmaIV_500", "ACE_plasmaIV_250", "ACE_salineIV", "ACE_salineIV_500", "ACE_salineIV_250", "kat_bloodIV_O", "kat_bloodIV_A", "kat_bloodIV_B", "kat_bloodIV_AB"]] call _fnc_addRequirement;

private _basicRequirements = [];
[_basicRequirements, "Bandage", ["ACE_fieldDressing", "ACE_packingBandage", "ACE_elasticBandage", "ACE_quikclot"]] call _fnc_addRequirement;
[_basicRequirements, "Tourniquet", ["ACE_tourniquet"]] call _fnc_addRequirement;

if (!_isAceLoaded) exitWith {
    private _nowLines = [
        "<t size='1.12' color='#9AD7FF'>NOW - NEXT ACTION</t>",
        "Advanced medical data is not detected.",
        "[ ] Use unit standard medical kit.",
        "[ ] Treat obvious bleeding, airway, and shock per SOP."
    ];
    [_nowLines, _basicRequirements] call _fnc_addNowRequirementLines;

    [
        ["NOW", _nowLines],
        ["FIRST", ["<t size='1.12' color='#9AD7FF'>FIRST - ON SCENE</t>", "[ ] Triage casualties.", "[ ] Treat lifesaving threats only.", "[ ] Mark and move to the next patient."]],
        ["TRANSPORT", ["<t size='1.12' color='#9AD7FF'>TRANS - EN ROUTE</t>", "[ ] Keep treatments in place.", "[ ] Recheck pulse, breathing, and bleeding after movement."]],
        ["RECHECK", ["<t size='1.12' color='#9AD7FF'>RECHECK</t>", "[ ] Reassess manually.", "[ ] Confirm required supplies before handoff."]]
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

private _patientAppliedTreatments = [];
if !(isNil "ace_medical_fnc_getIVs") then {
    private _ivs = _unit call ace_medical_fnc_getIVs;
    if (_ivs isEqualType [] && { _ivs isNotEqualTo [] }) then {
        _patientAppliedTreatments pushBack "IV / Fluid";
    };
};

private _bloodStatus = "Normal";
private _bloodAction = "Reassess after each treatment.";
private _ivRequired = false;
switch (true) do {
    case (_bloodVolume < 3.6): {
        _bloodStatus = "Critical";
        _bloodAction = "Replace volume aggressively after bleeding is controlled.";
        _ivRequired = true;
    };
    case (_bloodVolume < 4.2): {
        _bloodStatus = "Severe loss";
        _bloodAction = "Prioritize blood products and monitor pulse/BP.";
        _ivRequired = true;
    };
    case (_bloodVolume < 5.1): {
        _bloodStatus = "Low";
        _bloodAction = "Start fluids after bleeding is controlled.";
        _ivRequired = true;
    };
};

private _nowLines = [
    "<t size='1.12' color='#9AD7FF'>NOW - NEXT ACTION</t>"
];
private _hasImmediateAction = false;
private _maxNowTreatmentProcedures = 2;
private _nowTreatmentRows = [];

if (_isDead) then {
    _nowLines pushBack "<t color='#F06A5A'>Patient is dead. Confirm per SOP.</t>";
    _hasImmediateAction = true;
} else {
    if (_isCardiacArrest) then {
        _nowLines pushBack "<t color='#F06A5A'>CPR NOW.</t>";
        _nowLines pushBack "    DO: Start CPR. Control active bleeding when possible.";
        _hasImmediateAction = true;
    };

    if (_isBleeding) then {
        _nowTreatmentRows pushBack ([
            "<t color='#F06A5A'>M - ACTIVE BLEEDING</t>",
            "Pack wound, bandage, and recheck until bleeding stops.",
            _bleedRequirements
        ] call _fnc_buildNowProcedureRow);
    };

    if (_isUnconscious) then {
        _nowTreatmentRows pushBack ([
            "<t color='#F0B45A'>A - AIRWAY</t>",
            "Open airway and monitor breathing.",
            _airwayRequirements
        ] call _fnc_buildNowProcedureRow);
    };

    if (_ivRequired) then {
        _nowTreatmentRows pushBack ([
            format ["<t color='#F0B45A'>C - SHOCK: %1</t>", _bloodStatus],
            _bloodAction,
            _ivRequirements,
            _patientAppliedTreatments
        ] call _fnc_buildNowProcedureRow);
    };

    if ((count _nowTreatmentRows) > _maxNowTreatmentProcedures) then {
        _nowTreatmentRows resize _maxNowTreatmentProcedures;
    };

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

private _firstLines = [
    "<t size='1.12' color='#9AD7FF'>FIRST - ON SCENE</t>",
    "Scan casualties. Treat lifesaving threats only.",
    "Order: M bleed, A airway, R breathing, C shock, H cover."
];

if (_isCardiacArrest) then {
    _firstLines pushBack "[ ] Begin CPR.";
};
if (_isBleeding) then {
    _firstLines pushBack "[ ] Control active bleeding.";
    [_firstLines, _bleedRequirements] call _fnc_addUseMissingLines;
};
if (_isUnconscious) then {
    _firstLines pushBack "[ ] Open airway and monitor breathing.";
    [_firstLines, _airwayRequirements] call _fnc_addUseMissingLines;
};
if (_ivRequired) then {
    _firstLines pushBack format ["[ ] Treat shock: %1.", _bloodStatus];
    [_firstLines, _ivRequirements, "    ", _patientAppliedTreatments] call _fnc_addUseMissingLines;
};
if (!_isCardiacArrest && { !_isBleeding } && { !_isUnconscious } && { !_ivRequired }) then {
    _firstLines pushBack "[ ] No urgent ACE status detected.";
    _firstLines pushBack "[ ] Check pulse, blood pressure, pain, and responsiveness.";
};
_firstLines pushBack "[ ] Cover casualty and prepare movement.";

private _transportLines = [
    "<t size='1.12' color='#9AD7FF'>TRANS - EN ROUTE</t>",
    "Keep applied treatments in place.",
    "Recheck every move: bleeding, airway, breathing, pulse/BP."
];

if (_isBleeding) then {
    _transportLines pushBack "[ ] Recheck bandages for bleed-through.";
};
if (_isUnconscious) then {
    _transportLines pushBack "[ ] Maintain airway and monitor breathing.";
};
if (_ivRequired) then {
    _transportLines pushBack format ["[ ] Continue fluids/blood: %1.", _bloodAction];
    [_transportLines, _ivRequirements, "    ", _patientAppliedTreatments] call _fnc_addUseMissingLines;
};
_transportLines pushBack "[ ] Keep warm. Tell MEDEVAC what was done and missing.";

private _heartRateText = if (_heartRate >= 0) then {
    format ["Heart rate: %1", round _heartRate]
} else {
    "Heart rate: unknown"
};
private _painText = format ["Pain: %1%2", round (_painValue * 100), "%"];
private _bloodText = format ["Blood: %1", _bloodStatus];

private _recheckLines = [
    "<t size='1.12' color='#9AD7FF'>RECHECK</t>",
    format ["[ ] %1", _heartRateText],
    format ["[ ] %1", _bloodText],
    format ["[ ] %1", _painText],
    "[ ] Confirm bleeding remains controlled.",
    "[ ] Confirm airway and breathing.",
    "[ ] Update handoff notes before transport."
];

[
    ["NOW", _nowLines],
    ["FIRST", _firstLines],
    ["TRANSPORT", _transportLines],
    ["RECHECK", _recheckLines]
]
