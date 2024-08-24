-- advanced wand workshop 2.0 wand growth + omni pillar edit
dofile_once("mods/wand_workshop/files/scripts/lib/ComponentUtils.lua") -- Put your Lua here-- advanced wand workshop 2.0 wand growth edit (omni pillar)
dofile_once("mods/wand_workshop/files/scripts/config.lua")
dofile_once("data/scripts/lib/utilities.lua")
function hover_wand(wand_id, altar_id)
    local x, y = EntityGetTransform(altar_id)
    local component_id = EntityGetFirstComponentIncludingDisabled(wand_id, "ItemComponent")
    if component_id ~= nil then
        ComponentSetValue2(component_id, "has_been_picked_by_player", false)
        ComponentSetValue2(component_id, "play_hover_animation", true)
        ComponentSetValue2(component_id, "spawn_pos", x + altar_wand_offset_x, y + altar_wand_offset_y)
    end

    component_id = EntityGetFirstComponentWithVariable(wand_id, "LuaComponent", "script_item_picked_up", "data/scripts/particles/wand_pickup.lua")
    if component_id ~= nil then EntitySetComponentIsEnabled(wand_id, component_id, true) end
    component_id = EntityGetFirstComponentIncludingDisabled(wand_id, "SimplePhysicsComponent")
    if component_id ~= nil then EntitySetComponentIsEnabled(wand_id, component_id, false) end
    component_id = EntityGetFirstComponentWithVariable(wand_id, "SpriteParticleEmitterComponent", "velocity_always_away_from_center", nil)
    if component_id ~= nil then EntitySetComponentIsEnabled(wand_id, component_id, true) end
end

function get_wand_ability_component(wand_id)
    return EntityGetFirstComponentIncludingDisabled(wand_id, "AbilityComponent")
end

local main_altar_tag = "Wand_Altar"
local altars = {
    {
        tag = "Speed_Altar",
        omni = nil,
        object = "gunaction_config",
        property = "fire_rate_wait",
        var_field = "value_int",
        material = "spark_yellow",
        operator = "reductive"
    },
    {
        tag = "Reload_Altar",
        omni = nil,
        object = "gun_config",
        property = "reload_time",
        var_field = "value_int",
        material = "spark_red",
        operator = "reductive"
    },
    {
        tag = "Mana_Altar",
        omni = nil,
        object = nil,
        property = "mana_max",
        var_field = "value_int",
        material = "spark_blue",
        operator = "additive"
    },
    {
        tag = "Recharge_Altar",
        omni = nil,
        object = nil,
        property = "mana_charge_speed",
        var_field = "value_int",
        material = "spark_teal",
        operator = "additive"
    },
    {
        tag = "Shuffle_Altar",
        omni = nil,
        object = "gun_config",
        property = "shuffle_deck_when_empty",
        var_field = "value_bool",
        material = "spark_green",
        operator = nil
    },
    {
        tag = "Simulcast_Altar",
        omni = nil,
        object = "gun_config",
        property = "actions_per_round",
        var_field = "value_int",
        material = "spark_player",
        operator = nil
    },
    {
        tag = "Spread_Altar",
        omni = nil,
        object = "gunaction_config",
        property = "spread_degrees",
        var_field = "value_int",
        material = "spark_yellow",
        operator = "reductive"
    },
    {
        tag = "Capacity_Altar",
        omni = nil,
        object = "gun_config",
        property = "deck_capacity",
        var_field = "value_int",
        material = "spark_white",
        operator = "additive"
    },
    {
        tag = "Omni_Altar",
        omni = {
            {
                object = "gunaction_config", -- all the altars in one, kinda -- speed
                property = "fire_rate_wait",
                var_field = "value_int",
                operator = "reductive"
            },
            {
                object = "gun_config", -- reload
                property = "reload_time",
                var_field = "value_int",
                operator = "reductive"
            },
            {
                object = nil, -- mana
                property = "mana_max",
                var_field = "value_int",
                operator = "additive"
            },
            {
                object = nil, -- recharge
                property = "mana_charge_speed",
                var_field = "value_int",
                operator = "additive"
            },
            {
                object = "gunaction_config", -- spread
                property = "spread_degrees",
                var_field = "value_int",
                operator = "reductive"
            },
            {
                object = "gun_config", -- capacity
                property = "deck_capacity",
                var_field = "value_int",
                operator = "additive"
            },
        },
        object = nil,
        property = nil,
        var_field = nil,
        material = "spark_teal",
        operator = nil
    }
}

function link_altar_wand(altar_id, wand_id)
    EntityAddChild(wand_id, altar_id)
    EntitySetComponentsWithTagEnabled(altar_id, "wand_pickup", false)
    EntitySetComponentsWithTagEnabled(altar_id, "wand_effect", true)
    if not EntityHasTag(altar_id, "Wand_Altar") then
        reset_wands(altar_id)
        merge_wands(altar_id)
    else
        merge_wands(altar_id, wand_id)
    end
