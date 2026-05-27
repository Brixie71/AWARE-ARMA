# Tactical Combat Casualty Care (TCCC) Baseline

Tactical Combat Casualty Care is the standard medical protocol for treating combat casualties in the field. It's organized into three distinct phases based on tactical situation and environment.

## TCCC Overview

TCCC was developed by the U.S. military to address the most common preventable causes of death on the battlefield:
1. **Hemorrhage** (massive uncontrolled bleeding)
2. **Airway obstruction** (inability to breathe)
3. **Tension pneumothorax** (lung collapse)
4. **Shock** (inadequate tissue perfusion)

## Three TCCC Phases

### Phase 1: Care Under Fire
**Situation**: Enemy fire is ongoing, casualty is still in danger  
**Priority**: Survive immediate threat, not full treatment

**Goals**:
- Return fire or take cover
- Provide casualty with first aid items (tourniquet, hemostatic gauze)
- Move casualty to covered/concealed position when possible
- Self-aid preferred; minimal buddy aid

**Treatments Available**:
- Tourniquets for massive limb hemorrhage
- Hemostatic gauze for wounds
- Casualty positioning

### Phase 2: Tactical Field Care
**Situation**: Casualty is no longer under direct fire, medic can safely treat  
**Priority**: Primary survey, treat life threats, stabilize

**Goals**:
- Perform primary survey (MARCH)
- Control hemorrhage completely
- Manage airway obstruction
- Treat tension pneumothorax
- Prevent/manage shock
- Provide analgesia (pain management)
- Prepare for evacuation

**Treatments Available**:
- Complete hemorrhage control (all tourniquets, wound packing)
- Airway management (positioning, airway devices, oxygen)
- Chest decompression (needle, chest seal)
- Intravenous (IV) fluids, blood products
- Pain medications
- Monitoring and reassessment

### Phase 3: Casualty Evacuation (CASEVAC)
**Situation**: Casualty is being transported to aid station or hospital  
**Priority**: Continuous monitoring, maintain treatments, document

**Goals**:
- Maintain treatments already applied
- Reassess and treat new problems
- Keep casualty warm (prevent hypothermia)
- Document all treatments and times
- Communicate with receiving facility

**Treatments Available**:
- All Tactical Field Care treatments continued
- Hypothermia prevention
- Continuous vital signs monitoring

## MARCH Protocol (Primary Survey Order)

Used during Tactical Field Care to systematically address life threats in priority order:

| Priority | Focus | Threat | Treatment |
|----------|-------|--------|-----------|
| **M** | Massive Hemorrhage | Uncontrolled limb bleeding | Tourniquet, hemostatic gauze, wound packing |
| **A** | Airway | Obstruction, foreign objects | Position, clear airway, use devices |
| **R** | Respiration | Tension pneumothorax, inadequate breathing | Needle decompression, chest seal, oxygen |
| **C** | Circulation | Shock from blood loss | IV fluids, blood products, tourniquets |
| **H** | Hypothermia | Heat loss in cold environment | Insulation, passive rewarming, prevent further loss |

## Arma 3 Adaptation

In Arma 3 medical simulations, TCCC procedures translate to:

| TCCC Element | Arma 3 Equivalent |
|--------------|-------------------|
| Tourniquet | ACE3 tourniquet item; reduces bleeding to 0 on limb |
| Hemostatic gauze | ACE3 bandage/packing; stops wound bleeding |
| Airway management | Medical items or procedures affecting consciousness/respiration |
| IV/Blood products | Medical items that restore blood volume/pressure |
| Pain management | Medication items affecting pain status |
| Chest decompression | Medical procedure affecting chest/respiration |

## Clinical Concepts for Simulation

### Hemorrhage Control Hierarchy
1. **Direct pressure** (pressure bandages, hemostatic gauze)
2. **Tourniquet** (for proximal limb wounds)
3. **Wound packing** (for deep cavitary wounds)

In Arma 3: Apply in this order based on wound severity.

### Shock Management
Hemorrhagic shock occurs when blood loss reduces tissue perfusion. TCCC addresses through:
- **Hemorrhage control** (stop blood loss)
- **IV fluids** (restore blood volume)
- **Positioning** (prevent further pooling)
- **Hypothermia prevention** (maintain thermoregulation)

In Arma 3: Monitor blood volume/pressure; apply IV/transfusion as needed.

### Airway Assessment
Casualty can breathe if:
- Conscious and responsive
- Airway patent (not obstructed)
- No tension pneumothorax

In Arma 3: Track breathing status; apply airway devices if needed.

## Implementation Checklist

When implementing a TCCC-based medical system:

- [ ] Care Under Fire phase distinguishes from Tactical Field Care
- [ ] MARCH protocol determines treatment priority (massive hemorrhage first)
- [ ] Hemorrhage control uses correct hierarchy (gauze → tourniquet → packing)
- [ ] Medical items have realistic effectiveness and application time
- [ ] Shock mechanics modeled (blood loss → reduced function)
- [ ] Airway and respiration threats addressable through available items
- [ ] Medic skill affects treatment success/speed
- [ ] Medications have appropriate onset and duration
- [ ] Scenarios test all major TCCC procedures

## References

- **NATO STANAG 2103** - NATO Guidelines for TCCC
- **Committee on TCCC Guidelines** - Official TCCC Updates
- **Military Medicine Journal** - Peer-reviewed medical research
- **Tactical Combat Casualty Care (TCCC) Guidelines** - U.S. Department of Defense
