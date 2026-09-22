#include "\a3\editor_f\Data\Scripts\dikCodes.h"

/*
 * Author: Olaf
 * Ship Throttle - fnc_settingsMenuKeyDown
 *
 * Handles every keypress while the settings dialog (olk_ship_throttle_settings)
 * has focus. Two modes, tracked via the display's own "olk_captureMode"
 * variable (""/"increase"/"decrease"):
 *
 *  - Idle: "1"/"2" starts capturing a new binding for that action; Esc
 *    closes the dialog.
 *  - Capturing: the *next* key pressed (any key, with its Ctrl state)
 *    becomes the new binding for that action, saved to profileNamespace
 *    immediately; Esc cancels the capture without changing anything.
 *
 * Arguments:
 * 0: Settings dialog's display <DISPLAY>
 * 1: DIK key code <NUMBER>
 * 2: Ctrl held <BOOLEAN>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_display", "_key", "_ctrl"];

private _captureMode = _display getVariable ["olk_captureMode", ""];

if (_captureMode != "") then {
    if (_key != DIK_ESCAPE) then {
        private _varName = if (_captureMode == "increase") then {
            "olk_ship_throttle_increaseKey"
        } else {
            "olk_ship_throttle_decreaseKey"
        };
        profileNamespace setVariable [_varName, [_key, _ctrl]];
        saveProfileNamespace;
    };

    _display setVariable ["olk_captureMode", ""];
    [_display] call olk_fnc_refreshSettingsMenu;
} else {
    if (_key == DIK_ESCAPE) exitWith { closeDialog 0; };

    if (_key == DIK_1) then {
        _display setVariable ["olk_captureMode", "increase"];
        [_display] call olk_fnc_refreshSettingsMenu;
    };
    if (_key == DIK_2) then {
        _display setVariable ["olk_captureMode", "decrease"];
        [_display] call olk_fnc_refreshSettingsMenu;
    };
};
