class AWARE_RscText
{
    access = 0;
    idc = -1;
    type = 0;
    style = 2;
    linespacing = 1;
    colorBackground[] = {0.4, 0.4, 0.4, 0.75};
    colorText[] = {1, 1, 1, 1};
    text = "";
    shadow = 0;
    font = "PuristaMedium";
    SizeEx = "0.024 * safezoneH";
};

class AWARE_RscStructuredText
{
    access = 0;
    idc = -1;
    type = 13;
    style = 0;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    text = "";
    size = "0.0185 * safezoneH";
    colorText[] = {1, 1, 1, 1};
    class Attributes
    {
        font = "PuristaMedium";
        color = "#FFFFFF";
        align = "left";
        valign = "top";
        shadow = 0;
        size = "1";
    };
};

class AWARE_RscControlsGroup
{
    access = 0;
    idc = -1;
    type = 15;
    style = 16;
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    shadow = 0;

    class VScrollbar
    {
        color[] = {1, 1, 1, 0.45};
        colorActive[] = {1, 1, 1, 0.8};
        colorDisabled[] = {1, 1, 1, 0.15};
        thumb = "#(argb,8,8,3)color(1,1,1,0.65)";
        arrowEmpty = "#(argb,8,8,3)color(1,1,1,0.25)";
        arrowFull = "#(argb,8,8,3)color(1,1,1,0.65)";
        border = "#(argb,8,8,3)color(0,0,0,0)";
        shadow = 0;
        scrollSpeed = 0.06;
        width = 0.012;
        autoScrollEnabled = 0;
        autoScrollSpeed = -1;
        autoScrollDelay = 5;
        autoScrollRewind = 0;
    };

    class HScrollbar
    {
        color[] = {1, 1, 1, 0};
        colorActive[] = {1, 1, 1, 0};
        colorDisabled[] = {1, 1, 1, 0};
        thumb = "#(argb,8,8,3)color(0,0,0,0)";
        arrowEmpty = "#(argb,8,8,3)color(0,0,0,0)";
        arrowFull = "#(argb,8,8,3)color(0,0,0,0)";
        border = "#(argb,8,8,3)color(0,0,0,0)";
        shadow = 0;
        height = 0;
        autoScrollEnabled = 0;
    };

    class Controls {};
};

class AWARE_MedicalSuggestionExtension
{
    idd = -1;
    movingEnable = 0;
    enableSimulation = 1;
    duration = 1e+011;
    fadeIn = 0;
    fadeOut = 0;
    onLoad = "uiNamespace setVariable ['AWARE_MedicalSuggestionExtension', _this select 0]";
    onUnload = "uiNamespace setVariable ['AWARE_MedicalSuggestionExtension', displayNull]";

    class controls
    {
        class AWARE_MedExtBackground : AWARE_RscText
        {
            idc = 5200;
            style = 16;
            text = "";
            x = "safezoneX + 0.02";
            y = "safezoneY + 0.23 * safezoneH";
            w = "0.46";
            h = "0.58 * safezoneH";
            colorBackground[] = {0.05, 0.05, 0.05, 0.9};
        };

        class AWARE_MedExtHeader : AWARE_RscText
        {
            idc = 5201;
            style = 2;
            text = "$STR_AWARE_MEDICAL_CHECKLIST";
            x = "safezoneX + 0.02";
            y = "safezoneY + 0.23 * safezoneH";
            w = "0.46";
            h = "0.034";
            colorBackground[] = {0.79, 0.48, 0.08, 0.95};
            SizeEx = "0.021 * safezoneH";
        };

        class AWARE_MedExtHint : AWARE_RscText
        {
            idc = 5203;
            style = 16;
            text = "";
            x = "safezoneX + 0.024";
            y = "safezoneY + 0.264 * safezoneH";
            w = "0.452";
            h = "0";
            colorBackground[] = {0, 0, 0, 0};
            SizeEx = "0.018 * safezoneH";
            colorText[] = {0.87, 0.87, 0.87, 1};
        };

        class AWARE_MedExtTab1 : AWARE_RscText
        {
            idc = 5204;
            style = 2;
            text = "$STR_AWARE_TAB_NOW";
            x = "safezoneX + 0.024";
            y = "safezoneY + 0.268 * safezoneH";
            w = "0.109";
            h = "0.028";
            colorBackground[] = {0.08, 0.08, 0.08, 0.92};
            SizeEx = "0.0175 * safezoneH";
        };

        class AWARE_MedExtTab2 : AWARE_MedExtTab1
        {
            idc = 5205;
            text = "$STR_AWARE_TAB_FIRST";
            x = "safezoneX + 0.139";
        };

        class AWARE_MedExtTab3 : AWARE_MedExtTab1
        {
            idc = 5206;
            text = "$STR_AWARE_TAB_TRANSPORT";
            x = "safezoneX + 0.254";
        };

        class AWARE_MedExtTab4 : AWARE_MedExtTab1
        {
            idc = 5207;
            text = "$STR_AWARE_TAB_RECHECK";
            x = "safezoneX + 0.369";
        };

        class AWARE_MedExtPageUp : AWARE_RscText
        {
            idc = 5208;
            style = 2;
            text = "$STR_AWARE_SCROLL_UP";
            x = "safezoneX + 0.024";
            y = "safezoneY + 0.778 * safezoneH";
            w = "0.218";
            h = "0.026";
            colorBackground[] = {0.08, 0.08, 0.08, 0.92};
            SizeEx = "0.0175 * safezoneH";
        };

        class AWARE_MedExtPageDown : AWARE_MedExtPageUp
        {
            idc = 5209;
            text = "$STR_AWARE_SCROLL_DOWN";
            x = "safezoneX + 0.258";
        };

        class AWARE_MedExtScrollGroup : AWARE_RscControlsGroup
        {
            idc = 5199;
            x = "safezoneX + 0.024";
            y = "safezoneY + 0.302 * safezoneH";
            w = "0.452";
            h = "0.501 * safezoneH";

            class Controls
            {
                class AWARE_MedExtBody : AWARE_RscStructuredText
                {
                    idc = 5202;
                    text = "";
                    x = 0;
                    y = 0;
                    w = 0.434;
                    h = "0.475";
                    colorBackground[] = {0, 0, 0, 0};
                    SizeEx = "0.0185 * safezoneH";
                };
            };
        };
    };
};
