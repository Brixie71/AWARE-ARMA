/*
    Function: AWARE_fnc_registerSettings
    Registers CBA Addon Options for the AWARE medical checklist panel.
*/

if (isNil "CBA_fnc_addSetting") exitWith {};

[
    "AWARE_bodyIndicator_enabled",
    "CHECKBOX",
    ["Enable AWARE BODY", "Shows or hides the AWARE BODY status panel."],
    ["AWARE", "Body Indicator"],
    true,
    0,
    {
        params ["_value"];

        if (!_value && { !isNil "AWARE_fnc_setBodyIndicatorVisible" }) then {
            private _display = uiNamespace getVariable ["AWARE_BodyIndicator", displayNull];
            if (!isNull _display) then {
                [_display, false] call AWARE_fnc_setBodyIndicatorVisible;
            };
        };
    },
    false
] call CBA_fnc_addSetting;

[
    "AWARE_bodyIndicator_visibility",
    "LIST",
    ["AWARE BODY Visibility", "Controls whether AWARE BODY is always visible or only visible while the medical menu is open."],
    ["AWARE", "Body Indicator"],
    [[0, 1], ["Always On", "Medical Menu Only"], 0],
    0,
    {},
    false
] call CBA_fnc_addSetting;

[
    "AWARE_medicalSuggestions_enabled",
    "CHECKBOX",
    ["Enable Checklist", "Shows the AWARE medical checklist panel with the medical menu."],
    ["AWARE", "Medical Checklist"],
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
    ["Auto Show With Medical Menu", "Automatically opens the checklist panel when the medical menu opens."],
    ["AWARE", "Medical Checklist"],
    true,
    0,
    {},
    false
] call CBA_fnc_addSetting;

[
    "AWARE_medicalSuggestions_draggable",
    "CHECKBOX",
    ["Allow Dragging", "Allows the checklist panel to be dragged while the medical menu is open."],
    ["AWARE", "Medical Checklist"],
    true,
    0,
    {},
    false
] call CBA_fnc_addSetting;

[
    "AWARE_medicalSuggestions_scale",
    "SLIDER",
    ["UI Scale", "Scales the checklist panel size."],
    ["AWARE", "Medical Checklist"],
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
