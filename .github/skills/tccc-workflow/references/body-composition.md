# Arma 3 Body Composition & Damage Reference

This reference documents the body part structure used in Arma 3 medical systems and how damage translates to medical mechanics.

## Body Part Categories

Arma 3 divides the human body into the following medical regions for damage tracking:

### Limb Parts (High Hemorrhage Risk)
- **Left Arm** (`l_arm`)
- **Right Arm** (`r_arm`)
- **Left Leg** (`l_leg`)
- **Right Leg** (`r_leg`)

**Characteristics**:
- Can sustain high damage without immediate lethality
- Primary sites for hemorrhage (especially legs)
- Tourniquet application prevents all limb hemorrhage
- Loss of function depends on damage severity

### Torso (Critical Organs)
- **Abdomen/Pelvis** (`abdomen`)
- **Chest** (`chest`)
- **Pelvis** (`pelvis`)

**Characteristics**:
- Contains vital organs (lungs, heart, liver, intestines)
- Damage here is immediately threatening
- Tension pneumothorax risk in chest wounds
- Intra-abdominal bleeding difficult to control

### Head (Life Support)
- **Head** (`head`)

**Characteristics**:
- Contains brain and major vessels
- Any significant damage affects consciousness
- Airway obstruction risk
- Limited survival with severe damage

---

## Damage State Progression

Each body part tracks damage from 0 (healthy) to 1 (destroyed). Medical state depends on damage level:

### Damage Thresholds

| Damage Range | Medical Status | Clinical Effect |
|--------------|---|---|
| 0.0 - 0.2 | Minor injury | Pain, slight functional loss |
| 0.2 - 0.5 | Moderate injury | Significant pain, bleeding begins |
| 0.5 - 0.8 | Severe injury | Profuse bleeding, major dysfunction |
| 0.8 - 1.0 | Critical/Fatal | Uncontrollable bleeding, organ failure |

### Associated Medical Variables

Each body part tracks:
- **Damage value**: Physical injury severity (0-1)
- **Bleeding**: Active blood loss rate (0-1)
- **Bandaging status**: Dressing applied/removed
- **Tourniquet status**: Tourniquet applied (limbs only)
- **Infection risk**: Time-dependent in untreated wounds
- **Scar tissue**: Permanent minor damage from healed wounds

---

## Hemorrhage Mechanics

### Bleeding Severity by Location

**Limb hemorrhage** (most common treatable):
- Caused by limb damage
- Controlled by tourniquet (immediate, complete)
- Controlled by hemostatic bandage (slower, depends on severity)
- Casualty can lose limb function if untreated long

**Torso hemorrhage** (harder to control):
- Caused by chest/abdomen/pelvis damage
- Cannot be fully controlled by simple dressing
- IV fluids and transfusion primary treatment
- Casualty loses blood volume; shock develops

**Head hemorrhage**:
- Affects consciousness and airway
- Critical due to brain perfusion requirements
- Limited treatment options

### Bleeding Rate Calculation
```
_bleedingRate = _bodyPartDamage * _woundSeverityFactor - _treatmentEffectiveness
If _bleedingRate > 0, blood volume decreases over time
```

---

## Medical Status Variables

### Consciousness
Affected by:
- **Head damage** (primary factor)
- **Blood loss shock** (secondary factor)
- **Medications** (stimulants, sedatives)

States:
- Conscious and alert: Acts normally
- Drowsy/confused: Reduced awareness
- Unconscious: No action possible
- Brain dead: Irreversible

### Respiration
Affected by:
- **Chest damage** (pneumothorax risk)
- **Head damage** (brainstem affects breathing)
- **Shock** (reduces respiration rate)
- **Medication effects** (opioids depress breathing)

States:
- Normal breathing: Adequate oxygenation
- Labored breathing: Reduced capacity
- Gasping: Critical hypoxia
- Apnea: No breathing

### Blood Pressure
Affected by:
- **Total blood loss** (primary factor)
- **Shock level** (secondary factor)
- **Medications** (stimulants increase, sedatives decrease)

Typical values:
- Normal: 120/80 mmHg
- Shock warning: <100/60 mmHg
- Severe shock: <80/50 mmHg
- Cardiac arrest: 0/0 mmHg

### Pain
Affected by:
- **Overall damage level** (all injuries)
- **Medications** (opioids reduce)
- **Shock** (sometimes masks pain)

Effects:
- Mild pain: Slight morale/action penalty
- Moderate pain: Noticeable action reduction
- Severe pain: Large penalties, possible incapacity
- Shock pain suppression: Reduced perception despite injury

---

## Treatment Effectiveness by Body Part

| Body Part | Primary Treatment | Secondary Treatment | Tertiary |
|---|---|---|---|
| **L/R Arm** | Tourniquet | Hemostatic bandage | Pressure dressing |
| **L/R Leg** | Tourniquet | Hemostatic bandage | Pressure dressing |
| **Chest** | Chest seal (if open) | Needle decompression | Oxygen, IV fluids |
| **Abdomen** | IV fluids | Transfusion | Pressure bandage |
| **Pelvis** | IV fluids | Transfusion | Pelvic stabilization |
| **Head** | Airway management | Oxygen | Bandage (cosmetic) |

---

## Vital Signs Interpretation

### Heart Rate
- Resting normal: 60-100 bpm
- Hemorrhage response: 100-150 bpm (early shock)
- Critical shock: 150+ bpm (compensation failure)
- Cardiac arrest: 0 bpm

### Respiration Rate
- Normal: 12-20 breaths/min
- Shock response: 20-30+ breaths/min
- Respiratory depression (drugs): <8 breaths/min (critical)
- Apnea: 0 breaths/min (requires resuscitation)

### Oxygen Saturation (SpO2)
- Normal: 95-100%
- Mild hypoxia: 90-94%
- Moderate hypoxia: 80-89%
- Severe hypoxia: <80% (tissue damage begins)

### Capillary Refill
- Normal: <2 seconds
- Shock: >2 seconds (sluggish perfusion)

---

## Severity Classification

### NISS (New Injury Severity Score) for Multi-System Injuries

When casualty has injuries to multiple body regions, prioritize by severity:

1. **Most severely injured region**: Treat primary threat first
2. **Secondary regions**: Treat after primary stabilization
3. **Minor injuries**: Address last or during evacuation

Example: Casualty with chest wound + right leg hemorrhage
- Primary: Chest (airway/respiration threat)
- Secondary: Right leg (tourniquet, then chest treatment)
- Order: Seal chest wounds first if open → Apply leg tourniquet → Reassess both

---

## Implementation Considerations

When coding medical functions:

- **Damage accumulation**: Multiple hits to same part compound injury
- **Bleeding cascade**: Untreated wounds worsen over time
- **Shock progression**: Blood loss triggers shock symptoms after threshold
- **Unconsciousness risk**: Head damage or shock can cause loss of consciousness
- **Treatment windows**: Some treatments only work within time limits (e.g., tourniquet time limits)
- **Medical skill**: Medic skill affects treatment effectiveness and speed
- **Available resources**: Limited medical supplies affect triage
- **Realism balance**: Arma 3 medical can be arcade or simulation level
