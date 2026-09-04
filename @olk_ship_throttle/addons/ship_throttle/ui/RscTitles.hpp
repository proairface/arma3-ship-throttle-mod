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
                // entirely). ST_LEFT = 0 is confirmed on the BI wiki and
                // is a safe baseline; actual centered alignment still
                // comes from the inline <t align='center'> tag in
                // fn_updateHud.sqf, independent of this value.
                style = 0; // ST_LEFT
                // Bottom-center, sized like a real vehicle instrument
                // readout rather than a small tucked-away corner label.
                x = "safezoneX + safezoneW / 2 - 0.08";
                y = "safezoneY + safezoneH - 0.12";
                w = 0.16;
                h = 0.07;
                // Soft cyan-white, closer to Arma's own vehicle HUD/
                // instrument text tone than plain white.
                colorText[] = {0.65, 1, 1, 1};
                colorBackground[] = {0, 0, 0, 0.45};
                // PuristaSemiBold is Arma 3's own UI font (confirmed via
                // a real community pilot-HUD mod's config) - an earlier
                // build guessed "RobotoCondensedBold" without checking.
                font = "PuristaSemiBold";
                size = 0.07;
                shadow = 1;
                text = "";
            };
        };
    };
};
