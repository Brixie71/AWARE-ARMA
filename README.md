# AWARE Arma 3 Mod

Minimal Arma 3 mod scaffold.

## Structure

```text
AWARE/
  mod.cpp
  meta.cpp
  addons/
    main/
      $PBOPREFIX$
      config.cpp
      functions/
        fn_init.sqf
        fn_hello.sqf
```

## Build With HEMTT

1. Put `hemtt.exe` in this folder, or install HEMTT with `winget install hemtt`.
2. From this folder, run:

```powershell
.\hemtt.exe build
```

If `hemtt.exe` is installed on your PATH, use:

```powershell
hemtt build
```

The built local test mod is written to `.hemttout/build`.

Load that folder as a local mod in the Arma 3 Launcher, or launch Arma 3 with:

```powershell
-mod=D:\PROJECTS\HREP\AWARE\.hemttout\build
```

To launch Arma 3 directly with the dev build:

```powershell
.\hemtt.exe launch
```

To launch the bundled Virtual Reality hello-world mission:

```powershell
.\hemtt.exe launch vr
```

To open the bundled Virtual Reality mission in Eden Editor:

```powershell
.\hemtt.exe launch eden
```

## Manual Build

1. Install Arma 3 Tools from Steam.
2. Pack `addons/main` into `aware_main.pbo`.
3. Place the packed file at `@AWARE/addons/aware_main.pbo`.
4. Launch Arma 3 with `-mod=@AWARE`.

The `$PBOPREFIX$` file sets the virtual addon path to `x\aware\addons\main`, which is used by `CfgFunctions`.
