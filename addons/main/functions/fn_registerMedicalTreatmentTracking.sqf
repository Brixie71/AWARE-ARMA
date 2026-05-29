/*
    Function: AWARE_fnc_registerMedicalTreatmentTracking
    Records ACE treatment events on the patient for checklist display.
*/

if (!hasInterface) exitWith {};
if (missionNamespace getVariable ["AWARE_medicalTreatmentTrackingRegistered", false]) exitWith {};
if (isNil "CBA_fnc_addEventHandler") exitWith {};

missionNamespace setVariable ["AWARE_medicalTreatmentTrackingRegistered", true];
missionNamespace setVariable ["AWARE_fnc_recordAppliedMedicalItems", {
    params [
        ["_patient", objNull, [objNull]],
        ["_bodyPart", "", [""]],
        ["_treatments", [], [[]]]
    ];

    if (isNull _patient) exitWith {};

    private _appliedItems = _patient getVariable ["AWARE_appliedMedicalItems", []];
    if !(_appliedItems isEqualType []) then {
        _appliedItems = [];
    };

    private _itemsToRecord = [];
    {
        if (_x isEqualType "" && { _x isNotEqualTo "" }) then {
            _itemsToRecord pushBack _x;

            switch (toLower _x) do {
                case "fielddressing";
                case "ace_fielddressing";
                case "field dressing": {
                    _itemsToRecord append ["ACE_fieldDressing", "Field Dressing", "AWARE_BandageApplied"];
                };
                case "packingbandage";
                case "ace_packingbandage";
                case "packing bandage": {
                    _itemsToRecord append ["ACE_packingBandage", "Packing Bandage", "AWARE_BandageApplied"];
                };
                case "elasticbandage";
                case "ace_elasticbandage";
                case "elastic bandage": {
                    _itemsToRecord append ["ACE_elasticBandage", "Elastic Bandage", "AWARE_BandageApplied"];
                };
                case "quikclot";
                case "ace_quikclot": {
                    _itemsToRecord append ["ACE_quikclot", "QuikClot", "AWARE_BandageApplied"];
                };
                case "applytourniquet";
                case "tourniquet";
                case "ace_tourniquet": {
                    _itemsToRecord append ["ACE_tourniquet", "Tourniquet"];
                };
                case "splint";
                case "ace_splint": {
                    _itemsToRecord append ["ACE_splint", "Splint"];
                };
                case "chestseal";
                case "chest seal";
                case "kat_chestseal": {
                    _itemsToRecord append ["kat_chestSeal", "Chest Seal"];
                };
                case "painkillers";
                case "painkiller";
                case "ace_painkillers";
                case "ace_painkillers_item": {
                    _itemsToRecord append ["ACE_painkillers", "ACE_painkillers_Item", "Painkillers"];
                };
                case "morphine";
                case "ace_morphine": {
                    _itemsToRecord append ["ACE_morphine", "Morphine"];
                };
                case "bloodiv";
                case "bloodiv_500";
                case "bloodiv_250";
                case "plasmaiv";
                case "plasmaiv_500";
                case "plasmaiv_250";
                case "salineiv";
                case "salineiv_500";
                case "salineiv_250";
                case "ace_bloodiv";
                case "ace_bloodiv_500";
                case "ace_bloodiv_250";
                case "ace_plasmaiv";
                case "ace_plasmaiv_500";
                case "ace_plasmaiv_250";
                case "ace_salineiv";
                case "ace_salineiv_500";
                case "ace_salineiv_250": {
                    _itemsToRecord append ["AWARE_IVApplied", "IV Fluid / Blood Product", "Blood Transfusion"];
                };
                default {
                    if ((toLower _x) find "kat_bloodiv" == 0) then {
                        _itemsToRecord append ["AWARE_IVApplied", "IV Fluid / Blood Product", "Blood Transfusion"];
                    };
                };
            };
        };
    } forEach _treatments;

    private _bodyPartKey = toLower _bodyPart;
    if (_bodyPartKey isNotEqualTo "") then {
        {
            if (_x isEqualType "" && { _x isNotEqualTo "" }) then {
                _itemsToRecord pushBack format ["%1:%2", _x, _bodyPartKey];
            };
        } forEach +_itemsToRecord;
    };

    {
        if (_x isEqualType "" && { _x isNotEqualTo "" } && { !(_x in _appliedItems) }) then {
            _appliedItems pushBack _x;
        };
    } forEach _itemsToRecord;

    _patient setVariable ["AWARE_appliedMedicalItems", _appliedItems, true];
}];

["ace_medical_treatment_bandaged", {
    params [
        ["_medic", objNull, [objNull]],
        ["_patient", objNull, [objNull]],
        ["_bodyPart", "", [""]],
        ["_treatment", "", [""]],
        ["_itemUser", objNull, [objNull]],
        ["_usedItem", "", [""]]
    ];

    [_patient, _bodyPart, [_treatment, _usedItem]] call (missionNamespace getVariable ["AWARE_fnc_recordAppliedMedicalItems", {}]);
}] call CBA_fnc_addEventHandler;

["ace_treatmentSucceded", {
    params [
        ["_caller", objNull, [objNull]],
        ["_target", objNull, [objNull]],
        ["_selectionName", "", [""]],
        ["_className", "", [""]],
        ["_itemUser", objNull, [objNull]],
        ["_usedItem", "", [""]],
        ["_createLitter", true, [true]]
    ];

    [_target, _selectionName, [_className, _usedItem]] call (missionNamespace getVariable ["AWARE_fnc_recordAppliedMedicalItems", {}]);
}] call CBA_fnc_addEventHandler;
