/*
    Function: AWARE_fnc_vrHello
    Shows a visible sample message for the bundled VR test mission.
*/

if (!hasInterface) exitWith {};

[] spawn {
    waitUntil { !isNull player };
    waitUntil { time > 0 };

    hint "Hello world from AWARE in Virtual Reality.";
    systemChat "[AWARE] Hello world from VR.";

    [
        "<t size='2.2' color='#49C7F2'>AWARE</t><br/><t size='1.3'>Hello world in Virtual Reality</t>",
        0,
        0.35,
        5,
        1,
        0,
        9001
    ] spawn BIS_fnc_dynamicText;
};
