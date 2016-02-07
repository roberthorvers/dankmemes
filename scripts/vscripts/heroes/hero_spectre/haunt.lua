--[[
	Author: Noya
	Date: 18.01.2015.
	Creates Illusions, making use of the built in modifier_illusion

	Note: The positions weren't random in the original ability. Fix later
]]
function CreateIllusion(caster, ability, target)
    local player = caster:GetPlayerID()
    local unit_name = caster:GetUnitName()
    local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
    local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_damage_outgoing", ability:GetLevel() - 1 )
    local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_damage_incoming", ability:GetLevel() - 1 )
    local casterOrigin = caster:GetAbsOrigin()
    local casterAngles = caster:GetAngles()

    -- Spawn illusions
    local origin = target:GetAbsOrigin()

    -- handle_UnitOwner needs to be nil, else it will crash the game.
    local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
    illusion:SetPlayerID(caster:GetPlayerID())
    illusion:SetControllableByPlayer(player, true)

    illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )

    -- Level Up the unit to the casters level
    local casterLevel = caster:GetLevel()
    for i=1,casterLevel-1 do
        illusion:HeroLevelUp(false)
    end

    -- Set the skill points to 0 and learn the skills of the caster
    illusion:SetAbilityPoints(0)
    for abilitySlot=0,15 do
        local ability = caster:GetAbilityByIndex(abilitySlot)
        if ability ~= nil then
            local abilityLevel = ability:GetLevel()
            local abilityName = ability:GetAbilityName()
            local illusionAbility = illusion:FindAbilityByName(abilityName)
            illusionAbility:SetLevel(abilityLevel)
        end
    end

    -- Recreate the items of the caster
    for itemSlot=0,5 do
        local item = caster:GetItemInSlot(itemSlot)
        if item ~= nil then
            local itemName = item:GetName()
            local newItem = CreateItem(itemName, illusion, illusion)
            illusion:AddItem(newItem)
        end
    end

    -- Set the unit as an illusion
    -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
    illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })

    -- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
    illusion:MakeIllusion()
    -- Set the illusion hp to be the same as the caster
    illusion:SetHealth(caster:GetHealth())
end

function HauntAll(event)
    local caster = event.caster
    local ability = event.ability

    -- Find all buildings on the map
    local buildings = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)


    local allHeroes = HeroList:GetAllHeroes()
    for _,hero in pairs(allHeroes) do
        if hero:IsRealHero() then
            CreateIllusion(caster, ability, hero)
        end
    end

    local count = 0

    -- Iterate through each one
    for _, building in pairs(buildings) do
        if count < 5 then
        -- Parameters
            local building_name = building:GetName()

            -- Identify the building type
            if string.find(building_name, "tower") then
                CreateIllusion(caster, ability, building)
                count = count + 1

            elseif string.find(building_name, "rax_melee") then


            elseif string.find(building_name, "rax_range") then


            elseif string.find(building_name, "fort") then
                CreateIllusion(caster, ability, building)
                count = count + 1

            elseif string.find(building_name, "fountain") then
                -- Do nothing (fountain was already modified previously)
            else

            end
        end
    end
end