/*
    Function: AWARE_fnc_getBodyPartDamage
    Returns average damage for the first matching hitpoint names.
*/

params ["_unit", "_hitpointCandidates"];

if (isNull _unit) exitWith { 0 };
if (_hitpointCandidates isEqualTo []) exitWith { damage _unit };

private _hitData = getAllHitPointsDamage _unit;
if (_hitData isEqualTo [] || { (count _hitData) < 3 }) exitWith { damage _unit };

private _hitpointNames = _hitData param [0, []];
private _selectionNames = _hitData param [1, []];
private _hitpointDamages = _hitData param [2, []];
private _hitpointNamesLower = _hitpointNames apply { toLower _x };
private _selectionNamesLower = _selectionNames apply { toLower _x };
private _candidateNamesLower = _hitpointCandidates apply { toLower _x };
private _sum = 0;
private _count = 0;

{
    private _index = _hitpointNamesLower find _x;
    if (_index < 0) then {
        _index = _selectionNamesLower find _x;
    };

    if (_index > -1) then {
        _sum = _sum + (_hitpointDamages param [_index, 0]);
        _count = _count + 1;
    };
} forEach _candidateNamesLower;

if (_count == 0) exitWith { damage _unit };

(_sum / _count) max 0 min 1
