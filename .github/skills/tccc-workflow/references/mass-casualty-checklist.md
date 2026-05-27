# Mass Casualty Quick-Assist Checklist

This checklist is designed for fast action during KAT Advanced Medical mass-casualty situations. It prioritizes critical body parts and the immediate medications/items needed, while keeping the workflow simple for the player.

## Purpose

- Provide immediate suggestions in the KAT medical menu (press H)
- Prioritize life-saving treatments in the right order
- Keep recommendations short and actionable
- Use the player's available bag inventory
- Highlight missing items with clear indicators

## Priority Rules

1. **Massive Hemorrhage first**
   - Limb bleeding is the highest immediate threat
   - Apply tourniquet or hemostatic bandage immediately
   - Target: arms and legs

2. **Airway & Respiration second**
   - Head and chest injuries affect breathing and consciousness
   - Use recovery position, chest seal, oxygen, or airway support

3. **Circulation third**
   - Shock from blood loss requires fluids or blood products
   - Monitor blood pressure and restore volume

4. **Hypothermia fourth**
   - Prevent further heat loss during transport
   - Use insulation, blankets, or warming items

## Simple Body Part Priorities

- **Legs and arms**: Tourniquet / bandage first
- **Chest**: Chest seal, oxygen, needle decompression if available
- **Head**: Airway support, oxygen, mental state monitoring
- **Abdomen/Pelvis**: IV fluids / transfusion, immobilize if possible

## Medical First (On Scene) Workflow

1. **Scan casualties quickly**
   - Identify who is down
   - Note obvious bleeding and chest/head injuries

2. **Assign priority by threat**
   - Immediate hemorrhage: treat now
   - Severe breathing issues: treat next
   - Shock: support circulation
   - Hypothermia: isolate and warm

3. **Apply lifesaving items**
   - Tourniquet or hemostatic bandage for limb hemorrhage
   - Chest seal / oxygen for chest wounds
   - IV fluids or blood for shock
   - Thermal blanket for cold or open wounds

4. **Update KAT suggestions instantly**
   - Show top 1-2 actions for each casualty
   - Display missing item badge if the player lacks the required item
   - Prefer items from the player’s bag first

## Medical Transport (En Route) Workflow

1. **Maintain treatments already applied**
   - Keep tourniquets, bandages, chest seals, and IV lines in place

2. **Monitor vital status**
   - Recheck bleeding, breathing, blood pressure, and consciousness

3. **Provide supporting items**
   - Continue oxygen if breathing remains poor
   - Top up IV fluids if shock persists
   - Keep casualty warm with insulation

4. **Prepare for handoff**
   - Note what treatments were used
   - Identify any missing items or alternate medications
   - Keep the checklist minimal and focused on what is active

## Suggestion Output Style for KAT H Menu

Use clear, direct wording like:

- **"Leg bleed: tourniquet now"**
- **"Chest wound: apply seal + oxygen"**
- **"Shock: start IV / transfusion"**
- **"Cold casualty: insulation needed"**
- **"Missing: tourniquet in bag"**

## Player Inventory Guidance

Use the player bag inventory to decide suggestions:

- If required item exists: show the exact item and action
- If missing: show a red indicator and alternate options
- If multiple casualties need the same item: warn about supply shortage
- If item is unavailable, suggest the next best treatment in the list

## Mass Casualty Focus

In mass casualty, keep suggestions concise and repeatable:

- **One casualty at a time** based on highest immediate threat
- **Shortcut to the next critical action** rather than full diagnosis
- **Remove noise**: do not show low-priority treatments until the lifesaving ones are done
- **Use simple state**: bleeding, airway, shock, temperature

## Example Checklist for a Single Casualty

1. Limb bleed? → Tourniquet or pressure bandage
2. Chest/head injury? → Seal + oxygen
3. Low BP/shock? → IV fluids / blood
4. Cold? → Blankets / insulation

## Implementation Notes for Developers

- Build a small rule engine for the KAT H menu suggestions
- Query each casualty for body part status and treatment need
- Match required treatments to player inventory items
- Provide fallback recommendations if a required item is missing
- Keep the menu response time minimal for mass-casualty speed
