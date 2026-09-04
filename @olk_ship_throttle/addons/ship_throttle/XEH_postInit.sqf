/*
 * Ship Throttle - postInit.
 *
 * Hooks the local player's vehicle changes to drive the throttle
 * HUD/cruise control, and registers the throttle keybinds (unbound by
 * default - configure them in Arma 3 Options > Controls > Configure
 * Addons > Ship Throttle).
 *
 * Uses CBA's "vehicle" player event rather than "GetInMan"/"GetOutMan" -
 * those aren't real CBA_fnc_addPlayerEventHandler event names (checked
 * against CBA_A3's current source/wiki); "vehicle" fires whenever the
 * player's occupied vehicle changes and covers both getting in and out.
 * Switching seats within the *same* vehicle (e.g. driver -> gunner)
 * doesn't fire "vehicle", so that case is instead caught by the
 * per-frame watch loop started in fnc_onGetInMan.
 */

["vehicle", {
    params ["_unit", "_vehicle", "_previousVehicle"];

    if (_unit != player) exitWith {};

    if (_vehicle isKindOf "Ship" && {driver _vehicle == player}) then {
        [_vehicle] call olk_fnc_onGetInMan;
    } else {
        if (_previousVehicle isKindOf "Ship") then {
            [_previousVehicle] call olk_fnc_onGetOutMan;
        };
    };
}, true] call CBA_fnc_addPlayerEventHandler;

["olk_ship_throttle", "IncreaseThrottle", "Increase Ship Throttle (+10%)",
    {
        private _handled = (vehicle player) isKindOf "Ship" && {driver (vehicle player) == player};
        if (_handled) then { [10] call olk_fnc_adjustThrottle; };
        _handled
    },
    { false }
] call CBA_fnc_addKeybind;

["olk_ship_throttle", "DecreaseThrottle", "Decrease Ship Throttle (-10%)",
    {
        private _handled = (vehicle player) isKindOf "Ship" && {driver (vehicle player) == player};
        if (_handled) then { [-10] call olk_fnc_adjustThrottle; };
        _handled
    },
    { false }
] call CBA_fnc_addKeybind;

["olk_ship_throttle", "IncreaseThrottleFine", "Increase Ship Throttle, fine (+1%)",
    {
        private _handled = (vehicle player) isKindOf "Ship" && {driver (vehicle player) == player};
        if (_handled) then { [1] call olk_fnc_adjustThrottle; };
        _handled
    },
    { false }
] call CBA_fnc_addKeybind;

["olk_ship_throttle", "DecreaseThrottleFine", "Decrease Ship Throttle, fine (-1%)",
    {
        private _handled = (vehicle player) isKindOf "Ship" && {driver (vehicle player) == player};
        if (_handled) then { [-1] call olk_fnc_adjustThrottle; };
        _handled
    },
    { false }
] call CBA_fnc_addKeybind;
