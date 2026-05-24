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

class AWARE_BodyIndicator
{
    idd = -1;
    movingEnable = 0;
    enableSimulation = 1;
    duration = 1e+011;
    fadeIn = 0;
    fadeOut = 0;
    onLoad = "uiNamespace setVariable ['AWARE_BodyIndicator', _this select 0]";
    onUnload = "uiNamespace setVariable ['AWARE_BodyIndicator', displayNull]";

    class controls
    {
        class AWARE_Header : AWARE_RscText
        {
            idc = 5100;
            style = 2;
            text = "AWARE BODY";
            x = "safezoneX + safezoneW - 0.355";
            y = "safezoneY + 0.28 * safezoneH";
            w = "0.325";
            h = "0.034";
            colorBackground[] = {0.12, 0.12, 0.12, 0.85};
        };

        class AWARE_BodyScrollGroup : AWARE_RscControlsGroup
        {
            idc = 5099;
            x = "safezoneX + safezoneW - 0.355";
            y = "safezoneY + 0.32 * safezoneH";
            w = "0.325";
            h = "0.48 * safezoneH";

            class Controls
            {
                class AWARE_Head : AWARE_RscText
                {
                    idc = 5101;
                    style = 16;
                    text = "Head";
                    onMouseEnter = "_this call AWARE_fnc_onBodyPartHover";
                    onMouseExit = "_this call AWARE_fnc_onBodyPartHoverExit";
                    x = 0;
                    y = 0;
                    w = 0.31;
                    h = "0.056";
                    SizeEx = "0.020 * safezoneH";
                };

                class AWARE_Torso : AWARE_Head
                {
                    idc = 5102;
                    text = "Torso";
                };

                class AWARE_LeftHand : AWARE_Head
                {
                    idc = 5103;
                    text = "Left Hand";
                };

                class AWARE_RightHand : AWARE_Head
                {
                    idc = 5104;
                    text = "Right Hand";
                };

                class AWARE_LeftLeg : AWARE_Head
                {
                    idc = 5105;
                    text = "Left Leg";
                };

                class AWARE_RightLeg : AWARE_Head
                {
                    idc = 5106;
                    text = "Right Leg";
                };

                class AWARE_Unconscious : AWARE_RscText
                {
                    idc = 5108;
                    style = 2;
                    text = "UNCONSCIOUS";
                    x = 0;
                    y = 0;
                    w = 0.31;
                    h = "0.034";
                    colorBackground[] = {0.82, 0.58, 0.12, 0.9};
                };

                class AWARE_Dead : AWARE_RscText
                {
                    idc = 5107;
                    style = 2;
                    text = "DEAD";
                    x = 0;
                    y = 0;
                    w = 0.31;
                    h = "0.034";
                    colorBackground[] = {0.72, 0.08, 0.08, 0.9};
                };
            };
        };

        class AWARE_DetailDropdown : AWARE_RscText
        {
            idc = 5110;
            style = 16;
            text = "";
            x = "safezoneX + safezoneW - 0.355";
            y = "safezoneY + 0.53 * safezoneH";
            w = "0.325";
            h = "0.13";
            colorBackground[] = {0.05, 0.05, 0.05, 0.92};
            SizeEx = "0.020 * safezoneH";
        };

        class AWARE_DetailRow1 : AWARE_RscText
        {
            idc = 5111;
            style = 16;
            text = "";
            x = "safezoneX + safezoneW - 0.351";
            y = "safezoneY + 0.533 * safezoneH";
            w = "0.317";
            h = "0.021";
            colorBackground[] = {0, 0, 0, 0};
            SizeEx = "0.020 * safezoneH";
        };

        class AWARE_DetailRow2 : AWARE_DetailRow1
        {
            idc = 5112;
        };

        class AWARE_DetailRow3 : AWARE_DetailRow1
        {
            idc = 5113;
        };

        class AWARE_DetailRow4 : AWARE_DetailRow1
        {
            idc = 5114;
        };

        class AWARE_DetailRow5 : AWARE_DetailRow1
        {
            idc = 5115;
        };

        class AWARE_DetailRow6 : AWARE_DetailRow1
        {
            idc = 5116;
        };

        class AWARE_DetailRow7 : AWARE_DetailRow1
        {
            idc = 5117;
        };

        class AWARE_DetailRow8 : AWARE_DetailRow1
        {
            idc = 5118;
        };

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
            text = "AWARE MEDICAL CHECKLIST";
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
            text = "1 BODY";
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
            text = "2 PRIORITY";
            x = "safezoneX + 0.139";
        };

        class AWARE_MedExtTab3 : AWARE_MedExtTab1
        {
            idc = 5206;
            text = "3 ITEMS";
            x = "safezoneX + 0.254";
        };

        class AWARE_MedExtTab4 : AWARE_MedExtTab1
        {
            idc = 5207;
            text = "4 RECHECK";
            x = "safezoneX + 0.369";
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
