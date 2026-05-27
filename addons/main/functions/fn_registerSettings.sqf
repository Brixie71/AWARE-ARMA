/*
    Function: AWARE_fnc_registerSettings
    Registers CBA Addon Options for the AWARE medical checklist panel.
*/

if (isNil "CBA_fnc_addSetting") exitWith {};

[
    "AWARE_medicalSuggestions_enabled",
    "CHECKBOX",
    [localize "STR_AWARE_SETTING_ENABLE_CHECKLIST", localize "STR_AWARE_SETTING_ENABLE_CHECKLIST_DESC"],
    ["AWARE", localize "STR_AWARE_CATEGORY_MEDICAL_CHECKLIST"],
    true,
    0,
    {
        params ["_value"];

        if (!_value) then {
            uiNamespace setVariable ["AWARE_MedicalSuggestionsVisible", false];
            [false] call AWARE_fnc_renderMedicalSuggestions;
        };
    },
    false
] call CBA_fnc_addSetting;

[
    "AWARE_medicalSuggestions_autoShow",
    "CHECKBOX",
    [localize "STR_AWARE_SETTING_AUTO_SHOW", localize "STR_AWARE_SETTING_AUTO_SHOW_DESC"],
    ["AWARE", localize "STR_AWARE_CATEGORY_MEDICAL_CHECKLIST"],
    true,
    0,
    {},
    false
] call CBA_fnc_addSetting;

[
    "AWARE_medicalSuggestions_draggable",
    "CHECKBOX",
    [localize "STR_AWARE_SETTING_ALLOW_DRAGGING", localize "STR_AWARE_SETTING_ALLOW_DRAGGING_DESC"],
    ["AWARE", localize "STR_AWARE_CATEGORY_MEDICAL_CHECKLIST"],
    true,
    0,
    {},
    false
] call CBA_fnc_addSetting;

[
    "AWARE_medicalSuggestions_scale",
    "SLIDER",
    [localize "STR_AWARE_SETTING_UI_SCALE", localize "STR_AWARE_SETTING_UI_SCALE_DESC"],
    ["AWARE", localize "STR_AWARE_CATEGORY_MEDICAL_CHECKLIST"],
    [0.85, 1.25, 1, 2],
    0,
    {
        params ["_value"];

        if (uiNamespace getVariable ["AWARE_MedicalSuggestionsVisible", false]) then {
            [true] call AWARE_fnc_renderMedicalSuggestions;
        };
    },
    false
] call CBA_fnc_addSetting;
