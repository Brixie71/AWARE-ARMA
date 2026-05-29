# MARCH Protocol Implementation Reference

The MARCH protocol provides the systematic order for treating life threats during Tactical Field Care. This reference shows how to implement each step in Arma 3 SQF.

## MARCH Priority Order

### M - Massive Hemorrhage (Priority 1)

**What to treat**: Uncontrolled bleeding from limbs that can lead to rapid death

**Check condition**:
```
_bleeding = [(casualties player) select 0, "bleeding"] call BIS_fnc_getBodyPartDamage;
_bleeding > 0
```

**Treatment options** (in order):
1. **Tourniquet** (most effective for limb wounds)
   - Apply to upper arm or upper leg
   - Stops all bleeding from that limb
   - Prevents circulation to distal limb

2. **For Fractures, Apply Splint** (for Fractures)
   - Apply Splint After Tournique
   - Apply Splint before adding Bandages 

3. **Wound packing** (for deep cavitary wounds)
   - Manual packing of wound with gauze
   - More time-intensive
   - Most effective for complex wounds

4. **Hemostatic gauze/Bandage** (for smaller wounds)
   - Applies direct pressure
   - Slows or stops bleeding depending on severity
   - Casualty can move with bandage

**Implementation approach**:
- Check which body part is bleeding
- Assess bleeding severity
- Select appropriate tool (tourniquet for active Bleeding, before applying Bandages, either Packing, Elastic, quicloth, Bandage)
- For Fractures, Apply Splint (If there is a Fracture)
- Apply and verify bleeding stops

---

### A - Airway (Priority 2)

**What to treat**: Obstruction preventing normal breathing or consciousness loss

**Check condition**:
```
_consciousness = [(casualties player) select 0, "consciousness"] call BIS_fnc_getBodyPartStatus;
_canBreathe = _consciousness >= 0.5
```

**Treatment options**:
1. **Positioning** (Recovery position)
   - Place casualty in recovery position
   - Gravity helps keep airway open

2. **Clear Occlution/Obstruction** (Foreign body removal) 
   - Remove blood, vomit, or debris from mouth
   - Allows air passage

3. **Airway devices** (Oral/nasal airway)
   - Insert airway Adjunct
      - Additional Requirement after Airway Adjunct
   - Maintains airway patency mechanically

4. **Oxygen** (If available)
   - Increases oxygen saturation
   - Helps compensate for shock

**Implementation approach**:
- Assess casualty consciousness level
- Check for airway patency
- Apply appropriate device or positioning
- Re-check breathing effectiveness

---

### R - Respiration (Priority 3)

**What to treat**: Inadequate breathing or tension pneumothorax

**Check condition**:
```
_breathing = [(casualties player) select 0, "respiration"] call BIS_fnc_getBodyPartStatus;
_adequateBreathe = _breathing > 0.5
```

**Threats**:
1. **Tension pneumothorax** (collapsed lung, pressure building)
   - Caused by penetrating chest wound
   - Air enters chest cavity, compresses lung
   - Rapidly fatal if untreated

2. **Open pneumothorax** (sucking chest wound)
   - Air flows in/out of wound with breathing
   - Reduces effective gas exchange

**Treatment options**:
1. **Chest seal** (3-sided dressing)
   - Cover wound to prevent air entry
   - Allows pressure to escape on exhalation

2. **Needle decompression** (14-gauge needle)
   - Releases pressure in tension pneumothorax
   - Immediate relief of pressure

3. **Positioning and oxygen**
   - Semi-sitting position (aids breathing)
   - Oxygen therapy (supplements breathing)

**Implementation approach**:
- Perform chest exam (visual, auscultation simulation)
- Identify pneumothorax vs simple respiratory compromise
- Apply chest seal for open wounds
- Use needle decompression for tension signs
- Apply oxygen to boost respiration

---

### C - Circulation (Priority 4)

**What to treat**: Shock from blood loss or inadequate perfusion

**Check condition**:
```
_bloodPressure = [(casualties player) select 0, "bloodPressure"] call BIS_fnc_getBodyPartStatus;
_shockIndicators = _bloodPressure < 80 // systolic pressure
```

**Threats**:
1. **Hemorrhagic shock** (blood loss reduces perfusion)
   - Casualty loses consciousness
   - Organs fail due to lack of oxygen
   - Fatal if not treated

2. **Obstructive shock** (pressure or tension preventing circulation)
   - Chest compression from tension pneumothorax
   - Abdominal compartment syndrome

**Treatment options**:
1. **IV fluids** (Saline/Ringer's lactate)
   - Restores blood volume
   - Typical limit: 1-2L before damage from dilution

2. **Blood transfusion** (Whole blood or packed RBCs)
   - More effective than crystalloids
   - Limited availability in field

3. **Tourniquet** (Already applied in M phase)
   - Further hemorrhage control if needed

4. **Positioning** (Supine, legs elevated)
   - Helps blood flow to vital organs

**Implementation approach**:
- Calculate blood loss from injury patterns
- Assess shock indicators (BP, heart rate, consciousness)
- Apply IV fluids proportional to blood loss
- Use transfusion for massive hemorrhage (>2L loss estimated)
- Reposition casualty to optimize perfusion

---

### H - Hypothermia (Priority 5)

**What to treat**: Heat loss in cold environments

**Check condition**:
```
_coreTemp = [(casualties player) select 0, "coreTemperature"] call BIS_fnc_getBodyPartStatus;
_hypothermic = _coreTemp < 32 // Celsius
```

**Threats**:
1. **Acute hypothermia** (rapid heat loss)
   - Cold environment exposure
   - Wet clothing
   - Extended immobility

2. **Recovery phase paradoxical undressing**
   - Casualty becomes confused
   - Removes protective clothing (self-harm)

**Treatment options**:
1. **Remove wet clothing**
   - Eliminate heat-loss pathway
   - Replace with dry insulation

2. **Insulation/blankets**
   - Passive rewarming
   - Prevent further heat loss

3. **Warm fluids** (If available)
   - Warm IV fluids
   - Warm oral fluids (if conscious)

4. **Active rewarming** (Advanced setting)
   - Heat lamp
   - Warm body contact
   - Extracorporeal rewarming

**Implementation approach**:
- Monitor environmental temperature
- Track casualty heat loss over time
- Apply insulation/warm items to prevent hypothermia
- Prevent prolonged exposure
- Consider continued cooling effects of shock

---

## Implementation Workflow

### For Each Casualty:
1. **M Check**: Any massive hemorrhage? → Apply tourniquet/bandage
2. **A Check**: Airway patent? → Position, clear, apply device if needed
3. **R Check**: Breathing adequate? → Seal chest, decompress, add oxygen
4. **C Check**: Shock present? → IV fluids, transfusion, position
5. **H Check**: Hypothermia risk? → Insulate, warm

### Priority Rules:
- **Treat M before A**: Massive hemorrhage is more immediately lethal than airway
- **Don't skip steps**: Even if one is treated, check the next
- **Reassess frequently**: Casualty condition changes; repeat MARCH every 5-10 minutes
- **Resource management**: Treat most critical most salvageable first
- **Team priorities**: Treat highest-priority casualties with best resources

## Validation Checklist

- [ ] Massive hemorrhage controlled (all bleeding stopped or tourniqueted)
- [ ] Airway patent and consciousness adequate for breathing
- [ ] Respiration supported; no tension pneumothorax signs
- [ ] Shock treated with fluids; vital signs stabilizing
- [ ] Hypothermia prevented through insulation


