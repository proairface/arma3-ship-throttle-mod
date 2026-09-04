class CfgPatches
{
    class olk_ship_throttle
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.06;
        requiredAddons[] = {};
        author = "Olaf";
        authors[] = {"Olaf"};
        version = "0.3.5";
        versionStr = "0.3.5";
    };
};

class CfgFunctions
{
    class olk
    {
        class ship_throttle
        {
            file = "olk_ship_throttle\addons\ship_throttle\functions";
            class init { postInit = 1; };
            class keyDown {};
            class keyUp {};
            class setThrottle {};
            class adjustThrottle {};
            class onGetInMan {};
            class onGetOutMan {};
            class onGetInManEH {};
            class onGetOutManEH {};
            class onKilledEH {};
            class updateHud {};
        };
    };
};

// Config-level EventHandlers on the base "person" class fire for every
// unit (AI included) on every client - each dispatcher function filters
// down to "this is the local player" before doing anything. This is the
// vanilla (no-CBA) equivalent of a player-vehicle-change hook: it fires
// automatically for every mission, every respawn, without needing any
// runtime re-registration.
//
// IMPORTANT: the property names below (getInMan/getOutMan/killed) must
// be the *exact* recognized event names - vanilla config EventHandlers
// dispatch by that literal name, not by an arbitrary/addon-prefixed key.
// An earlier build used custom-prefixed names (olk_ship_throttle_*)
// thinking that made them collision-safe like CBA's XEH; the engine
// never recognized those as event handlers at all, so nothing fired.
// The real tradeoff this brings back: without XEH, only ONE handler per
// event name is allowed on a given class - if another non-CBA addon
// also defines getInMan/getOutMan/killed on CAManBase, whichever addon
// loads last silently wins. Not an issue with just this addon active.
//
// CAManBase's real parent is Man directly (confirmed against a real
// working mod's config.cpp: `class Man: Land {...}; class CAManBase: Man
// {...};`) - an earlier build incorrectly re-declared it as
// `class Civilian: Man {}; class CAManBase: Civilian {...}`, a parent
// that doesn't match the base game's actual class. Reopening an
// existing class with a mismatched parent is a real, documented Arma
// config problem (BI wiki/forums both describe it), so this was a
// second, independent bug on top of the EventHandlers-naming one above -
// possibly still masked by the postInit watchdog fallback, but wrong
// either way. Fixed to inherit directly from Man, matching the
// confirmed real hierarchy.
class CfgVehicles
{
    class Man;
    class CAManBase: Man
    {
        class EventHandlers
        {
            getInMan = "_this call olk_fnc_onGetInManEH";
            getOutMan = "_this call olk_fnc_onGetOutManEH";
            killed = "_this call olk_fnc_onKilledEH";
        };
    };
};

#include "ui\RscTitles.hpp"
