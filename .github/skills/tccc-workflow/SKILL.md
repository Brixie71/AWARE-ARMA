---
name: tccc-workflow
description: 'Map Tactical Combat Casualty Care (TCCC) procedures to Arma 3 medical code implementation. Use when implementing medical treatment workflows, creating medical procedures, understanding TCCC priority systems, or designing medical scenarios.'
argument-hint: 'TCCC procedure or medical workflow to implement'
user-invocable: true
---

# TCCC Workflow to Code Implementation

This skill guides you through mapping real-world Tactical Combat Casualty Care procedures to Arma 3 medical systems, ensuring medical mechanics align with authentic TCCC protocols adapted for the game.

## When to Use

- **Implementing new medical procedures**: Map TCCC stages to SQF code
- **Creating medical treatment functions**: Build SQF handlers that follow TCCC logic
- **Designing medical scenarios**: Ensure casualty care workflows are realistic
- **Understanding TCCC stages**: Learn how Care Under Fire, Tactical Field Care, and Casualty Evacuation translate to Arma 3
- **Building medical workflows**: Create medical state machines and treatment progressions
- **Validating medical priorities**: Ensure treatment order follows TCCC principles (MARCH protocol)

## Key TCCC Stages

| Stage | Context | Focus |
|-------|---------|-------|
| **Care Under Fire** | Active combat | Immediate threat management, self-aid |
| **Tactical Field Care** | Casualty secured, medic available | Primary survey, treatment, stabilization |
| **Casualty Evacuation** | MEDEVAC or safe movement | Transport, monitoring, continuous care |

## Workflow: From TCCC to Code

### Step 1: Define the Medical Procedure
Identify the TCCC procedure you're implementing:
- Which TCCC stage applies? (Care Under Fire / Tactical Field Care / CASEVAC)
- What's the real-world treatment? (tourniquet, bandaging, medication, airway, etc.)
- What's the clinical goal? (stop bleeding, treat shock, restore breathing, etc.)

**Example**: Hemorrhage control → Tourniquet or wound bandaging (Tactical Field Care stage)

### Step 2: Map to Arma 3 Medical Mechanics
Identify the corresponding Arma 3 medical mechanics:
- Which body parts does this affect? (limbs, torso, head, etc.)
- Which medical items provide this treatment? (ACE3 tourniquet, bandages, IV bags, etc.)
- What game-side effects change? (bleeding status, pain, consciousness, etc.)
- What success/failure conditions exist?

**Example**: Body part bleeding → Arma 3 bleeding damage value → ACE3 tourniquet/bandage → Reduce bleeding to 0

### Step 3: Identify Data Points
Research and document required variables and callables:
- Medical item properties (weight, type, effectiveness)
- Body part damage states (current bleeding, damage, bandaging status)
- Patient medical state (consciousness, blood pressure, pain, medication effects)
- Treatment callables (apply tourniquet, bandage wound, administer medication)

Use the [Arma3 Medical Researcher agent](../../../prompts/arma3-medical-researcher.agent.md) to gather:
- ACE3 Arsenal variables and callables
- KAT Advanced Medical functions and parameters
- Medical mechanics documentation

### Step 4: Design the Treatment Logic
Outline the decision tree and state progression:
1. **Condition checks**: Does the casualty need this treatment? (e.g., bleeding > threshold)
2. **Prerequisites**: Can treatment be applied? (medical skill, item available, body part accessible)
3. **Application**: Call the treatment function with correct parameters
4. **Validation**: Verify treatment success/failure
5. **State update**: Track treatment status (item consumed, body part healed, side effects)

See [SQF Implementation Template](./templates/medical-procedure-template.sqf) for code structure.

### Step 5: Implement in SQF
Create SQF function following MARCH protocol order:
- **M**assive hemorrhage: Tourniquet/wound packing
- **A**irway: Clear airway, position casualty
- **R**espiration: Check breathing, apply oxygen/airway devices
- **C**irculation: IV fluids, blood products
- **H**ypothermia: Prevent heat loss, warm if possible

See [MARCH Priority Reference](./references/march-protocol.md) for detailed implementation order.

**For fast mass-casualty support, use the [Mass Casualty Quick-Assist Checklist](./references/mass-casualty-checklist.md) to generate short, immediate suggestions and priority actions in the KAT medical menu.**

### Step 6: Test with Scenarios
Validate your implementation against realistic casualty situations:
- Single casualty with specific injury pattern
- Multiple casualties with mixed injuries
- Medic skill variations (untrained vs. trained)
- Medical supply limitations
- Stress conditions (ongoing fire, time pressure)

## Output Format

When implementing a TCCC procedure, document:

```markdown
## Procedure: [Procedure Name]
**TCCC Stage**: [Care Under Fire / Tactical Field Care / CASEVAC]

### Real-World Protocol
[Description of actual TCCC treatment]

### Arma 3 Implementation
- **Body Parts Affected**: [limbs, torso, head, etc.]
- **Medical Items**: [ACE3/KAT items that provide treatment]
- **Medical Variables**: [Required data points to check]
- **Callables**: [Functions to invoke for treatment]

### Success/Failure Conditions
- Success: [Treatment effectively reduces threat]
- Failure: [Conditions that cause treatment to fail]

### Implementation Reference
[Link to SQF code in your project]
```

## Related Resources

- [TCCC Baseline Reference](./references/tccc-baseline.md)
- [MARCH Protocol Priorities](./references/march-protocol.md)
- [SQF Implementation Template](./templates/medical-procedure-template.sqf)
- [Body Part Damage Reference](./references/body-composition.md)
- [Mass Casualty Quick-Assist Checklist](./references/mass-casualty-checklist.md)

## Next Steps

1. **Invoke the Arma3 Medical Researcher agent** to gather ACE3/KAT medical references
2. **Use SQF Template** to structure your medical procedure function
3. **Test** the procedure against example casualty scenarios
4. **Document** the implemented procedure using the output format above
