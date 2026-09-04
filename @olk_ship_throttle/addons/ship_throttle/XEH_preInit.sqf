/*
 * Ship Throttle - preInit.
 *
 * Registers the CBA setting that controls how reverse (negative)
 * throttle is applied. Defaults to true (try setCruiseControl with a
 * negative target speed) per the project's chosen design - see
 * README.md "Known risks - reverse throttle" for why this exists and
 * what to do if it turns out not to work in a live game test.
 */

[
    "olk_ship_throttle_reverseViaCruiseControl",
    "CHECKBOX",
    "Reverse via setCruiseControl (experimental)",
    "Ship Throttle",
    true
] call CBA_fnc_addSetting;