end

function unlink_altar_wand(altar_id, wand_id)
    EntityRemoveFromParent(altar_id)
    EntitySetComponentsWithTagEnabled(altar_id, "wand_pickup", true)
    EntitySetComponentsWithTagEnabled(altar_id, "wand_effect", false)
    if not EntityHasTag(altar_id, "Wand_Altar") then
        reset_wands(altar_id)
        merge_wands(altar_id)
    else
        for i = 1, #altars do
            local component_ids = EntityGetComponentIncludingDisabled(wand_id, "VariableStorageComponent", "wand_altar_statbuffer")
            if component_ids ~= nil then
                for j, component_id in pairs(component_ids) do
                    EntityRemoveComponent(wand_id, component_id)
                end
            end
        end

        kill_wands(altar_id)
    end
end

function get_wand(altar_id)
    local wand_id = EntityGetParent(altar_id)
    if wand_id ~= 0 and not EntityHasTag(wand_id, "wand") then
        print("Error: Altar has non-wand parent.")
        return 0
    end
    return wand_id
end

function get_altar(wand_id)
    local children = EntityGetAllChildren(wand_id)
    if children ~= nil then
        for i, child in ipairs(children) do
            if EntityHasTag(child, "wand_workshop_altar") then return child end
        end
    end
    return nil
end

