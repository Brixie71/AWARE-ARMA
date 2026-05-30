/*
    Function: AWARE_fnc_init
    Runs after mission initialization.
*/

[] call AWARE_fnc_hello;
[] call AWARE_fnc_registerMedicalTreatmentTracking;
[] call AWARE_fnc_startMedicalSuggestions;

if (false) then {
    private _unused = [
        localize "STR_AWARE_MEDICAL_APPLIED",
        localize "STR_AWARE_MEDICAL_REQUIRED",
        localize "STR_AWARE_SCROLL_DOWN",
        localize "STR_AWARE_SCROLL_UP"
    ];
};
