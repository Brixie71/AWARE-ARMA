class AWARE_RscText
{
    access = 0;
    idc = -1;
    type = 0;
    style = 2;
    linespacing = 1;
    colorBackground[] = {0.96, 0.94, 0.88, 0.92}; // Cream milk
    colorText[] = {0.35, 0.35, 0.38, 1}; // Pencil gray
    text = "";
    shadow = 0;
    font = "PuristaMedium";
    SizeEx = "0.022 * safezoneH";
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
    colorText[] = {0.35, 0.35, 0.38, 1}; // Pencil gray
    class Attributes
    {
        font = "PuristaMedium";
        color = "#5a5a60";
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
        color[] = {0.5, 0.5, 0.5, 0.35};
        colorActive[] = {0.79, 0.48, 0.08, 0.7};
        colorDisabled[] = {0.5, 0.5, 0.5, 0.15};
        thumb = "#(argb,8,8,3)color(0.35,0.35,0.38,0.55)";
        arrowEmpty = "#(argb,8,8,3)color(0.35,0.35,0.38,0.25)";
        arrowFull = "#(argb,8,8,3)color(0.35,0.35,0.38,0.55)";
        border = "#(argb,8,8,3)color(0,0,0,0)";
        shadow = 0;
        scrollSpeed = 0.06;
        width = 0.008;
        autoScrollEnabled = 0;
        autoScrollSpeed = -1;
        autoScrollDelay = 5;
        autoScrollRewind = 0;
    };

    class HScrollbar
    {
        color[] = {0.5, 0.5, 0.5, 0};
        colorActive[] = {0.5, 0.5, 0.5, 0};
        colorDisabled[] = {0.5, 0.5, 0.5, 0};
        thumb = "#(argb,8,8,3)color(0,0,0,0)";
        arrowEmpty = "#(argb,8,8,3)color(0,0,0,0)";
        arrowFull = "#(argb,8,8,3)color(0,0,0,0)";
        border = "#(argb,8,8,3)color(0,0,0,0)";
        shadow = 0;
        height = 0;
        autoScrollEnabled = 0;
    };
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
        class AWARE_MedExtShadow : AWARE_RscText
        {
            idc = 5206;
            style = 16;
            text = "";
            x = "safezoneX + 0.022";
            y = "safezoneY + 0.202 * safezoneH";
            w = "0.42";
            h = "0.52 * safezoneH";
            colorBackground[] = {0, 0, 0, 0.08};
        };

        class AWARE_MedExtBackground : AWARE_RscText
        {
            idc = 5200;
            style = 16;
            text = "";
            x = "safezoneX + 0.02";
            y = "safezoneY + 0.23 * safezoneH";
            w = "0.42";
            h = "0.52 * safezoneH";
            colorBackground[] = {0.97, 0.95, 0.90, 0.94};
            shadow = 1;
        };

        class AWARE_MedExtHeader : AWARE_RscText
        {
            idc = 5201;
            style = 2;
            text = "$STR_AWARE_MEDICAL_CHECKLIST";
            x = "safezoneX + 0.02";
            y = "safezoneY + 0.23 * safezoneH";
            w = "0.42";
            h = "0.038";
            colorBackground[] = {0.85, 0.70, 0.45, 0.95};
            colorText[] = {0.25, 0.23, 0.20, 1};
            SizeEx = "0.022 * safezoneH";
            shadow = 0;
        };

        class AWARE_MedExtHint : AWARE_RscText
        {
            idc = 5203;
            style = 16;
            text = "";
            x = "safezoneX + 0.026";
            y = "safezoneY + 0.272 * safezoneH";
            w = "0.408";
            h = "0";
            colorBackground[] = {0, 0, 0, 0};
            SizeEx = "0.016 * safezoneH";
            colorText[] = {0.5, 0.48, 0.44, 0.9};
        };

        class AWARE_MedExtTab1 : AWARE_RscText
        {
            idc = 5204;
            style = 2;
            text = "$STR_AWARE_TAB_NOW";
            x = "safezoneX + 0.026";
            y = "safezoneY + 0.272 * safezoneH";
            w = "0.195";
            h = "0.030";
            colorBackground[] = {0.93, 0.90, 0.84, 0.95};
            colorText[] = {0.35, 0.35, 0.38, 1};
            SizeEx = "0.0175 * safezoneH";
            shadow = 0;
        };

        class AWARE_MedExtTab2 : AWARE_MedExtTab1
        {
            idc = 5205;
            text = "$STR_AWARE_TAB_RECHECK";
            x = "safezoneX + 0.229";
            colorBackground[] = {0.93, 0.90, 0.84, 0.95};
        };

        class AWARE_MedExtSeparator : AWARE_RscText
        {
            idc = 5207;
            style = 16;
            text = "";
            x = "safezoneX + 0.024";
            y = "safezoneY + 0.304 * safezoneH";
            w = "0.412";
            h = "0.0015";
            colorBackground[] = {0.7, 0.6, 0.45, 0.5};
        };

        class AWARE_MedExtPageUp : AWARE_RscText
        {
            idc = 5208;
            style = 2;
            text = "▲ $STR_AWARE_SCROLL_UP";
            x = "safezoneX + 0.026";
            y = "safezoneY + 0.71 * safezoneH";
            w = "0.195";
            h = "0.028";
            colorBackground[] = {0.93, 0.90, 0.84, 0.92};
            colorText[] = {0.35, 0.35, 0.38, 1};
            SizeEx = "0.016 * safezoneH";
            shadow = 0;
        };

        class AWARE_MedExtPageDown : AWARE_MedExtPageUp
        {
            idc = 5209;
            text = "▼ $STR_AWARE_SCROLL_DOWN";
            x = "safezoneX + 0.229";
        };

        class AWARE_MedExtScrollGroup : AWARE_RscControlsGroup
        {
            idc = 5199;
            x = "safezoneX + 0.026";
            y = "safezoneY + 0.308 * safezoneH";
            w = "0.408";
            h = "0.398 * safezoneH";

            class Controls
            {
                class AWARE_MedExtBody : AWARE_RscStructuredText
                {
                    idc = 5202;
                    text = "";
                    x = 0;
                    y = 0;
                    w = 0.392;
                    h = 0.38;
                    colorBackground[] = {0, 0, 0, 0};
                    size = "0.018 * safezoneH";
                };
            };
        };
    };
};
