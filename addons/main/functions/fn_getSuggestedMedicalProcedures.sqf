/*
    Function: AWARE_fnc_getSuggestedMedicalProcedures
    Builds tabbed KAT/ACE checklist suggestions from current patient state.
*/

params [
    "_unit",
    ["_partStates", []]
];

if (isNull _unit) exitWith {
    [
        ["MARCH", ["<t color='#F0B45A'>NO PATIENT DATA</t>", "[ ] Reopen medical menu after selecting patient."]],
        ["BODY", ["[ ] No patient selected."]],
        ["ITEMS", ["[ ] No item guidance available."]],
        ["RECHECK", ["[ ] Select patient and reopen medical menu."]]
    ]
};

private _isAceLoaded = isClass (configFile >> "CfgPatches" >> "ace_medical");
if (!_isAceLoaded) exitWith {
    [
        ["MARCH", ["<t color='#F0B45A'>MEDICAL SYSTEM</t>", "[ ] ACE/KAT medical not detected.", "[ ] Follow your unit treatment SOP."]],
        ["BODY", ["[ ] No ACE body-state data."]],
        ["ITEMS", ["[ ] Use unit standard medical kit."]],
        ["RECHECK", ["[ ] Reassess manually."]]
    ]
};

private _isKatLoaded = false;
{
    if (isClass (configFile >> "CfgPatches" >> _x)) exitWith {
        _isKatLoaded = true;
    };
} forEach ["kat_main", "KAT_main", "kat_airway", "kat_breathing", "kat_circulation", "kat_pharma"];

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

    private _status = "Stable";
    switch (true) do {
        case (_bleedRatio > 0.35): {
            _status = "Heavy bleed";
        };
        case (_bleedRatio > 0.01 || { _openWoundsCount > 0 }): {
            _status = "Bleeding";
        };
        case (_damageValue > 0.7): {
            _status = "Severe trauma";
        };
        case (_damageValue > 0.35): {
            _status = "Moderate trauma";
        };
        case (_damageValue > 0.01): {
            _status = "Minor trauma";
        };
    };

    if (_hasFracture) then {
        _status = _status + ", fracture";
    };
    if (_hasTourniquet) then {
        _status = _status + ", TQ on";
    };
    if (_openWoundsCount > 0) then {
        _status = _status + format [", wounds x%1", _openWoundsCount];
    };

    private _items = [];
    private _action = "Monitor and reassess.";

    if (_bleedRatio > 0.35) then {
        if (_partType in ["arm", "leg"]) then {
            _items append ["Tourniquet", "Packing Bandage", "Elastic Bandage"];
            _action = "TQ high/tight, pack, then bandage.";
        } else {
            _items append ["Packing Bandage", "Elastic Bandage"];
            _action = "Pack wound and bandage until controlled.";
        };
    } else {
        if (_bleedRatio > 0.01 || { _openWoundsCount > 0 }) then {
            _items append ["Packing Bandage", "Elastic Bandage"];
            _action = "Bandage until bleeding is controlled.";
        };
    };

    if (_partType isEqualTo "torso" && { _damageValue > 0.01 || _bleedRatio > 0.01 }) then {
        _items pushBack "Chest Seal";
        _action = _action + " Seal chest wounds; check breathing.";
        if (_damageValue > 0.35) then {
            _items pushBack "Needle Decompression";
        };
    };

    if (_partType isEqualTo "head" && { _isUnconscious }) then {
        _items pushBack "NPA / King LT";
        _action = "Secure airway and monitor breathing.";
    };

    if (_hasFracture) then {
        _items pushBack "Splint";
        _action = _action + " Splint after bleeding control.";
    };

    if (_items isEqualTo []) then {
        _items pushBack "Monitor";
    };

    private _uniqueItems = [];
    {
        if !(_x in _uniqueItems) then {
            _uniqueItems pushBack _x;
        };
    } forEach _items;

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
        _uniqueItems,
        _action,
        _priorityColor,
        _bleedRatio,
        _damageValue,
        _hasFracture
    ]
};

private _isUnconscious = (_unit getVariable ["ACE_isUnconscious", false]) || { lifeState _unit == "INCAPACITATED" };
private _isCardiacArrest = _unit getVariable ["ace_medical_inCardiacArrest", false];
private _isLosingBlood = (_unit getVariable ["ace_medical_woundBleeding", 0]) > 0.01;
private _bloodVolume = _unit getVariable ["ace_medical_bloodVolume", 6];
private _painValue = (((_unit getVariable ["ace_medical_pain", 0]) - (_unit getVariable ["ace_medical_painSuppress", 0])) max 0) min 1;

