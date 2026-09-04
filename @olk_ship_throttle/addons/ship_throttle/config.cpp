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
        version = "0.2.0";
        versionStr = "0.2.0";
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
class CfgVehicles
{
    class Man;
    class Civilian: Man {};
    class CAManBase: Civilian
    {
        class EventHandlers
        {
            olk_ship_throttle_getInMan = "_this call olk_fnc_onGetInManEH";
            olk_ship_throttle_getOutMan = "_this call olk_fnc_onGetOutManEH";
            olk_ship_throttle_killed = "_this call olk_fnc_onKilledEH";
        };
    };
};

#include "ui\RscTitles.hpp"
