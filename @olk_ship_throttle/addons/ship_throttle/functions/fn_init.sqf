/*
 * Author: Olaf
 * Ship Throttle - fnc_init (CfgFunctions postInit = 1)
 *
 * Runs once, automatically, at the start of every mission (vanilla
 * CfgFunctions postInit mechanism - no CBA XEH needed). Starts two
 * independent spawned loops:
 *
 *  1. Registers the throttle keybind handler on the main game display.
 *  2. A 1s watchdog that starts throttle tracking whenever the local
 *     player is found driving a Ship - regardless of whether the
 *     GetInMan config EventHandler fired. This is defense-in-depth: an
 *     earlier build had a config.cpp bug (custom EventHandlers property
 *     names instead of the engine-recognized getInMan/getOutMan/killed)
 *     that made those handlers silently never fire at all, and the mod
 *     behaved exactly like vanilla with no error. This watchdog means a
 *     similar future mistake fails soft (throttle control starts up to
 *     ~1s late) instead of "the mod does nothing."
 *
 * Both run in their own `spawn` scope so a problem in one (e.g.
 * findDisplay 46 never appearing) can't block the other, and so
 * postInit itself returns immediately rather than risking a suspend
 * command inside postInit's own semi-scheduled context (BI forums flag
 * this as capable of stalling mission load in some cases).
 *
 * There's no in-game "Configure Addons" rebind menu without CBA - see
 * fn_keyDown.sqf / README.md "Keybinds" for the hardcoded defaults and
 * how to change them.
 *
 * Arguments:
 * 0: "postInit" <STRING>
 * 1: didJIP <BOOLEAN>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

// TEMPORARY DIAGNOSTIC BREADCRUMBS (systemChat) - remove once the mod is
// confirmed working end to end. Each one pinpoints how far execution got.
systemChat "[ShipThrottle] postInit started";

[] spawn {
    private _display = displayNull;
    waitUntil { !isNull (_display = findDisplay 46) };

    _display displayAddEventHandler ["KeyDown", {
        params ["_display", "_key", "_shift"];
        [_key, _shift] call olk_fnc_keyDown
    }];

    _display displayAddEventHandler ["KeyUp", {
        params ["_display", "_key"];
        [_key] call olk_fnc_keyUp
    }];

    systemChat "[ShipThrottle] keybind handler registered";
};

[] spawn {
    systemChat "[ShipThrottle] watchdog loop started";

    while {true} do {
        private _veh = vehicle player;
        private _shouldBeDriving = !isNull player && {_veh isKindOf "Ship"} && {driver _veh == player};
        private _isWatching = !isNull _veh && {_veh getVariable ["olk_watching", false]};

        if (_shouldBeDriving && !_isWatching) then {
            systemChat "[ShipThrottle] watchdog detected ship driver -> starting throttle";
            [_veh] call olk_fnc_onGetInMan;
        };

        sleep 1;
    };
};