private _bloodStatus = "Normal";
private _bloodItems = "Monitor vitals";
private _bloodAction = "Reassess after each treatment.";
switch (true) do {
    case (_bloodVolume < 3.6): {
        _bloodStatus = "Critical";
        _bloodItems = "Blood, Plasma, IV/IO access";
        _bloodAction = "Aggressive volume replacement after bleed control.";
    };
    case (_bloodVolume < 4.2): {
        _bloodStatus = "Severe loss";
        _bloodItems = "Blood or Plasma, IV/IO access";
        _bloodAction = "Prioritize blood products and monitor pulse/BP.";
    };
    case (_bloodVolume < 5.1): {
        _bloodStatus = "Low";
        _bloodItems = "Saline/Blood, IV access";
        _bloodAction = "Start fluids after active bleeding is controlled.";
    };
};

private _partRows = [];
{
    _partRows pushBack ([_x select 0, _x select 1, _x select 2, _partStates, _isUnconscious] call _fnc_partSummary);
} forEach [
    ["Head", "Head", "head"],
    ["Torso", "Torso", "torso"],
    ["Left Arm", "Left Hand", "arm"],
    ["Right Arm", "Right Hand", "arm"],
    ["Left Foot", "Left Leg", "leg"],
    ["Right Foot", "Right Leg", "leg"]
];

private _marchLines = [
    "<t size='1.12' color='#9AD7FF'>IMMEDIATE CHECKLIST</t>",
    "<t color='#F0B45A'>[ ] M</t> Massive bleeding: stop life-threatening bleeds.",
    "<t color='#F0B45A'>[ ] A</t> Airway: check responsiveness and obstruction.",
    "<t color='#F0B45A'>[ ] R</t> Respiration: inspect torso/chest and breathing.",
    "<t color='#F0B45A'>[ ] C</t> Circulation: pulse/BP and blood volume.",
    "<t color='#F0B45A'>[ ] H</t> Head/Hypothermia: protect, reassess, prevent relapse."
];

if (_isKatLoaded) then {
    _marchLines pushBack "<t color='#8FD8C8'>[ ] KAT</t> Use airway, breathing, and circulation extensions.";
} else {
    _marchLines pushBack "<t color='#D8DEE9'>[ ] ACE fallback</t> KAT actions may not be available.";
};
if (_isUnconscious) then {
    _marchLines pushBack "[ ] Airway priority: NPA / King LT and monitor breathing.";
};
if (_isCardiacArrest) then {
    _marchLines pushBack "[ ] Cardiac arrest: CPR plus monitor/drug protocol.";
};

private _bodyLines = ["<t size='1.12' color='#9AD7FF'>BODY PART CHECKLIST</t>"];
{
    _x params ["_name", "_status", "_items", "_action", "_color"];
    _bodyLines pushBack format ["<t color='%1'>[ ] %2</t> %3", _color, toUpper _name, _status];
    _bodyLines pushBack format ["    - Action: %1", _action];
} forEach _partRows;

private _itemLines = [
    "<t size='1.12' color='#9AD7FF'>ITEM SELECTION</t>",
    format ["<t color='#F0B45A'>[ ] Blood:</t> %1. Items: %2.", _bloodStatus, _bloodItems],
    format ["    - %1", _bloodAction]
];

if (_isLosingBlood) then {
    _itemLines pushBack "[ ] Active bleed: control bleeding before volume replacement.";
};
if (_painValue > 0.4) then {
    _itemLines pushBack "[ ] Pain: treat after life threats are stable.";
};

{
    _x params ["_name", "_status", "_items", "_action", "_color"];
    if (_items isNotEqualTo ["Monitor"]) then {
        _itemLines pushBack format ["<t color='%1'>[ ] %2:</t> %3", _color, _name, _items joinString ", "];
    };
} forEach _partRows;

private _recheckLines = [
    "<t size='1.12' color='#9AD7FF'>REASSESSMENT</t>",
    "[ ] Recheck bleeding after every bandage or TQ.",
    "[ ] Recheck airway and breathing after torso/head treatment.",
    "[ ] Recheck pulse/BP after fluids or blood.",
    "[ ] Splints: confirm pain reduction and limb pulse.",
    "[ ] Tourniquets: review only if SOP and condition allow.",
    "[ ] Final pass: vitals, pain, wounds, fractures, evacuation."
];

[
    ["MARCH", _marchLines],
    ["BODY", _bodyLines],
    ["ITEMS", _itemLines],
    ["RECHECK", _recheckLines]
]
