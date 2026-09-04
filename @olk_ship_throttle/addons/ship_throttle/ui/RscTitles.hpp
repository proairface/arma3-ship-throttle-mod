class RscTitles
{
    class olk_ship_throttle_hud
    {
        idd = -1;
        duration = 1e9;
        fadeIn = 0;
        fadeOut = 0;
        name = "olk_ship_throttle_hud";
        onLoad = "uiNamespace setVariable ['olk_ship_throttle_display', (_this select 0)]; [(vehicle player), ((vehicle player) getVariable ['olk_throttlePct', 0])] call olk_fnc_updateHud;";
        class controlsBackground {};
        class objects {};
        class controls
        {
            class olk_throttle_text
            {
                idc = 62100;
                type = 13; // CT_STRUCTURED_TEXT (confirmed on BI wiki)
                // `style` turned out to be a REQUIRED config entry for
                // this control (confirmed by an in-game "No entry
                // ...style" error after a previous build omitted it
                // entirely, thinking it was redundant/unverified - that
                // was a mistake, removing a required field is worse than
                // guessing its value). ST_LEFT = 0 is confirmed on the BI
                // wiki and is a safe baseline; actual right-alignment
                // still comes from the inline <t align='right'> tag in
                // fn_updateHud.sqf, independent of this value.
                style = 0; // ST_LEFT
                x = "safezoneX + safezoneW - 0.16";
                y = "safezoneY + safezoneH - 0.06";
                w = 0.14;
                h = 0.045;
                colorText[] = {1, 1, 1, 1};
                colorBackground[] = {0, 0, 0, 0.35};
                font = "RobotoCondensedBold";
                size = 0.04;
                shadow = 1;
                text = "";
            };
        };
    };
};
