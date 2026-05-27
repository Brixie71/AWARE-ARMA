# Common TCCC Procedures in Arma 3

This document shows how to implement commonly needed TCCC procedures in Arma 3 medical systems, with real-world context and game mechanics mapping.

## Hemorrhage Control: Tourniquet Application

### Real-World TCCC Protocol
**When**: Massive limb hemorrhage (life-threatening bleeding from arm or leg)  
**Goal**: Occlude blood flow completely, stop all bleeding  
**Success**: Distal limb pulseless, bleeding stopped  
**Risk**: Prolonged use (>2 hours) can cause tissue damage  

### Arma 3 Implementation

**Check conditions**:
```sqf
// Is the limb bleeding?
_limbBleed = [_patient, "r_leg"] call fnc_getBodyPartDamage;
if (_limbBleed < 0.3) exitWith { hint "No significant bleeding to treat" };

// Does medic have tourniquet?
if !(_medic hasItem "ACE_Tourniquet_Esmarch") exitWith { 
    hint "Medic needs tourniquet" 
};
```

**Apply tourniquet**:
```sqf
_medic removeItem "ACE_Tourniquet_Esmarch";
_medic playAction "Medical";
sleep 5;  // Application takes 5 seconds

// Stop all bleeding from this limb
[_patient, "r_leg", 0] call fnc_stopLimbBleeding;  // 0 = no bleeding

// Record tourniquet application
[_patient, "r_leg", "tourniquet"] call fnc_setTourniquetStatus;

// Set timer for tourniquet duration (2-hour limit)
_patient setVariable ["r_leg_tourniquet_time", serverTime];
```

**Monitor tourniquet**:
```sqf
// In loop, check tourniquet duration
_tourniquetTime = serverTime - (_patient getVariable "r_leg_tourniquet_time");
if (_tourniquetTime > 7200) then {  // 7200 seconds = 2 hours
    // Limb becomes unsalvageable
    [_patient, "r_leg", 1] call fnc_permanentLimbDamage;
    hint "Limb has suffered irreversible damage from prolonged tourniquet";
};
```

---

## Hemorrhage Control: Hemostatic Bandage

### Real-World TCCC Protocol
**When**: Moderate to severe bleeding from wound (not life-threatening)  
**Goal**: Apply direct pressure with hemostatic agent, slow/stop bleeding  
**Success**: Bleeding reduced to manageable level, dressing holds  
**Effectiveness**: Depends on wound severity and placement  

### Arma 3 Implementation

**Check conditions**:
```sqf
_armBleed = [_patient, "r_arm"] call fnc_getBodyPartDamage;
if (_armBleed > 0.8) exitWith {  
    hint "Wound too severe for bandage alone, use tourniquet"  
};

if !(_medic hasItem "ACE_elasticBandage") exitWith { 
    hint "Medic needs elastic bandage" 
};
```

**Apply bandage**:
```sqf
_medic removeItem "ACE_elasticBandage";
_medic playAction "Medical";
sleep 3;  // Bandaging takes 3 seconds

// Reduce bleeding based on wound severity
_currentBleed = [_patient, "r_arm"] call fnc_getBodyPartBleeding;
_bandageEffectiveness = 0.5 + (0.5 - _currentBleed);  // More effective on minor wounds
_newBleed = _currentBleed * (1 - _bandageEffectiveness);

[_patient, "r_arm", _newBleed] call fnc_setBodyPartBleeding;

// Record dressing
[_patient, "r_arm", "bandaged"] call fnc_setWoundDressingStatus;
```

---

## Airway Management: Recovery Position

### Real-World TCCC Protocol
**When**: Unconscious casualty with patent airway  
**Goal**: Position casualty to prevent airway obstruction from fluid/tongue  
**Success**: Airway remains clear, casualty can breathe  
**Risk**: Need to maintain position, cannot be left unattended safely  

### Arma 3 Implementation

