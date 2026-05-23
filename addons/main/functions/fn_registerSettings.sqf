/*
    Function: AWARE_fnc_registerSettings
    Registers CBA Addon Options for the AWARE KAT medical suggestion panel.
*/

if (isNil "CBA_fnc_addSetting") exitWith {};

[
    "AWARE_medicalSuggestions_enabled",
    "CHECKBOX",
    ["Enable Suggestions", "Shows the AWARE KAT medical suggestion panel with the ACE/KAT medical menu."],
    ["AWARE", "KAT Medical Suggestions"],
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
    ["Auto Show With Medical Menu", "Automatically opens the suggestion panel when the ACE/KAT medical menu opens."],
    ["AWARE", "KAT Medical Suggestions"],
    true,
    0,
    {},
    false
] call CBA_fnc_addSetting;

[
    "AWARE_medicalSuggestions_draggable",
    "CHECKBOX",
    ["Allow Dragging", "Allows the suggestion panel to be dragged while the medical menu is open."],
    ["AWARE", "KAT Medical Suggestions"],
    true,
    0,
    {},
    false
] call CBA_fnc_addSetting;

[
    "AWARE_medicalSuggestions_scale",
    "SLIDER",
    ["UI Scale", "Scales the suggestion panel size."],
    ["AWARE", "KAT Medical Suggestions"],
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
