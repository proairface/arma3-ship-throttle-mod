/*
 * Author: Olaf
 * Ship Throttle - fnc_onSettingsMenuLoad
 *
 * Called from the settings dialog's own onLoad (ui\SettingsMenu.hpp) -
 * the same "capture the display in onLoad" pattern already used by the
 * throttle HUD (ui\RscTitles.hpp), rather than looking it up later via
 * findDisplay/a fixed idd.
 *
 * Arguments:
 * 0: Settings dialog's display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_display"];

_display setVariable ["olk_captureMode", ""];

[_display] call olk_fnc_refreshSettingsMenu;

_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    [_display, _key, _ctrl] call olk_fnc_settingsMenuKeyDown;
    true
}];
