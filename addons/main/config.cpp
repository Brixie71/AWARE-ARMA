class CfgPatches
{
    class AWARE_main
    {
        name = "AWARE - Main";
        author = "Brixie71";
        url = "";
        requiredVersion = 2.14;
        requiredAddons[] = {"A3_Functions_F"};
        units[] = {};
        weapons[] = {};
    };
};

class CfgFunctions
{
    class AWARE
    {
        tag = "AWARE";

        class Main
        {
            file = "x\aware\addons\main\functions";

            class init
            {
                postInit = 1;
            };

            class hello {};
        };
    };
};
