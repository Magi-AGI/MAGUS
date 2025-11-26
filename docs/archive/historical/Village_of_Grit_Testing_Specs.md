# The Village of Grit - AI Agent Testing Scenario

## Setting
The Village of Grit is a musical learning environment where an AI agent explores, learns, and interacts with the community. Built on the Evennia MUD framework, it provides discrete locations, objects, and characters for the agent to engage with.

## Goals (Demands)

### 1. **Exploration** (Current: 0.5)
**Purpose**: Drive to discover new locations, objects, and experiences in the village.
- Satisfied by: Visiting new rooms, examining unfamiliar objects, discovering hidden areas
- Represents: Curiosity and knowledge-seeking behavior

### 2. **Affinity** (Current: 0.5)  
**Purpose**: Need for social connection and positive relationships with NPCs/players.
- Satisfied by: Successful conversations, helping others, participating in group activities
- Represents: Social bonding and community integration

### 3. **Energy** (Current: 0.8)
**Purpose**: Resource management for sustaining activities.
- Depleted by: Movement, complex actions, social interactions
- Restored by: Resting, eating, sleeping
- Represents: Physical and mental stamina

## Actions and Their Evaluations

### **Action: EXPLORE_NEW_ROOM**
*Move to an unvisited adjacent room*

| Goal | Considerations | Discouragements |
|------|---------------|-----------------|
| **Exploration** | • `novelty_available` (1.0 if unvisited room exists)<br>• `accessible_path` (1.0 if no locked doors)<br>• `discovery_potential` (0.8 for rooms with descriptions mentioning "interesting") | • `already_explored` (0.1 if all adjacent rooms visited)<br>• `dead_end` (0.5 if room has only one exit) |
| **Affinity** | • `social_opportunity` (0.7 if room description mentions people) | • `isolation_risk` (0.6 if moving away from populated areas)<br>• `interruption` (0.3 if leaving mid-conversation) |
| **Energy** | • `short_distance` (0.8 if adjacent room) | • `energy_cost` (0.7 if energy < 0.3)<br>• `fatigue` (0.5 if many recent moves) |

### **Action: EXAMINE_OBJECT**
*Investigate an object in the current room*

| Goal | Considerations | Discouragements |
|------|---------------|-----------------|
| **Exploration** | • `unexamined_object` (1.0 if not previously examined)<br>• `complexity` (0.6-0.9 based on object description length)<br>• `musical_instrument` (0.9 if object is an instrument) | • `familiar_object` (0.2 if already examined)<br>• `trivial_item` (0.4 if common object) |
| **Affinity** | • `shareable_discovery` (0.6 if others present)<br>• `conversation_starter` (0.7 if unusual object) | • `private_property` (0.3 if owned by NPC)<br>• `attention_diversion` (0.4 if others are talking) |
| **Energy** | • `simple_examination` (0.9 for look/examine) | • `energy_drain` (0.6 if energy < 0.2)<br>• `complex_puzzle` (0.4 if object requires manipulation) |

### **Action: TALK_TO_NPC**
*Initiate conversation with a Non-Player Character*

| Goal | Considerations | Discouragements |
|------|---------------|-----------------|
| **Exploration** | • `information_source` (0.7 if NPC hasn't been talked to)<br>• `local_knowledge` (0.6 if NPC is a villager) | • `repetitive_dialogue` (0.3 if recently talked to) |
| **Affinity** | • `relationship_building` (0.9 if positive past interactions)<br>• `mutual_interest` (0.8 if shared musical interest)<br>• `helping_opportunity` (0.7 if NPC needs something) | • `busy_npc` (0.4 if NPC is occupied)<br>• `negative_history` (0.2 if past interaction went poorly) |
| **Energy** | • `restful_activity` (0.6 if sitting while talking) | • `long_conversation` (0.5 if NPC is talkative)<br>• `mental_effort` (0.6 if complex topic) |

### **Action: PRACTICE_INSTRUMENT**
*Play or practice a musical instrument*

| Goal | Considerations | Discouragements |
|------|---------------|-----------------|
| **Exploration** | • `new_song` (0.8 if learning new piece)<br>• `technique_discovery` (0.7 if trying new method) | • `repetition` (0.3 if same song repeatedly) |
| **Affinity** | • `audience_present` (0.9 if others listening)<br>• `group_activity` (1.0 if joining others)<br>• `teaching_moment` (0.8 if can help others) | • `disturbance` (0.2 if late hour/quiet area)<br>• `poor_performance` (0.4 if low skill) |
| **Energy** | • `energizing_music` (0.6 if upbeat song) | • `physical_strain` (0.5 if energy < 0.4)<br>• `duration` (0.6 if long practice session) |

### **Action: REST**
*Sit down or find a place to rest*

| Goal | Considerations | Discouragements |
|------|---------------|-----------------|
| **Exploration** | • `observation_opportunity` (0.4 if can watch others)<br>• `planning_time` (0.5 if can review map/notes) | • `stagnation` (0.2 if no new information)<br>• `missing_opportunities` (0.3 if events happening) |
| **Affinity** | • `social_rest` (0.7 if resting with others)<br>• `approachable` (0.6 if in common area) | • `isolation` (0.4 if resting alone)<br>• `unavailable` (0.3 if others need help) |
| **Energy** | • `recovery_needed` (1.0 if energy < 0.3)<br>• `comfortable_spot` (0.8 if designated rest area)<br>• `safe_location` (0.9 if familiar place) | • `restlessness` (0.3 if energy > 0.8)<br>• `uncomfortable` (0.5 if no proper seating) |

### **Action: HELP_NPC**
*Assist an NPC with a task or request*

| Goal | Considerations | Discouragements |
|------|---------------|-----------------|
| **Exploration** | • `new_task` (0.8 if unfamiliar request)<br>• `location_discovery` (0.7 if task leads to new area) | • `routine_task` (0.3 if simple/repeated task) |
| **Affinity** | • `relationship_boost` (1.0 if helping needed task)<br>• `gratitude` (0.9 if NPC appreciative)<br>• `reputation` (0.8 if others observe) | • `ungrateful_npc` (0.2 if NPC is demanding)<br>• `competition` (0.4 if taking credit from others) |
| **Energy** | • `simple_help` (0.7 if low-effort task) | • `exhausting_task` (0.3 if energy < 0.5)<br>• `time_consuming` (0.5 if long task) |

## Implementation Notes

1. **Consideration values**: Range from 0.0 (worst) to 1.0 (best), with 0.5 being neutral
2. **Discouragement values**: Range from 0.0 (complete block) to 1.0 (no discouragement)
3. **State checks**: Many considerations/discouragements require checking game state:
   - Room visit history
   - Object examination history
   - NPC interaction history
   - Current energy level
   - Presence of other characters

## Example Calculation

**Scenario**: Agent is in the Library with energy at 0.8, a new NPC is present, and an unexamined piano is in the room.

For **EXAMINE_OBJECT** (piano):
- Exploration: high consideration (unexamined musical instrument)
- Affinity: medium consideration (could share discovery)
- Energy: low discouragement (high energy available)
- **Likely chosen if exploration is highly weighted**

For **TALK_TO_NPC**:
- Exploration: medium consideration (new information source)
- Affinity: high consideration (relationship building)
- Energy: low discouragement
- **Likely chosen if affinity is highly weighted**

This framework provides clear, testable scenarios for your MAGUS implementation in the Village of Grit!