**Check conditions**:
```sqf
_consciousness = [_patient] call fnc_getConsciousness;
if (_consciousness > 0.5) exitWith { 
    hint "Casualty is conscious, recovery position not needed" 
};

_breathing = [_patient] call fnc_getRespirationStatus;
if (_breathing < 0.2) exitWith { 
    hint "Breathing too poor, need airway device or oxygen" 
};
```

**Apply recovery position**:
```sqf
// Play positioning animation
_patient setUnitPos "UP";
_patient playAction "AidlPsitMnlp4S84";  // Casualty lying on side

sleep 2;  // Takes 2 seconds to position

// Improve airway patency
_currentAirway = [_patient] call fnc_getAirwayStatus;
_improvedAirway = _currentAirway + 0.3;  // Recovery position helps 30%

[_patient, _improvedAirway] call fnc_setAirwayStatus;
```

---

## Airway Management: Oxygen Therapy

### Real-World TCCC Protocol
**When**: Inadequate breathing, low oxygen saturation, shock  
**Goal**: Increase oxygen available to tissues  
**Success**: Oxygen saturation improves, consciousness improves  
**Duration**: Continuous until casualty stabilizes or evacuates  

### Arma 3 Implementation

**Check conditions**:
```sqf
if !(_medic hasItem "ACE_Oxygen_Bottle") exitWith { 
    hint "Medic needs oxygen bottle" 
};

_spO2 = [_patient] call fnc_getOxygenSaturation;
if (_spO2 > 90) exitWith { 
    hint "Oxygen saturation adequate, oxygen not needed" 
};
```

**Apply oxygen**:
```sqf
_medic removeItem "ACE_Oxygen_Bottle";
_medic playAction "Medical";
sleep 2;  // Takes 2 seconds to set up

// Oxygen improves saturation gradually
_patient setVariable ["oxygen_active", true];
_patient setVariable ["oxygen_startTime", serverTime];

// In update loop, increase saturation over time
[{
    params ["_patient"];
    _oxygenActive = _patient getVariable ["oxygen_active", false];
    if !(_oxygenActive) exitWith { [_handle] call CBA_fnc_removePerFrameHandler };
    
    _currentSpO2 = [_patient] call fnc_getOxygenSaturation;
    _improvedSpO2 = min [_currentSpO2 + 2, 100];  // Increase 2% per cycle up to 100%
    [_patient, _improvedSpO2] call fnc_setOxygenSaturation;
    
}, 1, [_patient]] call CBA_fnc_addPerFrameHandler;
```

**Stop oxygen**:
```sqf
_patient setVariable ["oxygen_active", false];
hint "Oxygen therapy stopped";
```

---

## Shock Management: IV Fluid Administration

### Real-World TCCC Protocol
**When**: Hemorrhagic shock (blood loss with low BP)  
**Goal**: Restore blood volume and circulation  
**Success**: Blood pressure stabilizes, shock signs improve  
**Complication**: Over-infusion can worsen bleeding by raising pressure  

### Arma 3 Implementation

**Check conditions**:
```sqf
_bloodLoss = [_patient] call fnc_getTotalBloodLoss;
if (_bloodLoss < 0.2) exitWith { 
    hint "Blood loss insufficient to warrant IV" 
};

_bloodPressure = [_patient] call fnc_getBloodPressure;  // Returns systolic pressure
if (_bloodPressure > 100) exitWith { 
    hint "Blood pressure acceptable, IV not needed" 
};

if !(_medic hasItem "ACE_Plasma_IV") exitWith { 
    hint "Medic needs IV bag" 
};
```

**Apply IV**:
```sqf
_medic removeItem "ACE_Plasma_IV";
_medic playAction "Medical";
sleep 4;  // Takes 4 seconds to establish IV

// IV restores blood volume gradually
_patient setVariable ["iv_running", true];
_patient setVariable ["iv_startTime", serverTime];

// Monitor blood pressure improvement
[{
    params ["_patient"];
    _ivRunning = _patient getVariable ["iv_running", false];
    if !(_ivRunning) exitWith { [_handle] call CBA_fnc_removePerFrameHandler };
    
    // Increase blood pressure over time (max 1L infusion restores ~20-30 mmHg)
    _currentBP = [_patient] call fnc_getBloodPressure;
    _improvedBP = min [_currentBP + 2, 120];  // Increase 2 mmHg per cycle
    [_patient, _improvedBP] call fnc_setBloodPressure;
    
    // After ~1 liter or once BP adequate, stop infusion
    _elapsedTime = serverTime - (_patient getVariable "iv_startTime");
    if (_improvedBP >= 90 || _elapsedTime > 30) then {
        _patient setVariable ["iv_running", false];
    };
    
}, 1, [_patient]] call CBA_fnc_addPerFrameHandler;
```

