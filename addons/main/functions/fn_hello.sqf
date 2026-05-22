/*
    Function: AWARE_fnc_hello
    Basic load confirmation for the starter addon.
*/

diag_log "[AWARE] Main addon loaded.";

if (hasInterface) then {
    [] spawn {
        waitUntil { !isNull player };
        systemChat "AWARE mod loaded.";
    };
};
