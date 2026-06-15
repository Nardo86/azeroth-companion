--
-- KnowledgeData.lua -- GENERATED, do not edit by hand.
--
-- Source: companion/knowledge/{dungeons,raids}_wotlk.json
-- Regenerate: python tools/gen_knowledge_lua.py
--
-- Static WotLK boss tips, baked in so the addon can answer boss/role
-- questions in-game with zero /reload and zero LLM round-trip.
--

local ADDON, ns = ...

ns.KnowledgeData = {
  ["expansion"] = "wotlk",
  ["instances"] = {
    {
      ["name"] = "Utgarde Keep",
      ["aliases"] = {
        "UK",
        "UTK",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 68-72; Heroic 80",
      ["generalTips"] = {
        "First WotLK dungeon; very forgiving on normal, tight on heroic at gearing level.",
        "Vrykul + caster mixes - LoS pulls around pillars to group casters.",
        "Bring interrupts for Dalronn's Shadow Bolts and CC for Keleseth's skeletons.",
      },
      ["bosses"] = {
        {
          ["name"] = "Prince Keleseth",
          ["summary"] = "Frost Tomb encases a random player; constant Vrykul Skeleton adds throughout fight.",
          ["positioning"] = "Stack loosely near boss so freed players are healable; tank faces boss anywhere.",
          ["tank"] = {
            "Pick up respawning Vrykul Skeletons immediately - they hit casters.",
            "Hold boss steady; no movement requirement.",
          },
          ["healer"] = {
            "Frost Tomb deals ticking frost dmg - top the tombed player while DPS frees them.",
            "Watch melee taking add damage.",
          },
          ["dps"] = {
            "Instantly switch to break Frost Tomb (player frozen, taking dmg).",
            "AoE/cleave the constant skeleton spawns.",
            "Achievement 'On The Rocks': kill him without shattering any Frost Tomb.",
          },
        },
        {
          ["name"] = "Skarvald the Constructor & Dalronn the Controller",
          ["summary"] = "Dual boss; first to die returns as a ghost, so balance damage to kill near-simultaneously.",
          ["positioning"] = "Tank both together; Skarvald charges, so keep group out of charge lanes.",
          ["tank"] = {
            "Grab both - Skarvald (melee, charges, knockback) and Dalronn (caster).",
            "Pull Dalronn into melee to limit his Shadow Bolt casting.",
          },
          ["healer"] = {
            "Heal through Skarvald's charge stun + physical burst.",
            "Dispel Dalronn's Debilitate (cast-speed slow) on healers if possible.",
          },
          ["dps"] = {
            "Split/balance damage - kill both within seconds of each other to minimize ghost phase.",
            "Interrupt Dalronn's Shadow Bolts.",
            "Whoever dies first becomes a ghost that keeps fighting - don't over-focus one.",
          },
        },
        {
          ["name"] = "Ingvar the Plunderer",
          ["summary"] = "Two-phase; dies in P1, rez'd by valkyr into shadow P2 with Dark Smash and Shadow Axes.",
          ["positioning"] = "Tank against a pillar to LoS Smash/Dark Smash; keep boss faced away from party.",
          ["tank"] = {
            "Face Ingvar AWAY from group - frontal Cleave/Smash hits party otherwise.",
            "Stand near a pillar to line-of-sight (interrupt) his Smash and P2 Dark Smash casts.",
            "Pop a cooldown for Dark Smash (heavy hit + stun).",
          },
          ["healer"] = {
            "Big tank spike on Smash/Dark Smash - pre-heal.",
            "P2 Woe Strike reduces healing received on tank; heal harder.",
            "Dispel Staggering/Dreadful Roar effects if able.",
          },
          ["dps"] = {
            "Move out of spawned Shadow Axe (P2) - they whirl and hit hard.",
            "Avoid the frontal cone; attack from the rear flank.",
            "Burn both phases; P2 is a fresh full-health shadow version.",
          },
        },
      },
    },
    {
      ["name"] = "The Nexus",
      ["aliases"] = {
        "Nexus",
        "NEX",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 69-73; Heroic 80",
      ["generalTips"] = {
        "Heavy arcane/frost magic damage throughout - magic resist/cleanse helps.",
        "Mostly mobile fights; keep moving on Keristrasza and during Telestra splits.",
        "Bring dispels for roots/Arcane Attraction.",
      },
      ["bosses"] = {
        {
          ["name"] = "Grand Magus Telestra",
          ["summary"] = "At 50% splits into 3 mirror images (Fire/Frost/Arcane); reforms when an image type is killed.",
          ["positioning"] = "Spread out for Firebomb; ranged at distance to dodge Ice Nova/Gravity Well.",
          ["tank"] = {
            "Pick up all 3 clones on split; keep them apart-ish for cleave control.",
            "Frost clone roots/slows - reposition as needed.",
          },
          ["healer"] = {
            "Heal through Firebomb DoT and Ice Nova burst during split.",
            "Use instant casts after Gravity Well knock-up.",
          },
          ["dps"] = {
            "Spread to avoid Firebomb chaining.",
            "On split, focus and CC/interrupt the clones; killing one type reforms her at low HP.",
            "Frost clone = Blizzard/root, Fire clone = Fire Blast, Arcane clone = Time Stop/teleport - interrupt where possible.",
          },
        },
        {
          ["name"] = "Anomalus",
          ["summary"] = "Spawns Chaotic Rifts that make him IMMUNE while active; rifts spawn Crazed Mana-Wraiths.",
          ["positioning"] = "Stack near boss for fast rift swaps; ranged kill rifts on spawn.",
          ["tank"] = {
            "Hold boss; not much movement.",
            "Pick up Mana-Wraith adds from rifts.",
          },
          ["healer"] = {
            "Dispel Arcane Attraction (pulls player to rift) off targets.",
            "Steady raid damage from rift AoE - keep topped.",
          },
          ["dps"] = {
            "Boss is IMMUNE while a Chaotic Rift is open - swap to kill the rift instantly.",
            "Kill Mana-Wraith adds spawning from rifts.",
            "Resume boss DPS only after rift closes.",
          },
        },
        {
          ["name"] = "Ormorok the Tree-Shaper",
          ["summary"] = "Crystal Spikes erupt in lines from random players (knock-up); casts Spell Reflection; Frenzy at 25%.",
          ["positioning"] = "Spread out so Crystal Spike lines don't chain; melee/ranged on flanks.",
          ["tank"] = {
            "Face boss away; hold through Frenzy (haste buff) at 25%.",
            "Trample is a frontal charge - keep group out of front.",
          },
          ["healer"] = {
            "Crystal Spikes hit and knock up - heal spike damage; spread to avoid.",
            "Tank takes more during 25% Frenzy.",
          },
          ["dps"] = {
            "STOP casting during Spell Reflection (reflects spells back) - melee through it or wait it out.",
            "Spread to avoid Crystal Spike lines erupting under you.",
            "Burn through Frenzy at 25%.",
          },
        },
        {
          ["name"] = "Keristrasza",
          ["summary"] = "Intense Cold: standing still stacks heavy frost dmg - NEVER stop moving. Roots players; Crystalfire Breath frontal.",
          ["positioning"] = "Everyone strafe/move constantly; non-tanks attack from the SIDES (avoid breath + tail).",
          ["tank"] = {
            "Keep moving even while tanking (jump/strafe) to drop Intense Cold stacks.",
            "Face Crystalfire Breath away from group.",
          },
          ["healer"] = {
            "Move while casting - your own Intense Cold will kill you if static.",
            "Dispel Crystal Chains (root) fast so rooted players can move again.",
            "Watch for 25% enrage burst.",
          },
          ["dps"] = {
            "Constant movement - jumping resets the Intense Cold stack.",
            "Attack from the sides; avoid frontal Crystalfire Breath and Tail Sweep.",
            "Achievement 'Intense Cold': never let your stack exceed 2.",
            "She enrages at 25% - blow cooldowns and finish.",
          },
        },
      },
    },
    {
      ["name"] = "Azjol-Nerub",
      ["aliases"] = {
        "AN",
        "Azjol",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 72-74; Heroic 80",
      ["generalTips"] = {
        "Short 3-boss dungeon, spider/nerubian themed.",
        "Add control is the whole dungeon - AoE and interrupts matter.",
        "Hadronox fight relies on letting the boss clear its own adds in the tunnel.",
      },
      ["bosses"] = {
        {
          ["name"] = "Krik'thir the Gatewatcher",
          ["summary"] = "Watcher adds (Gashtooth/Skitterer/etc.) before/with boss; Mind Flay + Curse of Fatigue; Frenzy at low HP.",
          ["positioning"] = "Tank boss + adds together; ranged spread slightly for Web Wrap.",
          ["tank"] = {
            "Grab the 3 named watchers and Skittering Swarmers - high add count.",
            "Pop a cooldown on Frenzy near death.",
          },
          ["healer"] = {
            "Heavy AoE add damage - strong throughput needed.",
            "Dispel Curse of Fatigue (movement/cast slow) if able.",
          },
          ["dps"] = {
            "AoE down the Swarmers/Skitterers fast; interrupt Krik'thir's Mind Flay.",
            "Kill the watcher adds before tunneling boss.",
          },
        },
        {
          ["name"] = "Hadronox",
          ["summary"] = "Climbs up tunnel fighting endless spider adds; Web Grab pulls everyone in; Leech Poison heals him; Acid Clouds on ground.",
          ["positioning"] = "Let Hadronox ascend and clear his own adds; pull him to the top ramp/doorway only when adds are dead.",
          ["tank"] = {
            "Face boss away from group (Pierce Armor); kite up the tunnel as he eats his adds.",
            "Engage for real near the top once accumulated adds are cleared.",
          },
          ["healer"] = {
            "Dispel Leech Poison FAST - it heals him massively, especially after Web Grab pulls everyone in.",
            "Heal AoE from Acid Cloud and add cleave.",
          },
          ["dps"] = {
            "Don't burn the boss too early - let him kill the spider waves himself.",
            "After Web Grab pull-in, ranged run back out; everyone move out of Acid Clouds.",
            "Heroic achievement 'Watch Him Die': kill him before he webs/destroys the top doors.",
          },
        },
        {
          ["name"] = "Anub'arak",
          ["summary"] = "Pound (huge tank hit + stun); submerges at 75/50/25% spawning Nerubians; Impale spikes + Leeching Swarm.",
          ["positioning"] = "Face boss AWAY from party; spread for Impale; stay mobile while he's burrowed.",
          ["tank"] = {
            "Face away - Pound (frontal, ~18k + 4s stun) must not hit the group.",
            "Pre-pop cooldown for Pound casts.",
            "Re-grab boss after each emerge.",
          },
          ["healer"] = {
            "Pound is a massive tank spike - pre-heal the 3s cast.",
            "Leeching Swarm drains health % - keep everyone above the drain.",
            "Heal add-phase damage during submerge.",
          },
          ["dps"] = {
            "During submerge (75/50/25%), kill the spawned Nerubians to force him back up.",
            "Spread for Impale (spikes through floor, knock-up) while he's burrowed.",
            "Heroic 'Hadronox Denied'/speed: kill within ~4 min for the Gauntlet achievement.",
          },
        },
      },
    },
    {
      ["name"] = "Ahn'kahet: The Old Kingdom",
      ["aliases"] = {
        "AK",
        "Old Kingdom",
        "OK",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 73-75; Heroic 80",
      ["generalTips"] = {
        "Sprawling nerubian/Old God dungeon; 3 core bosses + 2 optional (Amanitar, Jedoga depending on path).",
        "Disease/poison dispels are valuable throughout.",
        "Herald Volazj's Insanity is the standout mechanic - know your clone fight.",
      },
      ["bosses"] = {
        {
          ["name"] = "Elder Nadox",
          ["summary"] = "Spawns Ahn'kahar Guardians; while a Guardian is alive Nadox is IMMUNE (Guardian Aura). Brood Plague disease + Brood Rage on adds.",
          ["positioning"] = "Tank boss centrally; melee can cleave adds; ranged kill Guardian on spawn.",
          ["tank"] = {
            "Pick up the Swarm Guards and the elite Ahn'kahar Guardian adds.",
            "Hold boss while DPS swaps to Guardians.",
          },
          ["healer"] = {
            "Dispel Brood Plague (stacking disease DoT) off the group constantly.",
            "AoE add damage to heal through.",
          },
          ["dps"] = {
            "Kill the Ahn'kahar Guardian immediately - boss is immune while it lives.",
            "Heroic: a Guardian respawns on a timer - be ready to swap.",
            "Achievement 'Respect Your Elders': kill him before any Guardian spawns (rush DPS).",
          },
        },
        {
          ["name"] = "Prince Taldaram",
          ["summary"] = "Conjure Flame Sphere (slow-moving fire orbs) + Embrace of the Vampyr: vanishes and stun-drains a random player who needs freeing via damage.",
          ["positioning"] = "Spread to dodge Flame Spheres; keep clear lanes between players.",
          ["tank"] = {
            "Re-establish threat after each Vanish/Embrace.",
            "Keep boss steady so DPS can find the embraced target.",
          },
          ["healer"] = {
            "Embraced player takes a draining stun - heal them until freed.",
            "Move out of Flame Sphere paths while casting.",
          },
          ["dps"] = {
            "Immediately burn the player caught in Embrace of the Vampyr to free them.",
            "Strafe out of the two Conjured Flame Spheres orbiting the room.",
          },
        },
        {
          ["name"] = "Jedoga Shadowseeker",
          ["summary"] = "Adds initiation phase: a Twilight Volunteer runs to her to be sacrificed for Gift of the Herald (big buff); interrupt/kill it.",
          ["positioning"] = "Ranged spread for Lightning Bolt/Thundershock; melee avoid Cyclone Strike point-blank AoE.",
          ["tank"] = {
            "Hold boss during ground phase; she ascends periodically (untauntable in air).",
            "Re-grab when she lands.",
          },
          ["healer"] = {
            "Thundershock is a nova AoE - keep group topped.",
            "Heal through if a Volunteer reaches her (boss buffed/empowered).",
          },
          ["dps"] = {
            "When she ascends, STOP the chosen Twilight Volunteer running to her - kill it before contact or she gains Gift of the Herald.",
            "Interrupt her Lightning Bolt.",
          },
        },
        {
          ["name"] = "Amanitar",
          ["summary"] = "Heroic-only. Spawns Healthy (good) and Poisonous (bad) Mushrooms; killing a Healthy mushroom drops a cleanse zone for the Mini debuff. Entangling Roots + Venom Bolt Volley.",
          ["positioning"] = "Tank boss away from mushroom clusters; group stands in Healthy mushroom burst to cleanse Mini.",
          ["tank"] = {
            "Move boss away from spawning Poisonous Mushrooms.",
            "Hold through Bash stun.",
          },
          ["healer"] = {
            "Dispel Mini (shrinks/weakens) and Entangling Roots; AoE Venom Bolt damage.",
            "Direct group to stand in dying Healthy Mushroom cloud to remove Mini.",
          },
          ["dps"] = {
            "Kill Healthy Mushrooms to create the cleanse cloud; do NOT kill Poisonous ones (they explode).",
            "Heroic only - watch which mushroom is which.",
          },
        },
        {
          ["name"] = "Herald Volazj",
          ["summary"] = "At 66% and 33% casts Insanity: each player is phased alone to fight shadow clones of the whole party; clear them to rejoin.",
          ["positioning"] = "Spread for Shadow Bolt Volley; in Insanity, fight your clones in your own phase.",
          ["tank"] = {
            "In Insanity, your clones have low HP - DPS them; you may need to self-sustain.",
            "Re-grab boss after each Insanity phase ends.",
          },
          ["healer"] = {
            "During Insanity you must survive solo (clones of party) - use everything to stay alive, then help others.",
            "Between phases, heal Shadow Bolt Volley / Mind Flay damage.",
          },
          ["dps"] = {
            "In Insanity, kill your set of clones (they have reduced HP); focus-fire to exit phase faster.",
            "Once out, help party members still phased.",
            "Interrupt Mind Flay; spread for Shadow Bolt Volley.",
          },
        },
      },
    },
    {
      ["name"] = "Drak'Tharon Keep",
      ["aliases"] = {
        "DTK",
        "Drak",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 74-76; Heroic 80",
      ["generalTips"] = {
        "Drakkari troll keep; lots of trash with corpse/explosion themes.",
        "Bring fear protection (King Dred) and interrupts (Novos).",
        "AoE is strong here - many add-heavy fights.",
      },
      ["bosses"] = {
        {
          ["name"] = "Trollgore",
          ["summary"] = "Invading Drakkari adds run in; Consume stacks his damage by eating corpses; Corpse Explode detonates corpses for AoE.",
          ["positioning"] = "Tank boss away from add piles; group avoids standing in/near corpses.",
          ["tank"] = {
            "Hold boss + the streaming Drakkari Invaders.",
            "Face boss away so Crush/Infected Wound bleed hits only you.",
          },
          ["healer"] = {
            "Corpse Explode AoE + stacking Consume = rising raid/tank damage - DPS race.",
            "Keep tank topped through Infected Wound bleed.",
          },
          ["dps"] = {
            "Don't let corpses pile - Consume buffs him per body eaten; kill boss before stacks snowball.",
            "Avoid standing in Corpse Explode radius.",
            "AoE the invading adds.",
          },
        },
        {
          ["name"] = "Novos the Summoner",
          ["summary"] = "Shielded by Arcane Field; summon channel sends waves of undead (incl. Crystal Handlers) - kill the 4 Crystal Handlers to drop his shield.",
          ["positioning"] = "Tank holds the chamber; assign ranged to pick off climbing adds before they reach the platform.",
          ["tank"] = {
            "Grab the summoned undead waves (Risen/Fetid/Hulking adds).",
            "Once shield drops, hold boss and finish; he resummons if you stall.",
          },
          ["healer"] = {
            "Move out of his Blizzard; heal steady add-wave damage during shield phase.",
            "Dispel/heal Wrath of Misery and Frostbolt damage.",
          },
          ["dps"] = {
            "Kill the 4 Crystal Handlers - boss is IMMUNE (Arcane Field) until they die.",
            "Control/AoE the undead so they don't overwhelm; then burn boss.",
            "Heroic 'Oh Novos!': don't let any add reach the top - CC/AoE the ramps.",
          },
        },
        {
          ["name"] = "King Dred",
          ["summary"] = "Devilsaur raptor; brutal tank damage (Grievous Bite bleed + Mangling/Piercing Slash); Bellowing Roar fear; calls Raptor reinforcements.",
          ["positioning"] = "Clear nearby roaming raptors BEFORE pulling; tank in a corner so fear doesn't drag you into adds.",
          ["tank"] = {
            "Massive tank damage - pop cooldowns; tank near a wall to limit fear movement.",
            "Grievous Bite is a healing-reducing bleed - keep it from stacking high.",
          },
          ["healer"] = {
            "Hardest tank-damage fight here - spam tank, watch Grievous Bite (reduces healing received).",
            "Be ready to heal through Bellowing Roar fear scatter.",
          },
          ["dps"] = {
            "Use fear breaks/immunities (Berserker Rage, tremor, etc.) for Bellowing Roar.",
            "Pre-clear the patrolling raptors so feared players don't pull more.",
            "Heroic 'Better Off Dred': let 6 Drakkari Guardians (raptors) be alive when he dies.",
          },
        },
        {
          ["name"] = "The Prophet Tharon'ja",
          ["summary"] = "P1 caster (Curse of Life, Rain of Fire, Shadow Volley). P2 Gift of Tharon'ja: strips your gear/abilities, turns party to skeletons with role-swap skills.",
          ["positioning"] = "P1 spread for Rain of Fire; P2 reposition for Eye Beam/Lightning Breath frontal.",
          ["tank"] = {
            "P2: use the skeleton Taunt + Bone Armor to keep aggro while transformed.",
            "P1: face boss away (Shadow Volley/Decay Flesh).",
          },
          ["healer"] = {
            "P2: you lose normal heals - use 'Touch of Life' skeleton ability to heal.",
            "P1: dispel/heal Curse of Life (heals get reversed) and Rain of Fire.",
          },
          ["dps"] = {
            "P2: use 'Slaying Strike' skeleton ability; survive until Return Flesh ends the phase.",
            "P1: interrupt/spread for Shadow Volley; move out of Rain of Fire.",
            "Curse of Life in P1 turns healing into damage - dispel it.",
          },
        },
      },
    },
    {
      ["name"] = "The Violet Hold",
      ["aliases"] = {
        "VH",
        "Violet",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 75-77; Heroic 80",
      ["generalTips"] = {
        "Wave-defense event: portals spawn add waves; mini-boss after wave 6 and wave 12 (random of Erekem/Moragg/Ichoron/Xevozz/Lavanthor/Zuramat), Cyanigosa always after wave 18.",
        "Stack on the central portal pad; assign someone to call which portal spawns next.",
        "Activate the Defense Crystals (NPC console) only if struggling - skipping them is required for the 'Defenseless' achievement.",
        "Each random mini-boss is one of six - know all six since you don't pick.",
      },
      ["bosses"] = {
        {
          ["name"] = "Erekem",
          ["summary"] = "Arena boss with 2 Vrykul healer adds (Earth Shield/Chain Heal); Bloodlust enrage. Kill/interrupt the healers first.",
          ["positioning"] = "Spread boss and his 2 adds enough to interrupt all heal casts.",
          ["tank"] = {
            "Grab Erekem + both Vrykul adds; keep them grouped for interrupt rotation.",
          },
          ["healer"] = {
            "Heal through Bloodlust burst once adds are down.",
            "Cleanse if able.",
          },
          ["dps"] = {
            "Kill/CC the 2 healer adds first and INTERRUPT their Chain Heal / Earth Shock.",
            "Purge Earth Shield off adds.",
          },
        },
        {
          ["name"] = "Moragg",
          ["summary"] = "Simple beholder; heavy DoTs via Optic Link, Ray of Pain, Ray of Suffering, Corrosive Saliva.",
          ["positioning"] = "Tank anywhere; group stays near for healing.",
          ["tank"] = {
            "Straightforward tank-and-spank; hold threat.",
          },
          ["healer"] = {
            "Keep DoT-debuffed targets (Optic Link/Ray of Pain) topped - sustained damage fight.",
          },
          ["dps"] = {
            "Pure burn; nothing to dodge - just DPS down.",
          },
        },
        {
          ["name"] = "Ichoron",
          ["summary"] = "Water elemental with Protective Bubble (must land ~35 hits to pop); on burst splits into Ichor Globules that re-merge and heal her if they reach her.",
          ["positioning"] = "Stay SPREAD so Water Bolt Volley/Water Blast don't chain; surround to intercept globules.",
          ["tank"] = {
            "Hold boss; help control globule movement toward her.",
          },
          ["healer"] = {
            "Heal Water Bolt Volley AoE; stay spread.",
          },
          ["dps"] = {
            "Break the Protective Bubble fast, then KILL the 10 Ichor Globules before they reach Ichoron (each merge heals her + can Frenzy).",
            "Achievement 'Dehydration': let zero globules merge back.",
          },
        },
        {
          ["name"] = "Xevozz",
          ["summary"] = "Ethereal caster; Arcane Buffet/Barrage Volley raid damage; summons Ethereal Spheres that chase and must be kited away.",
          ["positioning"] = "Keep moving - kite the Ethereal Spheres away from the group at all times.",
          ["tank"] = {
            "Hold boss; help kite spheres.",
          },
          ["healer"] = {
            "Heal through Arcane Barrage Volley; stay mobile.",
          },
          ["dps"] = {
            "Constantly move away from summoned Ethereal Spheres (they buff him / explode if they reach him).",
            "Burn boss while kiting.",
          },
        },
        {
          ["name"] = "Lavanthor",
          ["summary"] = "Fire elemental; Flame Breath frontal cone; Lava Burn drops persistent fire patches on random players.",
          ["positioning"] = "Tank faces boss away from group; everyone avoid frontal cone and fire pools.",
          ["tank"] = {
            "Face Lavanthor AWAY - Flame Breath is a frontal cone.",
          },
          ["healer"] = {
            "Heal Lava Burn fire-patch DoT; move out of pools yourself.",
          },
          ["dps"] = {
            "Stay out of the frontal Flame Breath and move off Lava Burn fire patches.",
          },
        },
        {
          ["name"] = "Zuramat the Obliterator",
          ["summary"] = "Void caster; summons Void Sentry adds; Shroud of Darkness; Void Shift phases a player out (must survive/be healed).",
          ["positioning"] = "Stack-ish for AoE on Void Sentries; keep party near for healing.",
          ["tank"] = {
            "Pick up the Void Sentry adds quickly.",
          },
          ["healer"] = {
            "Keep party at FULL health - Void Shift can be lethal on a low target; dispel Shroud of Darkness if able.",
          },
          ["dps"] = {
            "AoE the Void Sentry adds down fast each spawn, then resume boss.",
            "Heroic 'Zombiefest!': kill many adds.",
          },
        },
        {
          ["name"] = "Cyanigosa",
          ["summary"] = "Final boss blue dragon (always after wave 18); Crystalfire/Uncontrollable Energy frontal + Tail Sweep rear; Arcane Vacuum pulls all in then drops Blizzard.",
          ["positioning"] = "Tank faces her away from group; non-tanks attack from the SIDES; after Arcane Vacuum re-spread and exit Blizzard.",
          ["tank"] = {
            "Face dragon away (frontal breath); hold steady.",
          },
          ["healer"] = {
            "Heal Mana Destruction / breath damage; move out of Blizzard after the vacuum pull.",
          },
          ["dps"] = {
            "Attack from the sides (avoid frontal breath + Tail Sweep).",
            "When Arcane Vacuum pulls everyone in, immediately spread back out and get off the Blizzard patch.",
          },
        },
      },
    },
    {
      ["name"] = "Gundrak",
      ["aliases"] = {
        "GD",
        "Gun'drak",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "76-80",
      ["generalTips"] = {
        "Activate the 3 altars behind Slad'ran, Drakkari Colossus, and Moorabi to open Gal'darah without backtracking.",
        "Eck the Ferocious is heroic-only and optional (skippable via the elemental gauntlet).",
      },
      ["bosses"] = {
        {
          ["name"] = "Slad'ran",
          ["summary"] = "Snake boss: wraps players in snakes and casts Poison Nova.",
          ["positioning"] = "Tank boss in place; party stays spread, ranged behind a corner to LoS Poison Nova.",
          ["tank"] = {
            "Hold boss steady, don't chase",
            "Help free anyone Snake-Wrapped if DPS is slow",
          },
          ["healer"] = {
            "Spot-heal Snake Wrap victims (they're rooted + ticking)",
            "Top group before Poison Nova",
          },
          ["dps"] = {
            "Kill summoned snakes and free Snake-Wrapped players ASAP",
            "Move out of Poison Nova / LoS it",
          },
        },
        {
          ["name"] = "Moorabi",
          ["summary"] = "Casts Transformation to become a mammoth (big damage buff); speeds up as HP drops via Mojo Frenzy.",
          ["positioning"] = "Standard melee stack; nothing to dodge.",
          ["tank"] = {
            "Hold threat; expect a damage spike if transform lands",
          },
          ["healer"] = {
            "Heal harder as Mojo Frenzy stacks late in fight",
          },
          ["dps"] = {
            "INTERRUPT every Transformation cast (top priority)",
            "Burn fast — Mojo Frenzy makes interrupts harder over time",
          },
        },
        {
          ["name"] = "Drakkari Colossus",
          ["summary"] = "Splits out a Living Mojo elemental at 50% and again near death; kill the mojo to end it.",
          ["positioning"] = "Tank both forms; party avoids ground puddles.",
          ["tank"] = {
            "Pick up the Living Mojo immediately when it spawns at 50%",
          },
          ["healer"] = {
            "Move out of mojo puddles (high damage)",
          },
          ["dps"] = {
            "Swap to the Living Mojo when it splits off; killing it ends the encounter",
            "Avoid puddles",
          },
        },
        {
          ["name"] = "Gal'darah",
          ["summary"] = "Final boss; alternates troll and rhino forms. Rhino does Stampede/Whirling Slash; troll does Impaling Charge + bleed.",
          ["positioning"] = "Spread slightly; ranged out of Impaling Charge line.",
          ["tank"] = {
            "Reposition through form swaps (Stampede/Whirling Slash)",
            "Keep boss facing away from group",
          },
          ["healer"] = {
            "Burst-heal melee through bleeds and Whirling Slash",
          },
          ["dps"] = {
            "Watch Impaling Charge target line; melee mind the rhino Whirlwind",
          },
        },
        {
          ["name"] = "Eck the Ferocious",
          ["summary"] = "Optional heroic-only; leaps to a random target (threat reset) and uses frontal Eck Spit.",
          ["positioning"] = "Keep boss faced away; ranged spread from his leap target.",
          ["tank"] = {
            "Re-taunt instantly after Eck Spring (threat reset) and reposition",
            "Face him away from group",
          },
          ["healer"] = {
            "Watch whoever he leaps to; cleanse/heal Eck Spit damage",
          },
          ["dps"] = {
            "Avoid frontal Eck Spit cone",
          },
        },
      },
    },
    {
      ["name"] = "Halls of Stone",
      ["aliases"] = {
        "HoS",
        "Stone",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "76-80",
      ["generalTips"] = {
        "Tribunal of Ages is a defend-Brann event that unlocks the door to Sjonnir; you must protect Brann while he hacks the console.",
        "Maiden of Grief and Krystallus can be done in either order.",
      },
      ["bosses"] = {
        {
          ["name"] = "Krystallus",
          ["summary"] = "Ground Slam knocks back + petrifies, then Shatter does proximity AoE; also Boulder/Ground Spike.",
          ["positioning"] = "Stay spread at all times — Shatter and Boulder punish stacking.",
          ["tank"] = {
            "Keep boss put; expect knockback from Ground Slam",
          },
          ["healer"] = {
            "Pre-heal before Shatter; damage scales with how clustered players are",
          },
          ["dps"] = {
            "Spread out — Shatter hits harder the closer you are to others",
            "Keep moving after Ground Slam",
          },
        },
        {
          ["name"] = "Maiden of Grief",
          ["summary"] = "Storm of Grief void zone on the floor; Shock of Sorrow is a group stun that also wipes threat.",
          ["positioning"] = "Tank holds her in place; party stays out of the black Storm of Grief circle.",
          ["tank"] = {
            "Re-taunt immediately after Shock of Sorrow (it wipes aggro)",
          },
          ["healer"] = {
            "Heal through Shock of Sorrow shadow damage",
            "Stay out of Storm of Grief void zone",
          },
          ["dps"] = {
            "Move out of Storm of Grief; avoid Pillar of Woe",
          },
        },
        {
          ["name"] = "Tribunal of Ages",
          ["summary"] = "Defend-Brann event: waves of Dark Rune adds (Protectors/Sentinels/Watchers) plus Searing Gaze / Lightning Grid hazards.",
          ["positioning"] = "Body-block adds before they reach Brann; avoid ground AoE grids.",
          ["tank"] = {
            "Grab every wave of adds fast; keep them off Brann",
          },
          ["healer"] = {
            "Heal Brann if adds reach him; dodge Lightning Grid / Searing Gaze",
          },
          ["dps"] = {
            "AoE/burn adds before they touch Brann; CC casters",
            "Avoid floor AoE effects",
          },
        },
        {
          ["name"] = "Sjonnir the Ironshaper",
          ["summary"] = "Spawns dwarf adds from side tubes; Lightning Arc + chain Static Overload; deals heavy melee proximity damage.",
          ["positioning"] = "Ranged/healer stay well back — he hits hard up close. Tank controls adds.",
          ["tank"] = {
            "Manage constant add stream from the tubes while holding the boss",
          },
          ["healer"] = {
            "Stand far from Sjonnir (high nearby damage); dispel/heal Lightning Arc",
          },
          ["dps"] = {
            "Ranged keep distance from the boss; help clear adds",
            "Burn boss fast during late frenzy",
          },
        },
      },
    },
    {
      ["name"] = "Halls of Lightning",
      ["aliases"] = {
        "HoL",
        "Lightning",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "79-80",
      ["generalTips"] = {
        "Loken is the signature fight: a positioning puzzle (stack in melee for Pulsing Shockwave, spread out for Lightning Nova).",
      },
      ["bosses"] = {
        {
          ["name"] = "General Bjarngrim",
          ["summary"] = "Patrols with adds; cycles Battle/Defensive/Berserker stances (Cleave, Knock Away, Whirlwind/Mortal Strike) and gains an Electrical Charge buff.",
          ["positioning"] = "Pull adds aside and kill them first (they heal him). Stay out of Whirlwind.",
          ["tank"] = {
            "Watch the stance: Berserker = Whirlwind, Defensive = Knock Away",
            "Pick up the patrolling adds",
          },
          ["healer"] = {
            "Spike-heal during Whirlwind and while his Electrical Charge buff is up",
          },
          ["dps"] = {
            "Kill adds first — they heal him",
            "Get out of melee during Whirlwind",
          },
        },
        {
          ["name"] = "Volkhan",
          ["summary"] = "Spawns Molten/Brittle Golem adds; Shattering Stomp shatters golems for big AoE if they aren't killed.",
          ["positioning"] = "Spread to limit Shattering Stomp splash; drag golems away from group.",
          ["tank"] = {
            "Tank boss + golems together; reposition off corpses",
          },
          ["healer"] = {
            "Brace for AoE burst when Shattering Stomp hits live golems",
          },
          ["dps"] = {
            "Kill the golems before they harden and Volkhan stomps them",
          },
        },
        {
          ["name"] = "Ionar",
          ["summary"] = "At ~50% Disperses into Spark of Ionar adds that must be killed/kited; Static Overload + Ball Lightning on players.",
          ["positioning"] = "Stay spread; Static Overload targets must run away from allies.",
          ["tank"] = {
            "Maintain spread to avoid overlapping lightning",
          },
          ["healer"] = {
            "Heal Static Overload / Ball Lightning targets; burst during Disperse phase",
          },
          ["dps"] = {
            "If you get Static Overload, run away from the group",
            "Kill Sparks fast after Disperse",
          },
        },
        {
          ["name"] = "Loken",
          ["summary"] = "Pulsing Shockwave aura does MORE damage the farther you are; Lightning Nova does more damage the closer you are.",
          ["positioning"] = "STACK in melee on Loken normally; SPREAD/run out only during Lightning Nova cast.",
          ["tank"] = {
            "Tank boss and keep the group stacked tight in melee range",
          },
          ["healer"] = {
            "Stand in melee (Pulsing Shockwave punishes range); pre-heal Lightning Nova",
          },
          ["dps"] = {
            "Stay stacked on Loken; run out to spread for Lightning Nova, then return",
          },
        },
      },
    },
    {
      ["name"] = "The Oculus",
      ["aliases"] = {
        "Oc",
        "Occu",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "78-80",
      ["generalTips"] = {
        "After Drakos, the last two bosses are fought on drake vehicles: Ruby = tank, Amber = DPS, Emerald = healer.",
        "Ruby Drake: Martyr/Evasive Maneuvers (threat + absorb); Amber Drake: Shock Lance + Stop Time; Emerald Drake: Touch the Nightmare (drain) + Leeching Poison (group heal).",
        "On Eregos, an Amber Drake must Stop Time during his Enraged Assault.",
      },
      ["bosses"] = {
        {
          ["name"] = "Drakos the Interrogator",
          ["summary"] = "Last ground fight. Magic Pull yanks everyone together; Unstable Spheres spawn and explode for AoE.",
          ["positioning"] = "Spread after each Magic Pull; keep moving away from Unstable Spheres.",
          ["tank"] = {
            "Hold threat through Magic Pulls; reposition out of spheres",
          },
          ["healer"] = {
            "Heal pull/sphere AoE; stay mobile",
          },
          ["dps"] = {
            "After Magic Pull re-spread; avoid/kite Unstable Spheres",
          },
        },
        {
          ["name"] = "Varos Cloudstrider",
          ["summary"] = "First drake-vehicle fight. Call Azure Ring Captain fires sweeping Energize beams across the platform.",
          ["positioning"] = "On drakes — fly to dodge the rotating beams; spread out.",
          ["tank"] = {
            "Ruby Drake: build threat, use Evasive Maneuvers to absorb hits",
          },
          ["healer"] = {
            "Emerald Drake: spam Leeching Poison / drain to keep drakes topped through beams",
          },
          ["dps"] = {
            "Amber Drake: nuke with Shock Lance while avoiding the beams",
          },
        },
        {
          ["name"] = "Mage-Lord Urom",
          ["summary"] = "Teleports through 3 side rooms (clearing add packs) then settles center; casts Time Bomb and Empowered Arcane Explosion.",
          ["positioning"] = "Ground fight (no drakes). Hide behind pillars / run out for the big Arcane Explosion.",
          ["tank"] = {
            "Gather adds in each teleport room; reposition for the center cast",
          },
          ["healer"] = {
            "Heal Time Bomb victim before it detonates on nearby players",
          },
          ["dps"] = {
            "Move away / LoS Empowered Arcane Explosion; spread for Time Bomb",
          },
        },
        {
          ["name"] = "Ley-Guardian Eregos",
          ["summary"] = "Final drake-vehicle fight. Arcane Volley/Barrage AoE; Planar Shift makes him immune + summons Azure Ley-Whelps; Enraged Assault.",
          ["positioning"] = "Stay on drakes; dodge chasing Planar Anomalies; kill whelps during Planar Shift.",
          ["tank"] = {
            "Ruby Drake: hold threat; pop Martyr to redirect drake damage for the kill",
          },
          ["healer"] = {
            "Emerald Drake: keep all drakes healed through Arcane Volley/Barrage",
          },
          ["dps"] = {
            "Amber Drake: Stop Time during Enraged Assault; kill Azure Ley-Whelps in Planar Shift",
            "Avoid Planar Anomalies",
          },
        },
      },
    },
    {
      ["name"] = "Utgarde Pinnacle",
      ["aliases"] = {
        "UP",
        "Pinnacle",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "78-80",
      ["generalTips"] = {
        "Skadi is a phase-1 gauntlet: loot Harpoons from Ymirjar Harpooners and fire 3 at his drake Grauf to ground him.",
      },
      ["bosses"] = {
        {
          ["name"] = "Svala Sorrowgrave",
          ["summary"] = "Ritual of the Sword: teleports a random player up for sacrifice while 3 Ritual Channelers cast on them (heroic).",
          ["positioning"] = "Free the abducted player; ranged keep DPS on Svala while she's aloft.",
          ["tank"] = {
            "Hold Svala; expect Sinister Strike spike damage",
          },
          ["healer"] = {
            "Keep the sacrificed player alive until adds die; pre-cooldown the ritual",
          },
          ["dps"] = {
            "Kill the 3 Ritual Channelers fast to save the abducted player",
          },
        },
        {
          ["name"] = "Gortok Palehoof",
          ["summary"] = "Orb releases 4 beast adds one at a time (Furbolg, Worgen, Rhino, Jormungar), then Palehoof himself; frontal Arcing Smash + Impale.",
          ["positioning"] = "Stay out of his frontal cone; nuke each add before the next.",
          ["tank"] = {
            "Pick up each freed beast immediately; keep boss faced away (Arcing Smash/Impale frontal)",
          },
          ["healer"] = {
            "Heal through Crush stuns on the tank",
          },
          ["dps"] = {
            "Focus one add at a time; avoid standing in front",
          },
        },
        {
          ["name"] = "Skadi the Ruthless",
          ["summary"] = "P1 gauntlet on his drake Grauf (Freezing Cloud breath); P2 ground fight with Whirlwind, Poisoned Spear, Crush stun.",
          ["positioning"] = "P1: dodge Grauf's freezing breath, get a Harpoon, fire 3 from the launchers. P2: out of Whirlwind.",
          ["tank"] = {
            "P2: hold Skadi, manage Crush stuns and reposition for Whirlwind",
          },
          ["healer"] = {
            "P1: heal freezing-breath damage; P2: cleanse Poisoned Spear, heal Crush",
          },
          ["dps"] = {
            "P1: kill Ymirjar Harpooners for Harpoons, fire 3 at Grauf",
            "P2: avoid Whirlwind",
          },
        },
        {
          ["name"] = "King Ymiron",
          ["summary"] = "Bane buff: if you die while Bane is up you stay dead — stop DPS or remove it. Dark Slash hits for half current HP; Fetid Rot disease; ancestor adds.",
          ["positioning"] = "Standard; spread modestly for Fetid Rot.",
          ["tank"] = {
            "Survive Dark Slash (deals ~50% of current HP) — keep HP high before it",
          },
          ["healer"] = {
            "Top tank before Dark Slash; dispel Fetid Rot; watch for Bane",
          },
          ["dps"] = {
            "Stop attacking during Bane (or remove it) so dead players can be rezzed",
          },
        },
      },
    },
    {
      ["name"] = "The Culling of Stratholme",
      ["aliases"] = {
        "CoS",
        "Strat",
        "Culling",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "78-80",
      ["generalTips"] = {
        "Escort Arthas through zombie waves to 10 crates; bosses spawn between/at the end of waves.",
        "Heroic: defeat the Infinite Corruptor within 25 minutes (talk to the Crusader to start the timer) for the Bronze Drake mount.",
      },
      ["bosses"] = {
        {
          ["name"] = "Meathook",
          ["summary"] = "Constricting Chains roots/chains a player; Disease Expulsion interrupts caster spells.",
          ["positioning"] = "Casters keep some distance from disease; melee on boss.",
          ["tank"] = {
            "Hold threat; position so chained players aren't isolated",
          },
          ["healer"] = {
            "Heal chained players; expect interrupt from Disease Expulsion",
          },
          ["dps"] = {
            "Kill any adds first; casters mind Disease Expulsion interrupts",
          },
        },
        {
          ["name"] = "Salramm the Fleshcrafter",
          ["summary"] = "Summons ghouls then Explode Ghoul for AoE; Curse of Twisted Flesh, Steal Flesh, Shadow Bolt Volley.",
          ["positioning"] = "Spread before ghoul explosions; don't cluster.",
          ["tank"] = {
            "Pick up summoned ghouls",
          },
          ["healer"] = {
            "Dispel Curse of Twisted Flesh; heal through Shadow Bolt Volley",
          },
          ["dps"] = {
            "Kill ghouls fast; interrupt Steal Flesh; spread to limit Explode Ghoul AoE",
          },
        },
        {
          ["name"] = "Chrono-Lord Epoch",
          ["summary"] = "Time Stop AoE stun, Time Warp slow, Curse of Exertion (drains mana), and a heavy Time Step-style tank hit.",
          ["positioning"] = "Standard melee; nothing major to dodge.",
          ["tank"] = {
            "Brace for his hard-hitting tank buster after Time Stop",
          },
          ["healer"] = {
            "Burst-heal the tank after stun; watch Curse of Exertion mana drain",
          },
          ["dps"] = {
            "Remove/handle stacking debuffs; keep DPS up through Time Warp slow",
          },
        },
        {
          ["name"] = "Mal'Ganis",
          ["summary"] = "Final boss; Carrion Swarm frontal AoE, Sleep on a player, Vampiric Touch (heals him + reduces target healing).",
          ["positioning"] = "Spread around the boss to minimize Carrion Swarm; stay out of its cone.",
          ["tank"] = {
            "Hold boss; manage Sleep disruptions",
          },
          ["healer"] = {
            "Dispel Sleep; counter Vampiric Touch healing reduction",
          },
          ["dps"] = {
            "Spread out around Mal'Ganis to dodge Carrion Swarm",
          },
        },
        {
          ["name"] = "Infinite Corruptor",
          ["summary"] = "Heroic-only timed boss; must be reached and killed within 25 minutes for the Bronze Drake mount.",
          ["positioning"] = "Speed-run prior wings; standard tank-and-spank when reached.",
          ["tank"] = {
            "Pull and hold quickly — the timer is the real boss",
          },
          ["healer"] = {
            "Keep group up during the rushed approach",
          },
          ["dps"] = {
            "Maximize speed through earlier waves to beat the 25-min timer",
          },
        },
      },
    },
    {
      ["name"] = "Trial of the Champion",
      ["aliases"] = {
        "ToC",
        "TotC",
        "Trial",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 78-80, Heroic 80",
      ["generalTips"] = {
        "Two random bosses: Grand Champions (joust) then either Eadric or Paletress, then Black Knight.",
        "Grab an Argent Lance and mount at the start for the joust phase.",
        "Loot drops in chests at center, not off corpses.",
      },
      ["bosses"] = {
        {
          ["name"] = "The Grand Champions (Mounted Joust)",
          ["summary"] = "Jousting on mounts, then dismounted fight vs 3 champions of random classes.",
          ["positioning"] = "Mounted: charge to build speed; dismount near group once unhorsed.",
          ["tank"] = {
            "Mounted: keep Defend (shield) up at 3 stacks at all times to cut damage.",
            "Use Shield-Breaker to strip their Defend, then Charge for big hits.",
            "Dismounted: grab all 3 champions, face them away from group, hold threat on focus kill.",
          },
          ["healer"] = {
            "Mounted: heal yourself, refresh Defend after taking hits.",
            "Dismounted: dispel poisons/curses/magic from champion classes; watch tank spike.",
            "Have interrupts ready for caster champions (Mage/Shaman).",
          },
          ["dps"] = {
            "Mounted: jousting on the trash champions; keep Defend up, Shield-Breaker then Thrust.",
            "Dismounted: single-target focus one champion at a time; do not spread damage.",
            "Interrupt and CC the caster champions (Mage Polymorph/Frostbolt, Shaman heals/totems).",
          },
        },
        {
          ["name"] = "Eadric the Pure",
          ["summary"] = "Tank-and-spank with Radiance blind and a returnable Hammer of the Righteous.",
          ["positioning"] = "Melee can step through/past him during Radiance; everyone face away on the cast.",
          ["tank"] = {
            "Pick him up fast: Vengeance makes him crit hard and he can blow up healer/ranged.",
            "On Radiance raid-warning, turn to face AWAY or you get blinded + ~4s stun.",
          },
          ["healer"] = {
            "Face away during Radiance (do not get stunned mid-heal).",
            "Dispel Hammer of Justice stun fast so the target can click the thrown hammer back.",
            "Steady tank healing; Vengeance crits cause spikes.",
          },
          ["dps"] = {
            "Turn away from boss when Radiance is announced.",
            "The player hit by Hammer of the Righteous: pick it up and throw it back at Eadric for big damage.",
          },
        },
        {
          ["name"] = "Argent Confessor Paletress",
          ["summary"] = "Priest boss; at 100% summons a Memory add that must be killed; she heals/shields.",
          ["positioning"] = "Tank Paletress where Memory can be picked up; melee swap to Memory on spawn.",
          ["tank"] = {
            "Hold Paletress, then grab the Memory add when it spawns and face it away.",
            "Memory casts Old Wounds / fears / Shadow nova - hold it on the group's kill spot.",
          },
          ["healer"] = {
            "Interrupt/dispel her Renew and Holy Smite heals.",
            "Reflective Shield reflects damage to attackers - heal through self-inflicted damage.",
            "Heal through the Memory's burst (Old Wounds bleed, fear).",
          },
          ["dps"] = {
            "When the Memory spawns, swap and burn it down fast, interrupting its casts.",
            "Do NOT cast into Reflective Shield carelessly - it reflects to you.",
            "Resume Paletress only after the Memory is dead.",
          },
        },
        {
          ["name"] = "The Black Knight",
          ["summary"] = "Three lives: skeleton -> ghoul-summoning corpse -> raging spectre with stacking bleed.",
          ["positioning"] = "P2: spread slightly so ghoul explosions do not chain; keep boss away from healer.",
          ["tank"] = {
            "P1: hold threat; healer dispels his two diseases (Icy Touch + Plague Strike) to weaken Obliterate.",
            "P3: pop cooldowns - Death's Bite is a stacking bleed and Marked for Death ramps his damage.",
          },
          ["healer"] = {
            "P1: dispel both diseases off the tank to soften Obliterate.",
            "P2: heal raid through Desecration ground + ghoul explosions.",
            "P3: big tank healing - Death's Bite stacks + Marked for Death make this the burn race.",
          },
          ["dps"] = {
            "P2: kill the summoned ghouls before they reach and explode on the group (avoid blasts).",
            "P3: full burst - race down the spectre before Death's Bite / Marked for Death overwhelm the tank.",
            "Avoid standing in Desecration (purple ground).",
          },
        },
      },
    },
    {
      ["name"] = "The Forge of Souls",
      ["aliases"] = {
        "FoS",
        "Forge",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 78-80, Heroic 80",
      ["generalTips"] = {
        "First wing of the Frozen Halls; two bosses.",
        "Bring interrupts - both bosses have key interruptible/avoidable casts.",
      },
      ["bosses"] = {
        {
          ["name"] = "Bronjahm, the Godfather of Souls",
          ["summary"] = "Soul-fragment self-heal in P1; at 35% teleports center and casts room-wide Soulstorm.",
          ["positioning"] = "Keep boss away from healer/ranged in P1; at 35% everyone STACKS on boss (eye of storm).",
          ["tank"] = {
            "Hold boss away from the group in P1.",
            "At 35% he teleports to center - get on top of him so the raid can stack safely in Soulstorm.",
          },
          ["healer"] = {
            "Stay max range in P1 (Shadow Bolt + Magic's Bane mana burn).",
            "P2 (Soulstorm): stand ON Bronjahm with the group; heal through Fear displacement chip damage.",
          },
          ["dps"] = {
            "Corrupt Soul: targeted player runs away from boss; a Corrupted Soul Fragment spawns and races to him - KILL it before it heals him (Consume Soul).",
            "Soulstorm (35%): move onto the boss; the center under him is the safe 'eye'.",
            "Interrupt Magic's Bane if able.",
          },
        },
        {
          ["name"] = "Devourer of Souls",
          ["summary"] = "Spam-interrupt Phantom Blast; stop DPS on Mirrored Soul; dodge the rotating Wailing Souls beam.",
          ["positioning"] = "Stay behind/inside the boss; on Wailing Souls move WITH the beam to stay behind the sweep.",
          ["tank"] = {
            "Keep boss faced away from group.",
            "During Wailing Souls keep the boss roughly put; the beam sweeps 90 deg - stay behind it.",
          },
          ["healer"] = {
            "Interrupt Phantom Blast (it chain-casts and hits hard).",
            "Mirrored Soul: heal the marked player (they take a share of all boss damage); warn DPS to stop.",
            "Unleashed Souls adds: heal through them (cannot be killed easily) or they get kited until despawn.",
          },
          ["dps"] = {
            "TOP PRIORITY: interrupt Phantom Blast every cast (rotate interrupts).",
            "Mirrored Soul: STOP attacking the boss - all your damage reflects and can kill the marked ally.",
            "Wailing Souls: a beam sweeps 90 deg from a random player - run behind the boss / stay behind the rotation (~10k/s if hit).",
          },
        },
      },
    },
    {
      ["name"] = "Pit of Saron",
      ["aliases"] = {
        "PoS",
        "Pit",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 78-80, Heroic 80",
      ["generalTips"] = {
        "Second wing of the Frozen Halls; three bosses plus a gauntlet escort before Tyrannus.",
        "Permafrost and frost damage are the recurring theme - bring dispels/frost cooldowns.",
      },
      ["bosses"] = {
        {
          ["name"] = "Forgemaster Garfrost",
          ["summary"] = "Stacking Permafrost frost aura; throws Saronite boulders that create LoS rocks; weapon upgrades ramp damage.",
          ["positioning"] = "Use the Saronite rock piles to break line-of-sight and drop Permafrost stacks.",
          ["tank"] = {
            "Position boss so ranged/healer can hide behind a thrown Saronite rock to reset Permafrost.",
            "Avoid Chilling Wave frontal cone; watch Thundering Stomp knockback.",
          },
          ["healer"] = {
            "Permafrost stacks raise frost damage taken (up to 30) - dispel it and hide behind rocks to reset.",
            "Burst-heal after each Forge Frostborn Mace upgrade (frost damage doubles at 66% and 33%).",
            "Dispel Deep Freeze.",
          },
          ["dps"] = {
            "Break LoS behind a Saronite boulder rock to drop your Permafrost stacks periodically.",
            "Move out of the front (Chilling Wave) and reposition after Saronite throws.",
          },
        },
        {
          ["name"] = "Ick and Krick",
          ["summary"] = "Krick rides Ick; Pursuit chases a random player; avoid poison clouds and Explosive Barrage orbs.",
          ["positioning"] = "Spread to avoid overlapping Toxic Waste puddles; keep room to kite Pursuit.",
          ["tank"] = {
            "Move Ick out of Toxic Waste poison clouds dropped under him.",
            "Reposition to keep threat during Explosive Barrage.",
          },
          ["healer"] = {
            "Heal the Pursuit target hard - they cannot fight back while kiting.",
            "Heal through Poison Nova and Explosive Barrage raid damage; dispel poison if able.",
          },
          ["dps"] = {
            "Pursuit: if the arrow targets you, RUN - Ick fixates and chases you; do not lead him into the group.",
            "Explosive Barrage: keep moving to dodge the exploding orbs.",
            "Stay out of Toxic Waste green puddles.",
          },
        },
        {
          ["name"] = "Scourgelord Tyrannus and Rimefang",
          ["summary"] = "Stop DPS on Overlord's Brand reflect; spread for Mark of Rimefang/Hoarfrost stun; manage Unholy Power.",
          ["positioning"] = "Spread out so Hoarfrost does not chain-stun; marked player runs away from the group.",
          ["tank"] = {
            "Overlord's Brand reflects your damage to the tank AND heals reflected to boss - call DPS off.",
            "Unholy Power buffs his melee ~75% - use a cooldown; kite through Rimefang's Icy Blast frost patches.",
          },
          ["healer"] = {
            "Big tank healing during Unholy Power windows.",
            "Mark of Rimefang -> Hoarfrost stuns the marked player + nearby allies; pre-heal and top after.",
            "Manage raid frost damage from Rimefang strafing.",
          },
          ["dps"] = {
            "STOP attacking the boss while Overlord's Brand is up (damage + healing reflect).",
            "If Marked by Rimefang, move away from everyone before Hoarfrost lands (it stuns nearby allies too).",
            "Avoid Rimefang's Icy Blast frost patches on the ground.",
          },
        },
      },
    },
    {
      ["name"] = "Halls of Reflection",
      ["aliases"] = {
        "HoR",
        "HoS",
        "Halls",
        "Reflection",
      },
      ["type"] = "dungeon",
      ["levelRange"] = "Normal 80, Heroic 80",
      ["generalTips"] = {
        "Third wing of the Frozen Halls; survive 10 ghost waves (5 before each of Falric/Marwyn) then escape the Lich King.",
        "Wave adds: interrupt Phantom Mage (Fireball/Frostbolt) and Ghostly Priest (Dark Mending heal); CC Shadowy Mercenary; kill Tortured Rifleman (Cursed Arrow) early.",
        "CC and interrupt-rotate the wave casters - uninterrupted heals/casts wipe groups.",
      },
      ["bosses"] = {
        {
          ["name"] = "Falric",
          ["summary"] = "Periodic Defiling Horror fear with heavy Shadow DoT; dispel Impending Despair; Hopelessness stacks lower output.",
          ["positioning"] = "Spread a bit to limit fear chaining; tank faces boss/adds away from group.",
          ["tank"] = {
            "Keep group topped is on healer, but hold threat through fears.",
            "Quivering Strike is a tank debuff - have it dispelled when possible.",
            "Save cooldowns as Hopelessness stacks (cast at 66/33/10%) cut everyone's healing/damage.",
          },
          ["healer"] = {
            "PRE-HEAL to full before Defiling Horror fear - the Shadow DoT kills feared players otherwise.",
            "Dispel Impending Despair before its 6s timer or the target gets stunned.",
            "Hopelessness reduces YOUR healing - compensate as it stacks.",
          },
          ["dps"] = {
            "Burn boss between fears; help interrupt/kill leftover wave adds.",
            "Fear-break trinkets/abilities help during Defiling Horror.",
            "Race him before Hopelessness stacks make the fight unhealable.",
          },
        },
        {
          ["name"] = "Marwyn",
          ["summary"] = "Easier than Falric; avoid Well of Corruption; do NOT dispel Shared Suffering; manage Corrupted Flesh on tank.",
          ["positioning"] = "Stay out of Well of Corruption ground pools (boost Shadow damage taken).",
          ["tank"] = {
            "Corrupted Flesh lowers your max health - stay topped to avoid sudden death.",
            "Keep boss out of / away from Well of Corruption pools.",
          },
          ["healer"] = {
            "Do NOT dispel Shared Suffering - dispelling dumps the remaining damage onto nearby allies.",
            "Heal tank through Corrupted Flesh max-HP reduction + Obliterate.",
          },
          ["dps"] = {
            "Stand out of Well of Corruption pools.",
            "Steady cleave - this is the easy boss; the gauntlet/escape after is the real test.",
          },
        },
        {
          ["name"] = "The Lich King (Escape from Arthas)",
          ["summary"] = "Running event: flee the chasing Lich King, break 4 ice walls under a wipe timer while fighting endless undead.",
          ["positioning"] = "Keep MOVING forward; never enter the 10-yard Remorseless Winter frost aura around the Lich King.",
          ["tank"] = {
            "Grab adds at each ice wall and face them away; keep moving with the group/escort.",
            "Pick up Lumbering Abominations (Cleave + vomit) - face away; stop Raging Ghouls leaping past you.",
          },
          ["healer"] = {
            "Heal on the move; stay ahead of Remorseless Winter (75% slow + ~7-8k frost/s within 10yd).",
            "Top the group before each wall - DPS must break it before Fury of Frostmourne (1,000,000 dmg) wipes you.",
          },
          ["dps"] = {
            "At each ice wall, BURST the wall down before the Fury of Frostmourne timer.",
            "Kill Risen Witch Doctors fast (ranged Shadow casters); stun/AoE Lumbering Abominations and Raging Ghouls.",
            "Never stop moving forward - the Lich King's frost aura kills lingerers.",
          },
        },
      },
    },
    {
      ["name"] = "Naxxramas",
      ["aliases"] = {
        "Naxx",
        "Naxx10",
        "Naxx25",
        "NAXX",
      },
      ["type"] = "raid",
      ["levelRange"] = "80 (Tier 7 entry raid)",
      ["generalTips"] = {
        "Greater Frost Protection Potions are mandatory for Sapphiron.",
        "Four wings (Arachnid, Plague, Construct, Military) unlock in any order; bosses below are the standout per wing.",
        "Bring decursers/dispellers for Grobbulus (disease) and Sapphiron (Life Drain curse).",
      },
      ["bosses"] = {
        {
          ["name"] = "Patchwerk (Construct)",
          ["summary"] = "Pure tank-and-spank gear/throughput check; Hateful Strike hits highest-HP non-tank melee.",
          ["positioning"] = "Stack 2-3 tanks together (Y-formation) at his front; only those tanks plus melee in range.",
          ["tank"] = {
            "Add tanks soak Hateful Strike by being highest-HP in melee — stack avoidance/HP.",
            "Hateful Strike fires ~every 1s for ~28-32k; pre-stack heals on add tanks.",
            "Pop defensives during Frenzy/Berserk (Soft Enrage at low HP) — damage spikes hard.",
          },
          ["healer"] = {
            "Assign 2-3 healers per Hateful-Strike tank; keep a heal landing every GCD.",
            "Time HoTs/big heals to land as Hateful Strike connects, not after.",
            "Save cooldowns (Guardian Spirit/PI) for the Frenzy phase.",
          },
          ["dps"] = {
            "Ranged: ignore mechanics, just burn — this is a DPS race vs the enrage.",
            "Melee: stay in range but never out-HP a designated Hateful tank.",
            "Use bloodlust/heroism on pull or at enrage per raid plan.",
          },
        },
        {
          ["name"] = "Grobbulus (Plague)",
          ["summary"] = "Mutating Injection disease detonates a poison cloud; slow-moving Slime Stream + Poison Clouds carpet the floor.",
          ["positioning"] = "Tank kites Grobbulus slowly around the room edge so green poison clouds don't cover walkable space.",
          ["tank"] = {
            "Kite the boss in a slow circle around the perimeter, staying ahead of the trailing poison.",
            "Keep him moving — Slime Stream and dropped clouds will block the room if you stand still.",
            "Off-tank picks up Fallout Slimes spawned from clouds; nuke them before they grow.",
          },
          ["healer"] = {
            "Do NOT dispel Mutating Injection — dispelling instantly detonates the 20yd cloud.",
            "Heal through the disease damage; injected players run out and the cloud pops on its own.",
            "Watch melee taking Poison Cloud ticks if the tank kites poorly.",
          },
          ["dps"] = {
            "If you get Mutating Injection, immediately run 20yd from everyone and drop the cloud in dead space.",
            "Drop clouds in a planned line so the kite path stays clean.",
            "Kill Fallout Slimes fast; spread out to avoid chaining cloud detonations.",
          },
        },
        {
          ["name"] = "Heigan the Unclean (Plague)",
          ["summary"] = "The 'Heigan Dance' — eruptions sweep the floor in safe-zone sequences; phases alternate with a teleport-to-platform spell phase.",
          ["positioning"] = "Stand on the marked safe-zone sections; move in the eruption sequence (1-2-3-4 then back) to dodge floor spikes.",
          ["tank"] = {
            "Tank Heigan in safe zone 1 during the ground phase; face him away.",
            "Manage Spell Disruption Zone — casting near him backfires, so position for melee.",
            "On teleport (platform/spell phase) everyone runs up; tank re-grabs when he returns.",
          },
          ["healer"] = {
            "Pre-HoT before the dance; you must move with the eruption rhythm too — don't stand still to cast.",
            "Decontaminate is unhealable if you eat eruptions; raid damage spikes during the dance.",
            "Triage during the teleport phase while spread on the platform.",
          },
          ["dps"] = {
            "Learn the eruption timing: stand zone1, then 2, 3, 4, then reverse — eruptions chase you.",
            "Casters: avoid Spell Disruption Zone (it interrupts/backfires casts near Heigan).",
            "In the teleport phase, get on the platform fast and AoE/burn from there.",
          },
        },
        {
          ["name"] = "Loatheb (Plague)",
          ["summary"] = "Necrotic Aura blocks all healing except brief windows; Spores spawn periodically and grant a Fungal Bloom crit buff when killed.",
          ["positioning"] = "Stack the raid; let one Spore reach the group so designated players soak Fungal Bloom.",
          ["tank"] = {
            "Healing is disabled most of the fight (Necrotic Aura) — survive on HoTs pre-applied and the brief heal windows.",
            "Stay put; this is a stationary nuke — face him away from raid for Deathbloom/poison.",
            "Watch for Inevitable Doom ramping in long fights; it's effectively a soft enrage.",
          },
          ["healer"] = {
            "Heals only land during the ~3s window between Necrotic Aura applications — coordinate a healer rotation, one healer per window.",
            "Pre-cast so the heal lands exactly when Necrotic Aura drops.",
            "HoTs ticking still help; keep the tank topped going into each blocked phase.",
          },
          ["dps"] = {
            "Kill Spores as they spawn and stand in them for Fungal Bloom (crit buff) to push DPS.",
            "It's a DPS race vs Inevitable Doom — burn hard, use bloodlust early.",
            "Spore-soaking is usually assigned to melee near the boss; coordinate so the buff is spread.",
          },
        },
        {
          ["name"] = "Thaddius (Construct)",
          ["summary"] = "Feugen & Stalagg constructs first (must die within ~10s of each other), then jump to Thaddius for Polarity Shift charge mechanic.",
          ["positioning"] = "Split raid for the two constructs; after the jump, stack by charge — positives on one side, negatives on the other.",
          ["tank"] = {
            "Constructs: keep Feugen/Stalagg ON their platforms or they wipe the raid (Static Field nature dmg).",
            "Constructs swap via Magnetic Pull — tanks taunt back or trade after each pull.",
            "On Thaddius, tank him center; watch Chain Lightning and the polarity stacks like everyone else.",
          },
          ["healer"] = {
            "Constructs: heal through Static Field (60yd nature pulse) and Stalagg's Power Surge attack-speed spikes.",
            "After the jump, stack with your matching charge; a wrong-charge neighbor = instant death.",
            "Polarity Shift reassigns charges every ~30s — re-check your debuff and move every shift.",
          },
          ["dps"] = {
            "Constructs must die within 10s of each other or the survivor revives the other.",
            "Make the jump cleanly (Slow Fall/Levitate helps); falling = death.",
            "On Thaddius: stack same-charge to gain the damage buff; re-sort instantly on every Polarity Shift.",
          },
        },
        {
          ["name"] = "Sapphiron",
          ["summary"] = "Frost-aura DPS race in P1 with Life Drain curse + Blizzard, then airborne Frost Breath you must LOS behind Ice Blocks.",
          ["positioning"] = "Stack the raid on one flank of his body (melee on hind leg); avoid head and tail. Stay grouped for healing.",
          ["tank"] = {
            "Point Sapphiron toward the Kel'Thuzad door, away from raid; keep him still.",
            "Constant Frost Aura (~600 dmg/2s) ticks the whole raid — pre-stack frost resistance/potions.",
            "Avoid the tail-swipe arc; reposition only if Blizzard forces it.",
          },
          ["healer"] = {
            "Decurse Life Drain immediately — it heals Sapphiron and drains the target each tick.",
            "Heal through the raid-wide Frost Aura; stacked raid = easier AoE/HoT coverage.",
            "P2: get behind an Ice Block too — you can't out-heal a missed Frost Breath.",
          },
          ["dps"] = {
            "Move out of Blizzard (Chill) trails on the ground.",
            "P2 (he flies): when he freezes 5 players, hide behind a frozen player's Ice Block to LOS Frost Breath or you die.",
            "Burn in P1; frost resist potions raise survivability for the DPS race.",
          },
        },
        {
          ["name"] = "Kel'Thuzad",
          ["summary"] = "Wave-based add phase, then KT awakens: Frost Blast encasement, Shadow Fissure void zones, Mana Detonation, and a guardian add phase.",
          ["positioning"] = "P1 stack center away from add spawn alcoves; P2 spread ~10yd on assigned points around his robe.",
          ["tank"] = {
            "P1: pick up the Abominations; let ranged kill Soldiers/Banshees first.",
            "P2: tank KT center; off-tank grabs Guardians of Icecrown when they spawn (~40%).",
            "Watch Frost Blast — anyone (incl. tank) can be encased; raid must free them fast.",
          },
          ["healer"] = {
            "Free Frost Blast targets ASAP (DPS the ice block) — they take escalating damage encased.",
            "Spread 10yd so Shadow Fissure / Mana Detonation don't chain the group.",
            "Heal through Frostbolt/Frostbolt Volley; conserve mana — Mana Detonation drains and explodes on mana users.",
          },
          ["dps"] = {
            "P1: kill Soldiers and Banshees from range, never standing in their melee/charm range; Abom last.",
            "Run out of the swirling Shadow Fissure void zones instantly (they one-shot).",
            "Spread to limit Mana Detonation; help break Frost Blast ice blocks immediately.",
          },
        },
      },
    },
    {
      ["name"] = "The Obsidian Sanctum",
      ["aliases"] = {
        "OS",
        "Obsidian Sanctum",
        "Sarth",
        "OS+3",
        "OS3D",
      },
      ["type"] = "raid",
      ["levelRange"] = "80 (Tier 7)",
      ["generalTips"] = {
        "Difficulty scales with how many drakes you leave alive at the Sartharion pull (OS+1/+2/+3).",
        "More drakes alive = Sartharion enrages at higher HP and the room gets far deadlier.",
        "Kill order is typically Tenebron, then Vesperon, then Shadron, then Sartharion.",
      },
      ["bosses"] = {
        {
          ["name"] = "Sartharion + Drakes (Tenebron, Shadron, Vesperon)",
          ["summary"] = "Tank Sartharion while drakes descend on a timer; Flame Tsunami (lava wave) sweeps the room, drakes add fire debuffs, whelps, and Twilight Portals.",
          ["positioning"] = "Tank Sartharion on one side near the lava-wave path so the raid only side-steps the Flame Tsunami; stack raid to dodge waves together.",
          ["tank"] = {
            "Main tank holds Sartharion; off-tank immediately grabs each drake and faces it AWAY from raid (Tail Lash/Breath).",
            "Position so the Flame Tsunami only requires a small step to dodge; never get caught mid-room.",
            "At ~10% Sartharion spawns a big Lava Blaze wave — off-tank picks those up, don't let them hit raid.",
            "If any drake is alive at 35%, Sartharion gains a hard Berserk — manage drake timers.",
          },
          ["healer"] = {
            "Shadron's Gift of Twilight doubles raid fire damage taken — heal hard while it's up and during Flame Tsunami.",
            "Vesperon's Twilight Portal sends players to the shadow realm vs an Acolyte (Disrupting Shadows) — keep portal team alive.",
            "Pre-heal before each Flame Breath / lava wave; raid-wide fire damage is constant with drakes up.",
          },
          ["dps"] = {
            "Dodge Flame Tsunami (the rolling lava wall) every time — it splits the room; cross at the gap.",
            "Tenebron spawns Twilight Whelps — AoE them down fast or they overwhelm healers.",
            "Kill Acolytes inside Vesperon's/Shadron's Twilight Portal to drop Sartharion's damage shield/buffs.",
            "Priority: drakes down before Sartharion hits 35% to avoid his Berserk.",
          },
        },
      },
    },
    {
      ["name"] = "The Eye of Eternity",
      ["aliases"] = {
        "EoE",
        "Eye",
        "Malygos",
        "Maly",
      },
      ["type"] = "raid",
      ["levelRange"] = "80 (Tier 7)",
      ["generalTips"] = {
        "Single-boss raid (Malygos) fought across 3 phases on platform, hover disks, then red drakes.",
        "Phase 3 disables your normal abilities — everyone uses the drake's vehicle bar (Flame Spike, Engulf, heal HoT, Flame Shield).",
        "Spread out in P1; never bunch up for the Arcane Breath cone.",
      },
      ["bosses"] = {
        {
          ["name"] = "Malygos",
          ["summary"] = "P1 ground fight (Arcane Breath cone, Vortex air-toss, Power Sparks), P2 on hover disks vs Nexus Lords/Scions, P3 on red drakes using a vehicle rotation.",
          ["positioning"] = "P1: spread around the platform out of the frontal Arcane Breath; drag Power Sparks into the raid. P2: ride disks, dodge Static Field. P3: free-fly on drakes, dodge Surge of Power.",
          ["tank"] = {
            "P1: face Malygos away from raid so Arcane Breath cone hits no one; keep him still.",
            "During Vortex everyone is sucked airborne and takes ticking damage — just survive it, then re-grab.",
            "Run Power Sparks into the melee/raid so the group gets the damage/haste buff before they expire.",
            "P2/P3 have no traditional tanking — switch to add-killing (disks) and the drake rotation.",
          },
          ["healer"] = {
            "P1: heal through Vortex (raid-wide) and Arcane Breath; spread to avoid splash.",
            "P2: heal disk riders through Static Field and add damage; melt the Scions of Eternity casting Arcane Barrage.",
            "P3: no normal heals — use the drake's HoT (heals 500/s, builds combo points) on damaged drakes; everyone self-sustains.",
          },
          ["dps"] = {
            "P1: stand in Power Spark pulse to gain the buff; nuke through Vortex damage.",
            "P2: kill Nexus Lords (melee them off their disks) and Scions; collect Power Sparks; watch for Deep Breath if too few sparks consumed.",
            "P3 drake rotation: Flame Spike x2-3 to build combo points, then Engulf in Flames to apply/stack the DoT; repeat.",
            "P3: use Flame Shield the instant you're targeted by Surge of Power or you die; pick up Revivify orbs/spark buff.",
          },
        },
      },
    },
    {
      ["name"] = "Ulduar",
      ["aliases"] = {
        "Uld",
        "Ulduar 10/25",
      },
      ["type"] = "raid",
      ["levelRange"] = "80",
      ["generalTips"] = {
        "Vehicle bosses (Flame Leviathan) use raid-provided Demolishers/Siege/Choppers, not your character.",
        "Most hard modes are opt-in via in-fight choices (towers up, kill heart, kill Animus, watchers alive).",
        "Interrupts win fights here: Searing Flames (Vezax), construct casters, add casters.",
        "Movement raid: position near safe spots (snowdrifts, mushrooms, away from beams/bombs).",
      },
      ["bosses"] = {
        {
          ["name"] = "Flame Leviathan",
          ["summary"] = "Vehicle fight; gunners shoot down pyrite, siege engines interrupt Flame Vents, choppers slow/kite.",
          ["positioning"] = "Stay in your assigned vehicle; circle the boss, kite at range, never let it free-roam.",
          ["tank"] = {
            "Siege Engine driver = de facto tank/kiter; Electroshock to interrupt Flame Vents.",
            "Pop ram/shield to soak; keep boss moving so it can't fixate.",
            "Hard mode = leave towers up (more damage, harder).",
          },
          ["healer"] = {
            "No traditional healing; you're in a vehicle. Pyrite-boost damage instead.",
            "Repair/heal vehicles where possible; revive ejected players post-fight.",
          },
          ["dps"] = {
            "Gunner: shoot pyrite crates, ignite tar, gather pyrite for driver.",
            "Demolisher driver: launch passengers onto boss to plant charges / destroy turrets.",
            "Killing turrets triggers Systems Shutdown: stun + 50% more damage for 20s, BURN.",
          },
        },
        {
          ["name"] = "Razorscale",
          ["summary"] = "Alternating air/ground phases; harpoon her down, kill adds, ground-only under 50%.",
          ["positioning"] = "Spread for Devouring Flame patches; stack at harpoons to pull her down fast.",
          ["tank"] = {
            "Pick up Dark Iron adds from mole machines instantly; Sentinels die first (Whirlwind).",
            "Ground phase: tank front; watch Fuse Armor + Flame Buffet stacks for burst.",
            "Under 50% she's permanently grounded; use a CD when stacks climb.",
          },
          ["healer"] = {
            "Spot-heal Devouring Flame targets; big tank healing in permanent ground phase.",
            "Top off harpoon operators; raid stays out of fire patches to ease healing.",
          },
          ["dps"] = {
            "Air phase: kill Sentinels (Whirlwind) > Watchers; man harpoons to ground her.",
            "Burn hard during the 30-40s grounded window before she relaunches.",
            "Don't stand in Devouring Flame; spread to limit fireball/flame spread.",
          },
        },
        {
          ["name"] = "Ignis the Furnace Master",
          ["summary"] = "Tank constructs through scorch to make them Molten, then to water to make them Brittle and shatter.",
          ["positioning"] = "Boss out of raid; constructs cycled construct-tank -> scorch -> water by ranged.",
          ["tank"] = {
            "Main tank: face Ignis AWAY from raid (Flame Jets frontal cone).",
            "Construct tank: drag adds into Scorch ground until Molten (10 Heat), then to water.",
            "Brittle constructs are stunned 20s and shatter from physical/spell hits.",
          },
          ["healer"] = {
            "Slag Pot target takes heavy DoT 10s; pre-HoT and burst-heal them out.",
            "Flame Jets = raid-wide fire; top group between casts.",
            "Watch construct tank standing in scorch (self-damage).",
          },
          ["dps"] = {
            "Instant-cast during Flame Jets (cast bar locked).",
            "Shatter Brittle constructs immediately (they're stunned, take bonus dmg).",
            "Ranged stay near water to shatter; don't stand in Scorch.",
          },
        },
        {
          ["name"] = "XT-002 Deconstructor",
          ["summary"] = "Heart exposes every 25%; nuke heart for damage, manage adds and Tympanic Tantrum.",
          ["positioning"] = "Spread for Searing Light/Gravity Bomb; keep bombbots away from raid.",
          ["tank"] = {
            "Grab XM-024 Pummellers when heart is exposed (they spawn during heart phase).",
            "Position boss so Tantrum/heart phases are predictable; minimal movement.",
            "Hard mode = kill the Heart while exposed (turns fight harder).",
          },
          ["healer"] = {
            "Tympanic Tantrum = ~heavy raid AoE over 8s; topple-heal between ticks.",
            "Searing Light = heavy DoT on target; keep them up.",
            "High DPS can skip Tantrum by exposing heart before its 1-min timer.",
          },
          ["dps"] = {
            "Nuke Heart (takes 100% extra dmg) during 30s exposed window.",
            "Ranged: kill XE-321 Boombots fast and at range (they explode, can kill healers).",
            "Move out of Gravity Bomb; don't cluster near bombbots.",
          },
        },
        {
          ["name"] = "Kologarn",
          ["summary"] = "Kill arms to stop Grip/Sweep; tank-swap Crunch Armor; dodge Focused Eyebeams.",
          ["positioning"] = "Ranged spread; eyebeam targets run toward entrance to keep beams clear of raid.",
          ["tank"] = {
            "Tank-swap on Crunch Armor (-25% armor, stacks to 100%); use avoidance CDs at 1 stack.",
            "Avoidance > stamina: dodged Overhead Smash skips a Crunch Armor application.",
            "Right arm focus reduces Stone Grips; left arm regrows.",
          },
          ["healer"] = {
            "Heal Stone Grip victims (grabbed players take damage until arm dies).",
            "Tank spikes when Crunch Armor stacks; pre-empt the swap.",
            "Eyebeam targets take heavy moving AoE; chase-heal them.",
          },
          ["dps"] = {
            "Focus RIGHT arm (fewer Stone Grips); free gripped allies by killing the arm.",
            "Run Focused Eyebeam toward the entrance, away from raid.",
            "Don't fall off the platform on knockbacks; mind the rubble edges.",
          },
        },
        {
          ["name"] = "Thorim",
          ["summary"] = "Split raid: gauntlet team rushes to Sif, arena team survives waves; phase 2 burn with tank-swaps.",
          ["positioning"] = "Arena team near center, spread (Chain Lightning); avoid Sif's Blizzard rim and Frost Nova.",
          ["tank"] = {
            "Phase 2: tank-swap on Unbalancing Strike (+50% damage taken debuff).",
            "Manage Lightning Charge stacks (boss ramps); face boss away if needed.",
            "Gauntlet tank: pick up adds fast to reach Sif before timer (hard mode).",
          },
          ["healer"] = {
            "Arena: heavy raid AoE from waves + Chain Lightning; spread to limit bounces.",
            "Gauntlet: keep DPS up through tunnel adds; speed matters for hard mode.",
            "Phase 2 tank spikes on Unbalancing Strike; pre-shield the swap.",
          },
          ["dps"] = {
            "Don't stack in phase 2: Chain Lightning bounces and chains kills.",
            "Kill arena adds (Acolytes/Champions) by priority; reach boss together.",
            "Move out of Sif's Frost Nova and Blizzard; burn boss fast (DPS race vs Sif buffs).",
          },
        },
        {
          ["name"] = "Freya",
          ["summary"] = "Survive 3 add-wave types (lashers, conservator, elementals) to drop Attuned-to-Nature, then burn Freya.",
          ["positioning"] = "Stack loosely for AoE on lashers; stand under Healthy Mushrooms during Conservator's Grip.",
          ["tank"] = {
            "Tank Ancient Conservator and the elemental trio (Snaplasher ramps with hits).",
            "Snaplasher: spread melee to slow its hardening stacks.",
            "Hold Freya away from raid; watch Iron Roots locking players in place.",
          },
          ["healer"] = {
            "Lasher explosions = AoE on death; spread heals across raid.",
            "Stand under Healthy Mushrooms to cleanse Conservator's Grip (silence/pacify).",
            "Sunbeam = pulsing nature AoE; heal/move targets out.",
          },
          ["dps"] = {
            "Detonating Lashers: untankable, AoE them (each death removes Attuned stacks).",
            "Kill Conservator (-30 stacks) and elementals to drop the buff; then Freya.",
            "Move out of Nature Bombs and Sunbeam; free rooted allies via Iron Roots.",
          },
        },
        {
          ["name"] = "Hodir",
          ["summary"] = "Beat the enrage by freeing NPCs and stacking damage; never stand still (Flash Freeze, Icicles).",
          ["positioning"] = "Constant movement; stand in/near Snowdrifts (anti-freeze buff) but not under landing shards.",
          ["tank"] = {
            "Tank-swap on Frozen Blows (melee turns to heavy Frost); use defensives.",
            "Frost Resistance helps; drag boss onto frozen helper NPCs to free them.",
            "Keep moving to avoid Icicle drops.",
          },
          ["healer"] = {
            "Frozen Blows = raid Frost every 2s for 20s; ramp raid healing, save CDs.",
            "Dispel Freeze roots immediately (movement is survival).",
            "Use Toasty Fire / NPC buffs; keep helpers alive.",
          },
          ["dps"] = {
            "Stay in Snowdrift buff to avoid Flash Freeze encasement.",
            "Free frozen players/NPCs; use Storm/Starlight buff zones for haste/crit.",
            "Dodge falling Icicles and incoming Flash Freeze shards; it's a soft enrage race.",
          },
        },
        {
          ["name"] = "Mimiron",
          ["summary"] = "4 phases (Leviathan MKII, VX-001, Aerial, combined); avoid mines/rockets/lasers each phase.",
          ["positioning"] = "P1 spread for mines; P2 hug close to dodge laser barrage rotation; P4 manage all at once.",
          ["tank"] = {
            "P1: tank-swap on Plasma Blast (heavy stacking Spellfire); face MKII away.",
            "P2 VX-001: no melee tank needed; P4 re-tank the assembled unit.",
            "Reposition constantly to dodge Shock Blast (50k nature in 15yd).",
          },
          ["healer"] = {
            "P1 Proximity Mines + P4 stacked damage are spiky; heavy raid healing.",
            "Plasma Blast tank target needs burst healing (25k/s).",
            "Rocket Strike + Napalm/Frost Bomb DoTs hit movers; top them fast.",
          },
          ["dps"] = {
            "P1: spread, don't trigger Proximity Mines; kill Bomb Bots.",
            "P2: rotate around VX-001 to avoid P3Wx2 Laser Barrage; dodge Rocket Strikes.",
            "P3: kill Aerial Command Unit + Assault/Bomb Bots; P4 = all mechanics combined, prioritize survival.",
          },
        },
        {
          ["name"] = "General Vezax",
          ["summary"] = "Near-zero mana regen (Aura of Despair); use Saronite Vapor puddles, interrupt Searing Flames, spread for Shadow Crash.",
          ["positioning"] = "Spread out for Shadow Crash; Mark of the Faceless target runs away from everyone.",
          ["tank"] = {
            "Boss reduces melee attack speed via aura; steady threat.",
            "Hard mode: do NOT kill Saronite Animus (kill it = normal); leave it for hard.",
            "Position boss centrally so raid can reach vapor puddles.",
          },
          ["healer"] = {
            "Mana is scarce: stand in Saronite Vapor puddles to regen (but they damage you).",
            "Searing Flames MUST be interrupted every cast (huge raid damage if not).",
            "Mark of the Faceless drains/heals boss from nearby allies; spread to negate.",
          },
          ["dps"] = {
            "Interrupt Searing Flames on rotation, every time.",
            "Move out of Shadow Crash impact; spread so it doesn't hit clusters.",
            "Mark of the Faceless: isolate yourself (it leeches health from nearby players).",
          },
        },
        {
          ["name"] = "Yogg-Saron",
          ["summary"] = "3 phases: clear Sara's tentacles -> brain room portals (kill Influence Tentacles) -> burn body; manage Sanity throughout.",
          ["positioning"] = "P1 spread from Malady fear targets; P2 stand by exit portal in brain room before nuking brain.",
          ["tank"] = {
            "P1: tank Crusher Tentacles; P3: tank Yogg body + Immortal Guardians.",
            "Phase transitions reset positioning; keep adds off raid.",
            "Manage Sanity like everyone (don't look at clouds/portals carelessly).",
          },
          ["healer"] = {
            "Sanity management: avoid mechanics that drain it (0 = mind controlled).",
            "Squeeze (Constrictor Tentacle) = severe DoT; heal hard until tentacle dies.",
            "P3 Lunatic Gaze + Shadow Beacon adds = heavy raid damage; ramp healing.",
          },
          ["dps"] = {
            "P1: kill Crusher/Corruptor/Constrictor tentacles (Constrictor first - Squeeze).",
            "P2: clear Immune/Influence Tentacles to open brain room; nuke Brain to 30% then escape portal.",
            "P3: DPS race - kill Brain-spawned adds, watch Sanity, burn Yogg before enrage.",
          },
        },
      },
    },
    {
      ["name"] = "Trial of the Crusader",
      ["aliases"] = {
        "ToC",
        "ToGC",
        "TotC",
        "Coliseum",
      },
      ["type"] = "raid",
      ["levelRange"] = "80",
      ["generalTips"] = {
        "Linear, no trash; 5 encounters back to back in one arena.",
        "Heroic (ToGC) adds attackable portals/spawners and limited raid-wide wipes (50 in 25H).",
        "Interrupts and PvP-style CC matter most on Faction Champions.",
        "Several fights are timer/positioning races, not gear checks.",
      },
      ["bosses"] = {
        {
          ["name"] = "Northrend Beasts",
          ["summary"] = "3-stage gauntlet: Gormok (snobolds/impale) -> Acidmaw+Dreadscale (poison/fire kiting) -> Icehowl (Massive Crash charge).",
          ["positioning"] = "Spread for Gormok; assign poison/fire kite paths in jormungar phase; spread out for Icehowl charge.",
          ["tank"] = {
            "Gormok: tank faces raid? No - just hold; off-tank can take Impale stacks via swap.",
            "Jormungars: ONE tank on mobile worm, ONE on stationary; swap when Acidmaw/Dreadscale surface roles flip.",
            "Icehowl: re-grab after Massive Crash + Arctic Breath stun; tank front, raid behind.",
          },
          ["healer"] = {
            "Gormok: Snobold-riding players take damage; Impale bleed stacks need attention.",
            "Jormungar: Burning Bile + Paralytic Poison combo - cleanse/swap debuffs (burning bile cures paralysis).",
            "Icehowl: huge raid damage if Massive Crash lands on someone; spread to avoid wipe.",
          },
          ["dps"] = {
            "Gormok: kill Snobold Vassals off players' heads ASAP (4 spawn).",
            "Jormungar: burn both; players with poison stand apart, burning-bile players cleanse poisoned allies.",
            "Icehowl: STOP and move away from Massive Crash target ring; nuke after his post-charge stun (he hits wall).",
          },
        },
        {
          ["name"] = "Lord Jaraxxus",
          ["summary"] = "Interrupt Fel Fireball, run Legion Flame out, kill Mistress of Pain + Infernals, manage Incinerate Flesh.",
          ["positioning"] = "Keep raid loosely spread (Fel Lightning chains); move out of Legion Flame and Infernal volcanoes.",
          ["tank"] = {
            "Main tank Jaraxxus (warrior/DK preferred for Fel Fireball interrupts).",
            "Off-tank grabs Mistress of Pain (from Nether Portal) immediately.",
            "Spellsteal/Purge Nether Power (10 stacks, +magic dmg) off the boss.",
          },
          ["healer"] = {
            "Incinerate Flesh = healing absorb shield on a player; burst through it before it becomes Burning Inferno raid damage.",
            "Fel Lightning bounces; keep targets spread-healed.",
            "Heavy magic damage when Nether Power stacks are up; pre-CD.",
          },
          ["dps"] = {
            "Interrupt Fel Fireball every cast.",
            "Run out of raid with Legion Flame; kill Infernal Volcanoes/Nether Portals (heroic) fast.",
            "Burn Mistress of Pain quickly (Spinning Pain Spike) and Spellsteal/Purge Nether Power.",
          },
        },
        {
          ["name"] = "Faction Champions",
          ["summary"] = "PvP-style fight vs enemy player comp; CC and focus-kill healers, force trinkets, peel for your healers.",
          ["positioning"] = "Group with LoS for CC; spread casters; peel melee off your healers; use pillars/walls.",
          ["tank"] = {
            "No traditional tanking; act as peeler/CC and body-block melee off your healers.",
            "Use stuns/snares (Shockwave, Hungering Cold) to lock down the kill target.",
            "Pick up and control loose champions chasing your backline.",
          },
          ["healer"] = {
            "You are the primary target - kite, LoS, bubble/trinket out of stuns and silences.",
            "Dispel deadly debuffs (Polymorph, fears, magic burst); trinket the big CC chains.",
            "Stay near peelers; expect to be tunneled the whole fight.",
          },
          ["dps"] = {
            "Focus enemy healers first (Druid/Shaman highest priority), then casters.",
            "Chain CC off-targets; AoE CC (Psychic Scream, Hungering Cold) to bait PvP trinkets.",
            "Interrupt enemy heals/casts; blow cooldowns to burst the kill target through their defensives.",
          },
        },
        {
          ["name"] = "Twin Val'kyr",
          ["summary"] = "Match your essence to absorb same-color attacks; swap essence for Vortex; break shields to interrupt Twin's Pact heal.",
          ["positioning"] = "Half raid light essence on dark twin, half dark on light twin; grab same-color orbs for damage buff.",
          ["tank"] = {
            "Tank each Val'kyr; tanks take essence matching their twin to mitigate her melee/attacks.",
            "Hold both twins apart for raid clarity; minimal swaps.",
            "Stay on top of threat through the essence-swap chaos.",
          },
          ["healer"] = {
            "Swap your essence to MATCH the Vortex caster's color or take heavy raid damage.",
            "Heal through Twin's Pact channel window; lots of essence-mismatch damage punishes mistakes.",
            "Touch same-color orbs to boost output; opposite-color orbs hurt you.",
          },
          ["dps"] = {
            "DPS the twin OPPOSITE your essence color (light essence -> hit dark twin).",
            "On Vortex: change essence to match the casting twin immediately, then resume.",
            "Break the shield to interrupt Twin's Pact (heals 20% normal / 50% heroic); grab same-color orbs (Surge of Speed).",
          },
        },
        {
          ["name"] = "Anub'arak",
          ["summary"] = "3 phases: surface (burrowers, Penetrating Cold) -> submerge (Pursuing Spikes, use Permafrost) -> P3 burn with Leeching Swarm.",
          ["positioning"] = "Kill Frost Spheres to make Permafrost patches; in submerge phase kite spikes onto Permafrost to slow them.",
          ["tank"] = {
            "P1/P3: tank Anub'arak + Nerubian Burrowers (off-tank on adds).",
            "Freezing Slash freezes the tank 3s; off-tank ready.",
            "Keep boss positioned near Permafrost for fast re-engage after submerge.",
          },
          ["healer"] = {
            "Penetrating Cold = stacking frost DoT on 5 random players; rolling raid heal.",
            "P3 Leeching Swarm drains health to heal boss - keep everyone high so it self-sustains less.",
            "Pursuing Spikes hits = damage + knockup; heal movers in submerge phase.",
          },
          ["dps"] = {
            "Submerge: kite Pursuing Spikes onto Permafrost (resets their speed); kill Swarm Scarabs fast (lethal stacking bleed).",
            "Kill Frost Spheres before submerge to seed Permafrost patches.",
            "P3 (<30%): DPS race vs Leeching Swarm; burn boss while staying topped.",
          },
        },
      },
    },
    {
      ["name"] = "Icecrown Citadel",
      ["aliases"] = {
        "ICC",
        "Icecrown",
      },
      ["type"] = "raid",
      ["levelRange"] = "80 (10/25, normal & heroic)",
      ["generalTips"] = {
        "Buffs (Strength of Wrynn / Hellscream's Warsong) add stacking 5-30% HP/healing/damage — set the % via instance NPC before pulling.",
        "Frost Resistance gear helps on Sindragosa and Lich King; not needed elsewhere.",
        "Most fights want ranged spread and melee stacked — default to that unless a mechanic says otherwise.",
      },
      ["bosses"] = {
        {
          ["name"] = "Lord Marrowgar",
          ["summary"] = "Stacked-tank cleave fight with impale spikes and a whirlwind phase.",
          ["positioning"] = "Tanks + melee stacked under boss in center; ranged/healers spread in a loose arc behind.",
          ["tank"] = {
            "Both tanks stack on top of each other to split Saber Lash (Bone Slice) 3-way.",
            "Never let a tank stand alone — unsplit Saber Lash one-shots.",
            "Regroup with co-tank fast after each Bone Storm.",
          },
          ["healer"] = {
            "Spread for Coldflame trails but stay in raid range.",
            "Spot-heal anyone Bone-Spiked; pre-HoT during Bone Storm.",
            "Bone Storm = heavy raid AoE; have a CD ready.",
          },
          ["dps"] = {
            "Melee hug the boss to dodge Coldflame fire lines.",
            "Instantly swap to kill Bone Spikes (impaled players) — melee near, ranged far.",
            "During Bone Storm run away from boss; spread from Coldflame; resume on impaled targets.",
          },
        },
        {
          ["name"] = "Lady Deathwhisper",
          ["summary"] = "Break her Mana Barrier (P1) by killing adds, then burn boss (P2).",
          ["positioning"] = "Tanks hold boss + adds at front; ranged spread along the back rail; melee on boss/adds.",
          ["tank"] = {
            "Pick up Fanatics/Adherents as they spawn from side balconies; keep them off healers.",
            "P2: tank boss; watch for Reanimated Adherent — taunt and burn.",
            "Face boss away (Death and Decay / Frostbolt frontal).",
          },
          ["healer"] = {
            "P1 is heavy on add-tank + raid damage from Death and Decay; spread.",
            "Dispel Curse of Torpor (Adherent) and the disease.",
            "Save mana — P2 has a soft enrage.",
          },
          ["dps"] = {
            "P1: kill adds, do NOT damage the boss (her shield converts mana). Kill Adherents that cast, control Fanatics.",
            "Casters dispel/Spellsteal the Fanatic damage/heal-absorb buff if possible.",
            "P2: full burn boss; ranged dodge Frostbolt Volley spread, run from Death and Decay, kill Ghost adds (Vengeful Shade).",
          },
        },
        {
          ["name"] = "Gunship Battle",
          ["summary"] = "Ship-to-ship: man cannons, jump across, kill enemy boss/adds. No traditional tank/heal check.",
          ["positioning"] = "Stay near your ship's rail for healer range; cannon operators on cannons; jumpers use rocket pack to cross.",
          ["tank"] = {
            "Tank jumps first — enemy commander activates the instant anyone lands.",
            "Drag enemy boss to the ship edge to keep healers in range.",
            "Use CDs vs Wounding Strike; sidestep Bladestorm.",
          },
          ["healer"] = {
            "Stand near the ledge to reach both ships.",
            "Watch jumpers' health (fall + boss damage) and cannon operators.",
            "Light healing fight overall.",
          },
          ["dps"] = {
            "Cannon operators: Cannon Blast to ~90 heat, then Incinerating/Overheat to vent — never hit 100 heat.",
            "Ranged kill the Mage adds casting Below Zero (they freeze your cannons).",
            "Melee jump and burn enemy boss + adds; dodge Bladestorm.",
          },
        },
        {
          ["name"] = "Deathbringer Saurfang",
          ["summary"] = "Tank-swap on Rune of Blood and starve his Blood Power to avoid extra Marks.",
          ["positioning"] = "Tanks stack boss at center; ranged spread wide; melee on boss but ready to single-target Blood Beasts.",
          ["tank"] = {
            "Instant taunt-swap on Rune of Blood or he self-heals — keep taunts ready.",
            "Keep the boss centered so ranged can spread.",
            "Save big CDs for last 30% (Frenzy).",
          },
          ["healer"] = {
            "Beacon/external the Mark of the Fallen Champion target(s) — Marks are permanent and stack.",
            "Watch Boiling Blood ticks, deadly on Marked players.",
            "Less damage early = fewer Marks; the longer the fight runs the harder it gets.",
          },
          ["dps"] = {
            "Minimize Blood Power: ranged spread so Blood Nova only hits one person.",
            "Blood Beasts have Resistant Skin — NO AoE; use single-target + slows/stuns/knockbacks.",
            "Ranged stand near melee so Beasts don't run far before dying; kill them fast (they fuel Blood Power).",
          },
        },
        {
          ["name"] = "Festergut",
          ["summary"] = "5-minute DPS race; everyone must inhale Gas Spores to survive Pungent Blight.",
          ["positioning"] = "Melee + tank stacked; ranged spread on perimeter for Vile Gas. Group up to share spores when they spawn.",
          ["tank"] = {
            "Gastric Bloat stacks on tank — swap before ~9-10 stacks or Gastric Explosion kills you.",
            "Be IN range of a Gas Spore each time — you must get the Inhaled Blight buff.",
            "Pop a CD each Pungent Blight (raid-wide every ~2 min).",
          },
          ["healer"] = {
            "Heavy spike damage at high Inhale Blight; raid CD on each Pungent Blight.",
            "Spread so Vile Gas only hits one ranged.",
            "Confirm everyone has Inoculated stacks before Pungent Blight or it kills the raid.",
          },
          ["dps"] = {
            "Group up so the 3 Gas Spore holders share the buff with everyone nearby.",
            "Ranged spread for Vile Gas, then regroup for spore inhale.",
            "Pure burn — 5-min hard enrage; pop CDs on pull and during heroism.",
          },
        },
        {
          ["name"] = "Rotface",
          ["summary"] = "Dispel infections away from raid; one tank kites a growing Big Ooze and detonates it.",
          ["positioning"] = "Boss tanked off-center; melee stacked on boss; ranged spread on edges; ooze-kiter runs Big Ooze around the room.",
          ["tank"] = {
            "Boss tank: hold Rotface, face Slime Spray cone away from raid.",
            "Ooze-kiter: grab Big Ooze from 10+ yds, kite it and merge Little Oozes into it, then position for Unstable Ooze Explosion.",
            "Use speed boosts (Nitro) to kite.",
          },
          ["healer"] = {
            "Set and follow a dispel order for Mutated Infection — only dispel once the infected player is in the safe drop spot.",
            "Spread for Vile Gas; raid CD on Unstable Ooze Explosion.",
            "Dispelling spawns a Little Ooze + Sticky Ooze slow at that location.",
          },
          ["dps"] = {
            "Infected players run to the kite path before being dispelled.",
            "Stack to share Unstable Ooze Explosion damage when Big Ooze blows.",
            "Melee dodge Slime Spray; burn boss; avoid Sticky Ooze puddles.",
          },
        },
        {
          ["name"] = "Professor Putricide",
          ["summary"] = "3 phases: kite/kill oozes, then add Malleable Goo, then a tank-swap DPS race.",
          ["positioning"] = "Boss tanked along a wall to keep center clear of Slime Puddles; ranged spread; one player drives the Abomination to eat puddles and slow oozes.",
          ["tank"] = {
            "P1-2: keep boss near wall, move out of Choking Gas Bombs / puddles.",
            "P3 (35%): frequent tank swaps for Mutated Plague — never take 3 stacks; swap every ~2 stacks.",
            "Coordinate CDs between swaps.",
          },
          ["healer"] = {
            "Spread; track Slime Puddle growth and ooze explosions.",
            "P3: prioritize the current Mutated Plague tank (damage multiplies per stack).",
            "Dispel Unbound Plague carefully (only pass between the two melee designated).",
          },
          ["dps"] = {
            "Instantly swap to Gas Cloud (chase) / Volatile Ooze (stack to soak) when Unstable Experiment spawns them.",
            "Move out of Malleable Goo (P2) and Choking Gas Bombs.",
            "Abomination driver: Eat Ooze on puddles, save energy for Regurgitated Ooze to slow oozes. P3 = hard burn.",
          },
        },
        {
          ["name"] = "Blood Prince Council",
          ["summary"] = "3 princes alive; only the one with Invocation of Blood takes real damage — follow the empower swaps.",
          ["positioning"] = "Melee spread in 2-3 groups behind active prince (Shock Vortex knockback); back to a wall; ranged spread.",
          ["tank"] = {
            "Keleseth tank should be a DK/Warlock — only DoTs hurt him while he's unempowered; survive Empowered Shadow Lance (~100k) with CDs.",
            "Other tank handles Valanar + Taldaram, swapping as Invocation moves.",
            "2 or 3 tanks both viable.",
          },
          ["healer"] = {
            "Tunnel the Keleseth tank through Empowered Shadow Lance (huge hits).",
            "Constant raid damage from Vortex/Flames — keep everyone topped.",
            "Spread so Shock Vortex doesn't chain-knock multiple players.",
          },
          ["dps"] = {
            "Only DPS the empowered prince (Invocation of Blood); swap on every empower change.",
            "Keep Kinetic Bombs (Valanar) bouncing — knock them up to stop them hitting the floor (pets/ranged).",
            "Spread, back to wall, dodge Empowered Flames; on Keleseth phase, DoT all 3 if assigned.",
          },
        },
        {
          ["name"] = "Blood-Queen Lana'thel",
          ["summary"] = "Vampiric Bite chain spreads a haste buff; follow the bite order or get Mind Controlled. Soft enrage.",
          ["positioning"] = "Melee in spread groups behind boss; ranged spread; linked Pact players stack together to clear it.",
          ["tank"] = {
            "Both tanks stack as close to the boss as possible (Blood Mirror reflect to off-tank).",
            "Off-tank takes Delirious Slash bleed — needs priority healing.",
            "Save personal CDs for late fight when raid is fully bitten.",
          },
          ["healer"] = {
            "Raid CD rotation on each Bloodbolt Whirl (~every 2 min, massive AoE).",
            "Heal Swarming Shadows runner and the off-tank.",
            "Beg for Innervate early — mana-intensive fight.",
          },
          ["dps"] = {
            "FOLLOW YOUR BITE ORDER — when bitten you have 10s to bite another or you Mind Control; highest DPS bitten first for buff uptime.",
            "Essence of the Blood Queen = +damage; ride it.",
            "Pact of the Darkfallen: linked players stack instantly to clear; spread for Bloodbolt Whirl. Race the enrage.",
          },
        },
        {
          ["name"] = "Valithria Dreamwalker",
          ["summary"] = "Healing race — heal Valithria to 100% before enrage while DPS clears adds.",
          ["positioning"] = "Valithria in center; healers cycle through Dream portals for buff stacks; tanks/DPS handle adds around the room.",
          ["tank"] = {
            "Pick up Gluttonous Abominations, face them away from raid (Gut Spray / splash).",
            "Taunt/kite Blistering Zombies away from the group.",
            "Mostly add control — not a boss-tanking fight.",
          },
          ["healer"] = {
            "This is YOUR race: heal Valithria up, not the raid.",
            "Use Dream portals to stack Emerald Vigor (haste/healing); grab clouds inside for amplification, then heal the boss.",
            "Coordinate raid-healing-increase CDs while stacks are high; keep ~2 healers outside on adds/dispels.",
          },
          ["dps"] = {
            "Priority kill order: Blazing Skeleton (Lay Waste) > Suppresser (cuts Valithria's healing) > Risen Archmage.",
            "Interrupt Risen Archmage; dodge Column of Frost / Mana Void.",
            "Kill Gluttonous Abominations + their spawns; slow Blistering Zombies.",
          },
        },
        {
          ["name"] = "Sindragosa",
          ["summary"] = "Frost Aura DoT, air-phase Ice Tombs for LoS, then a Mystic Buffet stack-management P2.",
          ["positioning"] = "Tank boss sideways (head + tail away from raid); melee at her flank; casters spread; in P2 use Ice Tombs as LoS blockers.",
          ["tank"] = {
            "Tank boss sideways so Frost Breath/Tail Smash miss the raid; swap after ~3 Frost Breaths.",
            "Frost Resist gear (~280) cuts Frost Breath ~50%; CD each Frost Breath.",
            "P3: alternate tanking with LoS-ing behind an Ice Tomb to drop Mystic Buffet.",
          },
          ["healer"] = {
            "Call out Unchained Magic — those debuffed move out before it detonates raid AoE.",
            "CD with tanks on each Frost Breath; 6-8 healers, even number for Unchained distribution.",
            "P3: hide behind Ice Tombs to reset Mystic Buffet stacks.",
          },
          ["dps"] = {
            "Melee attack from her midsection; stop at ~6 Chilled to the Bone stacks until it drops.",
            "Casters watch Unchained Magic (Instability) — stop casting at 3-4 stacks or you blow up.",
            "Air phase: hide behind Ice Tombs to dodge Frost Bombs; P3 burn while LoS-resetting Mystic Buffet behind tombs.",
          },
        },
        {
          ["name"] = "The Lich King",
          ["summary"] = "Hardest boss in the game: tank-swap Infest, dodge Defile, manage Necrotic Plague + Val'kyrs, survive Soul Reaper.",
          ["positioning"] = "Boss faced away from raid at center; everyone spread to the platform's outer edge for Defile; melee stay close, ranged max-spread.",
          ["tank"] = {
            "Tank-swap on Infest stacks; off-tank instantly grabs Drudge Ghouls and Shambling Horrors.",
            "Coordinate a major CD for EVERY Soul Reaper — it will one-shot otherwise.",
            "Keep boss faced away; reposition cleanly out of Defile.",
          },
          ["healer"] = {
            "Pre-CD every Soul Reaper window with the tanks.",
            "Heavy raid damage from Infest/Defile; dispel Necrotic Plague only on the assigned Drudge-Ghoul stack point.",
            "During Val'kyr, top the grabbed player while ranged free them.",
          },
          ["dps"] = {
            "Move OUT of Defile the instant it lands — it grows each tick and is the #1 wipe cause; stay spread on the edge.",
            "Burn Val'kyrs fast to free the carried player before they're thrown off.",
            "Let Necrotic Plague jump to the Drudge Ghouls (don't random-dispel); kill Shambling Horrors (interrupt Enrage). Race transitions.",
          },
        },
      },
    },
    {
      ["name"] = "Onyxia's Lair (Level 80)",
      ["aliases"] = {
        "Ony",
        "Onyxia",
        "Onyxia 80",
      },
      ["type"] = "raid",
      ["levelRange"] = "80 (10/25)",
      ["generalTips"] = {
        "Three-phase fight: ground (P1) > air (P2, 65%) > ground + whelps (P3, 40%).",
        "Approach laterally so you avoid Cleave (front), Flame Breath (front), and Tail Sweep (rear).",
        "Watch for 'Deep Breath' (full-room fire) shout in the air phase and avoid the breath path.",
      },
      ["bosses"] = {
        {
          ["name"] = "Onyxia",
          ["summary"] = "Position to dodge cleaves/tail, survive the air-phase fireballs and whelps, then burn in P3.",
          ["positioning"] = "Tank her against the north wall facing away from raid; ranged + healers behind/under her belly; melee on flanks, never in front or directly behind.",
          ["tank"] = {
            "Charge first, turn her away, back into the north wall (minimizes Tail Sweep knockback).",
            "Keep her nose pointed away from the raid (Cleave + Flame Breath ~30k frontal).",
            "P2: pick up Onyxian Lair Guards that spawn; hold them through the air phase.",
          },
          ["healer"] = {
            "P1: heal Flame Breath spikes (~30k every 15-20s) and Tail Sweep victims.",
            "P2 air phase: spread for random Fireballs (~hit every 2s) and the Eruption fissures.",
            "P3: heaviest phase — Flame Breath + whelp swarm; AoE raid healing.",
          },
          ["dps"] = {
            "P1: hit her from the side; stay out of front (Cleave) and rear (Tail Sweep).",
            "P2: ranged nuke Onyxia in the air, kill Lair Guards/whelps, dodge Eruption (ground fire) and Deep Breath.",
            "P3: full burn; spread out, AoE whelp waves, keep moving out of fire.",
          },
        },
      },
    },
    {
      ["name"] = "The Ruby Sanctum",
      ["aliases"] = {
        "RS",
        "Ruby Sanctum",
        "RubySanc",
      },
      ["type"] = "raid",
      ["levelRange"] = "80 (10/25, normal & heroic)",
      ["generalTips"] = {
        "Trash: three mini-bosses (Baltharus, Saviana, Zarithrian) before Halion.",
        "Halion is a 3-phase, two-realm fight; bring 2 tanks and 3-5 healers.",
        "Have reliable dispellers — both major debuffs (Combustion fire, Consumption shadow) must be dispelled.",
      },
      ["bosses"] = {
        {
          ["name"] = "Halion",
          ["summary"] = "P1 physical realm, P2 twilight realm, P3 both realms split — keep Corporeality balanced or a tank dies.",
          ["positioning"] = "Tank at room edge; raid spread into groups for Meteor Strike. P3: raid splits between Physical and Twilight realms; keep damage even.",
          ["tank"] = {
            "P1: tank Halion facing away (Flame Breath); position at edge.",
            "P2: in the Twilight realm, move boss to dodge the rotating Twilight Cutter beams.",
            "P3: one tank per realm; watch Corporeality — uneven DPS makes one realm's boss hit far harder.",
          },
          ["healer"] = {
            "Dispel Mark of Combustion (P1) and Mark of Consumption (P2) — dispelled target drops a pool, so they spread out first.",
            "P3: split healing across both realms, weighting the realm with higher Corporeality (more damage).",
            "On Heroic, Freedom/cleanse the slow effects.",
          },
          ["dps"] = {
            "P1: spread into groups, run from Meteor Strike impact + its flame walls.",
            "P2: dodge the rotating Twilight Cutter beam (kill orbs / move with boss).",
            "P3: split by type — keep DPS roughly EVEN across both realms to hold Corporeality near 50% or the raid wipes.",
          },
        },
      },
    },
  },
}

return ns.KnowledgeData
