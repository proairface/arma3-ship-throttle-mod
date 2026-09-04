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
                // No `style` constant here - alignment is set inline via
                // the <t align='right'> tag in fn_updateHud.sqf's text
                // instead, avoiding an unverified ST_* numeric guess.
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
