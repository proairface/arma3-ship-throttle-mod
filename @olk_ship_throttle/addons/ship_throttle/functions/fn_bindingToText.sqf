#include "\a3\editor_f\Data\Scripts\dikCodes.h"

/*
 * Author: Olaf
 * Ship Throttle - fnc_bindingToText
 *
 * Renders a [key, ctrl] binding (see fn_keyDown.sqf) as human-readable
 * text for the settings menu, e.g. "Ctrl + W". Covers letters, digits,
 * and a handful of other common keys; anything else falls back to
 * "Key#<code>" rather than guessing a name.
 *
 * Arguments:
 * 0: Binding [key <NUMBER>, ctrl <BOOLEAN>] <ARRAY>
 *
 * Return Value:
 * Display text <STRING>
 *
 * Public: No
 */

params ["_binding"];
_binding params ["_key", "_ctrl"];

private _names = [
    [DIK_A, "A"], [DIK_B, "B"], [DIK_C, "C"], [DIK_D, "D"], [DIK_E, "E"],
    [DIK_F, "F"], [DIK_G, "G"], [DIK_H, "H"], [DIK_I, "I"], [DIK_J, "J"],
    [DIK_K, "K"], [DIK_L, "L"], [DIK_M, "M"], [DIK_N, "N"], [DIK_O, "O"],
    [DIK_P, "P"], [DIK_Q, "Q"], [DIK_R, "R"], [DIK_S, "S"], [DIK_T, "T"],
    [DIK_U, "U"], [DIK_V, "V"], [DIK_W, "W"], [DIK_X, "X"], [DIK_Y, "Y"],
    [DIK_Z, "Z"],
    [DIK_0, "0"], [DIK_1, "1"], [DIK_2, "2"], [DIK_3, "3"], [DIK_4, "4"],
    [DIK_5, "5"], [DIK_6, "6"], [DIK_7, "7"], [DIK_8, "8"], [DIK_9, "9"],
    [DIK_SPACE, "Space"], [DIK_TAB, "Tab"],
    [DIK_ADD, "Numpad +"], [DIK_SUBTRACT, "Numpad -"],
    [DIK_UP, "Up"], [DIK_DOWN, "Down"], [DIK_LEFT, "Left"], [DIK_RIGHT, "Right"]
];

private _idx = _names findIf {(_x select 0) == _key};
private _keyName = if (_idx == -1) then {format ["Key#%1", _key]} else {(_names select _idx) select 1};

if (_ctrl) then {
    format ["Ctrl + %1", _keyName]
} else {
    _keyName
}
