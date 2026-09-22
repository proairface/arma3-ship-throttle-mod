/*
 * Ship Throttle settings dialog - keyboard-only (no CT_BUTTON), reusing
 * only the CT_STRUCTURED_TEXT control type/property set already proven
 * to work correctly for the HUD in RscTitles.hpp. See
 * fn_onSettingsMenuLoad.sqf / fn_settingsMenuKeyDown.sqf for the
 * interaction logic. A bare top-level class (not nested under a
 * "Dialogs" wrapper) is sufficient for createDialog to find it - it
 * searches configFile directly by class name.
 */
class olk_ship_throttle_settings
{
    idd = -1;
    movingEnable = 1;
    enableSimulation = 1;
    onLoad = "[(_this select 0)] call olk_fnc_onSettingsMenuLoad";
    class controlsBackground {};
    class objects {};
    class controls
    {
        class olk_settings_title
        {
            idc = 62200;
            type = 13; // CT_STRUCTURED_TEXT
            style = 0; // ST_LEFT - required entry; alignment set inline instead
            x = "safezoneX + safezoneW / 2 - 0.15";
            y = "safezoneY + safezoneH / 2 - 0.12";
            w = 0.3;
            h = 0.04;
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0, 0, 0, 0.6};
            font = "PuristaSemiBold";
            size = 0.035;
            shadow = 1;
            text = "<t align='center'>Ship Throttle Settings</t>";
        };
        class olk_settings_increase
        {
            idc = 62201;
            type = 13;
            style = 0;
            x = "safezoneX + safezoneW / 2 - 0.15";
            y = "safezoneY + safezoneH / 2 - 0.06";
            w = 0.3;
            h = 0.04;
            colorText[] = {0.65, 1, 1, 1};
            colorBackground[] = {0, 0, 0, 0.6};
            font = "PuristaSemiBold";
            size = 0.03;
            shadow = 1;
            text = "";
        };
        class olk_settings_decrease
        {
            idc = 62202;
            type = 13;
            style = 0;
            x = "safezoneX + safezoneW / 2 - 0.15";
            y = "safezoneY + safezoneH / 2 - 0.01";
            w = 0.3;
            h = 0.04;
            colorText[] = {0.65, 1, 1, 1};
            colorBackground[] = {0, 0, 0, 0.6};
            font = "PuristaSemiBold";
            size = 0.03;
            shadow = 1;
            text = "";
        };
        class olk_settings_footer
        {
            idc = 62203;
            type = 13;
            style = 0;
            x = "safezoneX + safezoneW / 2 - 0.15";
            y = "safezoneY + safezoneH / 2 + 0.05";
            w = 0.3;
            h = 0.06;
            colorText[] = {0.8, 0.8, 0.8, 1};
            colorBackground[] = {0, 0, 0, 0.4};
            font = "PuristaSemiBold";
            size = 0.022;
            shadow = 1;
            text = "";
        };
    };
};
