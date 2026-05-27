/*
    Function: AWARE_fnc_getMedicInventoryItems
    Returns item classnames available to the medic from worn gear and assigned items.
*/

params [
    ["_medic", objNull, [objNull]]
];

if (isNull _medic) exitWith { [] };

(items _medic)
    + (assignedItems _medic)
    + (uniformItems _medic)
    + (vestItems _medic)
    + (backpackItems _medic)
    + (magazines _medic)