---

## Hypothermia Prevention: Insulation

### Real-World TCCC Protocol
**When**: Cold environment, prolonged casualty care  
**Goal**: Prevent further heat loss  
**Success**: Core temperature stabilizes  
**Method**: Remove wet clothes, apply insulation blanket  

### Arma 3 Implementation

**Check conditions**:
```sqf
_coreTemp = [_patient] call fnc_getCoreTemperature;
_envTemp = getWeatherTemp;

if (_coreTemp > 35 || _envTemp > 15) exitWith { 
    hint "Hypothermia risk low, insulation not urgent" 
};

if !(_medic hasItem "ACE_Thermal_Blanket") exitWith { 
    hint "Medic needs thermal blanket" 
};
```

**Apply insulation**:
```sqf
_medic removeItem "ACE_Thermal_Blanket";
_medic playAction "Medical";
sleep 3;  // Takes 3 seconds to wrap patient

// Halt core temperature drop
_patient setVariable ["insulated", true];
_patient setVariable ["insulation_startTime", serverTime];

// In weather loop, insulation reduces heat loss
[{
    params ["_patient"];
    _insulated = _patient getVariable ["insulated", false];
    if !(_insulated) exitWith { [_handle] call CBA_fnc_removePerFrameHandler };
    
    _currentTemp = [_patient] call fnc_getCoreTemperature;
    _envTemp = getWeatherTemp;
    _tempDiff = _currentTemp - _envTemp;
    
    // Without insulation: lose 1 degree/minute
    // With insulation: lose 0.1 degree/minute (90% reduction)
    _heatLoss = 0.1 / 60;  // Per second
    _newTemp = max [_currentTemp - _heatLoss, _envTemp];
    
    [_patient, _newTemp] call fnc_setCoreTemperature;
    
}, 1, [_patient]] call CBA_fnc_addPerFrameHandler;
```

---

## Procedure Chaining: Complete Casualty Treatment

Example of combining multiple procedures for a realistic casualty treatment:

```sqf
// Casualty has: severe leg bleeding + moderate chest wound + moderate shock

// Step 1: Massive Hemorrhage (M)
[casualty, medic, "ACE_Tourniquet_Esmarch"] call fnc_applyTourniquet;  // Right leg

// Step 2: Airway (A)
[casualty, medic, ""] call fnc_positionRecovery;  // Recovery position

// Step 3: Respiration (R)
[casualty, medic, "ACE_Chest_Seal"] call fnc_applyChestSeal;  // For chest wound

// Step 4: Circulation (C)
[casualty, medic, "ACE_Plasma_IV"] call fnc_applyIV;  // Restore blood volume

// Step 5: Hypothermia (H)
[casualty, medic, "ACE_Thermal_Blanket"] call fnc_applyInsulation;  // Prevent heat loss

// Casualty is now stabilized and ready for evacuation
hint "Casualty stabilized, proceed to CASEVAC";
```

---

## Testing Your Procedures

After implementing procedures:

1. **Single casualty test**: Apply procedure to isolated casualty, verify effects
2. **Injury pattern test**: Test procedure with the specific injury it treats
3. **Medic skill test**: Test with different medic skill levels
4. **Resource constraint test**: Test when medic is low on supplies
5. **Multiple casualty test**: Triage multiple casualties, apply procedures in priority order
6. **Time test**: Verify procedure times are realistic (not instant)
7. **State persistence test**: Verify treatment effects persist after procedure ends

Use test missions in `missions/` folder to validate your medical system.
