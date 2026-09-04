class CfgPatches
{
    class olk_ship_throttle
    {
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.06;
        requiredAddons[] = {"CBA_A3"};
        author = "Olaf";
        authors[] = {"Olaf"};
        version = "0.1.0";
        versionStr = "0.1.0";
    };
};

class CfgFunctions
{
    class olk
    {
        class ship_throttle
        {
            file = "olk_ship_throttle\addons\ship_throttle\functions";
            class setThrottle {};
            class adjustThrottle {};
            class onGetInMan {};
            class onGetOutMan {};
            class updateHud {};
        };
    };
};

#include "ui\RscTitles.hpp"
