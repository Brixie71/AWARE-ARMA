/*
    Function: AWARE_fnc_getPriorityMedicalWorkflow
    Builds the first-tab rapid casualty treatment workflow.
*/

params [
    "_unit",
    ["_injuredPartRows", []],
    ["_bloodStatus", "Normal"],
    ["_bloodAction", "Reassess after each treatment."],
    ["_bloodRequirements", []],
    ["_isUnconscious", false],
    ["_isCardiacArrest", false],
    ["_isLosingBlood", false],
    ["_inventoryItems", []]
];

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

private _fnc_formatRequirementText = {
    params ["_available", "_missing"];

    private _segments = [];
    if (_available isNotEqualTo []) then {
        _segments pushBack format ["Use: %1", _available joinString ", "];
    };
    if (_missing isNotEqualTo []) then {
        private _quotedMissing = _missing apply { format ["""%1""", _x] };
        _segments pushBack format ["<t color='#F06A5A'>Required: %1</t>", _quotedMissing joinString ", "];
    };

    _segments joinString " | "
};

private _lines = [
    format ["<t size='1.14' color='#9AD7FF'>%1</t>", localize "STR_AWARE_RAPID_PRIORITY_WORKFLOW"],
    "<t color='#F0B45A'>[ ] FLOW</t> Bleed control > Airway > Breathing > Circulation > Reassess"
];

if (_isCardiacArrest) then {
    _lines pushBack "<t color='#F06A5A'>[ ] CARDIAC ARREST</t> | CPR plus monitor/drug protocol per SOP.";
};

if (_isUnconscious) then {
    _lines pushBack "<t color='#F0B45A'>[ ] AIRWAY</t> | Open airway | Add adjunct if available | Monitor breathing.";
};

if (_injuredPartRows isEqualTo []) then {
    _lines pushBack "[ ] No severe wound detected by AWARE. Recheck the medical menu and patient vitals.";
} else {
    _lines pushBack format ["<t size='1.08' color='#9AD7FF'>%1</t>", localize "STR_AWARE_ACTIVE_PRIORITY"];

    private _stepNumber = 1;
    {
        if (_stepNumber <= 5) then {
            _x params ["_name", "_status", "_requirements", "_action", "_color"];
            private _split = [_requirements] call _fnc_splitRequirements;
            _split params ["_available", "_missing"];
            private _requirementText = [_available, _missing] call _fnc_formatRequirementText;
            private _itemText = "";
            if (_requirementText != "") then {
                _itemText = " | " + _requirementText;
            };

            _lines pushBack format ["<t color='%1'>[ ] %2 %3</t> | %4 | Do: %5%6", _color, _stepNumber, toUpper _name, _status, _action, _itemText];
            _stepNumber = _stepNumber + 1;
        };
    } forEach _injuredPartRows;
};

if (_bloodRequirements isNotEqualTo []) then {
    private _split = [_bloodRequirements] call _fnc_splitRequirements;
    _split params ["_available", "_missing"];
    private _requirementText = [_available, _missing] call _fnc_formatRequirementText;
    private _itemText = "";
    if (_requirementText != "") then {
        _itemText = " | " + _requirementText;
    };

    _lines pushBack format ["<t size='1.08' color='#9AD7FF'>%1</t>", localize "STR_AWARE_AFTER_BLEED_CONTROL"];
    _lines pushBack format ["<t color='#F0B45A'>[ ] VOLUME</t> | %1 | Do: %2%3", _bloodStatus, _bloodAction, _itemText];
};

if (_isLosingBlood) then {
    _lines pushBack "<t color='#F06A5A'>[ ] ACTIVE BLEED</t> | Stay until bleeding is controlled or casualty is triaged.";
};

_lines pushBack "[ ] REASSESS | Bleeding | Airway | Breathing | Pulse/BP | Move to next casualty.";

_lines