function kill_wand(wand_id, altar_id, material)
    local wand_x, wand_y = EntityGetTransform(wand_id)
    if material ~= nil then
        local particle_id = EntityLoad("mods/wand_workshop/files/entities/particles/small_effect.xml", wand_x, wand_y)
        local component_id = EntityGetFirstComponentIncludingDisabled(particle_id, "ParticleEmitterComponent")
        ComponentSetValue2(component_id, "emitted_material_name", material)
    end

    unlink_altar_wand(altar_id, wand_id)
    local children = EntityGetAllChildren(wand_id)
    if children ~= nil then
        for i, child in ipairs(children) do
            if EntityHasTag(child, "card_action") then
                local item_component = EntityGetFirstComponentIncludingDisabled(child, "ItemComponent")
                if item_component ~= nil then
                    if ComponentGetValue2(item_component, "permanently_attached") or ComponentGetValue2(item_component, "is_frozen") then
                        print("Found always cast spell")
                    else --EntityAddComponent(child, "LuaComponent"
                        EntityRemoveFromParent(child)
                        EntitySetComponentsWithTagEnabled(child, "enabled_in_world", true)
                        EntitySetTransform(child, wand_x, wand_y)
                        SetRandomSeed(wand_x + wand_id, wand_y + child)
                        local rangle = Randomf(-math.pi, math.pi)
                        local force = RandomDistributionf(0, 100, 50)
                        ComponentSetValue2(EntityGetFirstComponentIncludingDisabled(child, "VelocityComponent"), "mVelocity", force * math.sin(rangle), force * math.cos(rangle))
                    end
                else
                    print("Spell without ItemComponent found. This should not happen: Erasing")
                end
            end
        end
    end

    EntityConvertToMaterial(wand_id, "gold")
    EntityKill(wand_id)
end

function kill_wands(altar_id)
    local pos_x, pos_y = EntityGetTransform(altar_id)
    for i = 1, #altars do
        local altar = altars[i]
        local sub_altar_id = EntityGetClosestWithTag(pos_x, pos_y, altar.tag)
        local wand_id = get_wand(sub_altar_id)
        if wand_id ~= 0 then kill_wand(wand_id, sub_altar_id, altar.material) end
    end
end

function reset_wands(altar_id)
    if not EntityHasTag(altar_id, "Wand_Altar") then
        local pos_x, pos_y = EntityGetTransform(altar_id)
        altar_id = EntityGetClosestWithTag(pos_x, pos_y, "Wand_Altar")
    end

    local wand_id = get_wand(altar_id)
    if wand_id == nil then return end
    local ability_component_id = get_wand_ability_component(wand_id)
    if ability_component_id == nil then return end
    for j = 1, #altars do
        local altar = altars[j]
        local component_id = EntityGetFirstComponentWithVariable(wand_id, "VariableStorageComponent", "name", altar.property, "wand_altar_statbuffer")
        if component_id ~= nil then
            if altar.object == nil then
                ComponentSetValue2(ability_component_id, altar.property, ComponentGetValue2(component_id, altar.var_field))
            else
                ComponentObjectSetValue2(ability_component_id, altar.object, altar.property, ComponentGetValue2(component_id, altar.var_field))
            end

            EntityRemoveComponent(wand_id, component_id)
        end
    end
end

function merge_wands(altar_id, target_wand)
    if not EntityHasTag(altar_id, "Wand_Altar") then
        local pos_x, pos_y = EntityGetTransform(altar_id)
        altar_id = EntityGetClosestWithTag(pos_x, pos_y, main_altar_tag)
    end

    if target_wand == nil or target_wand == 0 then
        target_wand = get_wand(altar_id)
        if target_wand == 0 then return end
    end

    local trg_component_id = get_wand_ability_component(target_wand)
    if trg_component_id == nil then
        print("Error, bad wand on Main_Altar")
        return
    end

    local pos_x, pos_y = EntityGetTransform(altar_id)
    for i = 1, #altars do
        local altar = altars[i]
        local sub_altar_id = EntityGetClosestWithTag(pos_x, pos_y, altar.tag)
        local wand_id = get_wand(sub_altar_id)
        if wand_id ~= 0 then
            local src_component_id = get_wand_ability_component(wand_id)
            if src_component_id ~= nil then
                combine_wand_stats(altar, target_wand)
            else --kill_wand(wand_id, sub_altar_id, altar.material)
                print("Error, bad wand on " .. altar.tag .. "; skipping")
            end
        end
    end
end

function combine_wand_stats(altar, target_wand)
    if altar.omni == nil then
        ensure_stat_buffer_exists(target_wand, altar.property)
        set_component_stats(trg_component_id, var_component_id, altar, false)
    else
        local omnis = altar.omni
        for o = 1, #omnis do
            local omni = omnis[o]
            ensure_stat_buffer_exists(target_wand, omni.property)
            set_component_stats(trg_component_id, var_component_id, omni, true)   
        end
    end
end

function ensure_stat_buffer_exists(target_wand, property)
    local var_component_id = EntityGetFirstComponentWithVariable(target_wand, "VariableStorageComponent", "name", property, "wand_altar_statbuffer")
    if var_component_id == nil then
        var_component_id = EntityAddComponent(target_wand, "VariableStorageComponent", {
            name = property,
            _tags = "wand_altar_statbuffer"
        })
    end
end

function set_component_stats(trg_component_id, var_component_id, altar, isOmni)
    if altar_object == nil then
        local old = ComponentGetValue2(trg_component_id, altar.property)
        ComponentSetValue2(var_component_id, altar.var_field, old)
        local val = ComponentGetValue2(src_component_id, altar.property)
        if type(val) == "number" and type(old) == "number" then
            val = adjust_val_for_growth(old, val, isOmni, altar.operator)
        end
        ComponentSetValue2(trg_component_id, altar.property, val)
    else
        local old = ComponentObjectGetValue2(trg_component_id, altar.object, altar.property)
        ComponentSetValue2(var_component_id, altar.var_field, old)
        local val = ComponentObjectGetValue2(src_component_id, altar.object, altar.property)
        if type(val) == "number" and type(old) == "number" then
            val = adjust_val_for_growth(old, val, isOmni, altar.operator)
        end
        ComponentObjectSetValue2(trg_component_id, altar.object, altar.property, val)
    end
end

function adjust_val_for_growth(old, val, isOmni, altar_operator)
    local baseVal = get_base_value(old, val, altar_operator)
    local growthVal = get_growth_value(old, val, isOmni, altar_operator)
    return baseVal + growthVal
end

function get_base_value(old, val, isOmni, altar_operator)
    local ratio = ModSettingGet("wand_workshop.mix_fraction")
    if type(ratio) == "number" then
        local isAdditive = altar_operator == "additive"
        local isReductive = altar_operator == "reductive"
        ratio = clean_precision(ratio)
        if ratio > 1 then -- if ratio is > 100% and the target has better stats than the sacrifice
            if (isAdditive and old >= val) or (isReductive and old <= val) then
                val = old -- don't replace the value, it's worse than the old one!
            end
            ratio = 1
        end
        if isOmni then
            val = old
        else
            val = ratio * val + (1 - ratio) * old
        end
    end
    return val -- maybe modified, maybe not
end

function get_growth_value(old, val, isOmni, altar_operator)
    local override = ModSettingGet("wand_workshop.omni_override")
    local ratio = ModSettingGet("wand_workshop.mix_fraction")
    if type(override) == "number" and override > 0 then
        ratio = clean_precision(override)
    elseif type(ratio) == "number" and ratio > 1 then
        ratio = clean_precision((ratio - 1) / 2)
    else
        ratio = 0
    end
    local growth = 0  
    if ratio > 0 then       
        local isAdditive = altar_operator == "additive"
        local isReductive = altar_operator == "reductive"    
        local hasImprovement = ((isAdditive and old >= val) or (isReductive and old <= val))
        -- other pillars replace the stat unless the wand is better
        if isOmni or hasImprovement then
            growth = ratio * val
        end
        if isReductive and growth > 0
            growth = growth * -1 -- invert for reductive values
        end        
    end
    return growth
end

function clean_precision(d)
    if d ~= math.floor(d * 100 + 0.5) / 100 then -- make it not an ugly number...
        d = math.floor(d * 100 + 0.5) / 100
    end
    return d
end