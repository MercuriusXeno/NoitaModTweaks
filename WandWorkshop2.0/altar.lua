dofile_once("mods/wand_workshop/files/scripts/lib/ComponentUtils.lua")
dofile_once("mods/wand_workshop/files/scripts/config.lua")
dofile_once("data/scripts/lib/utilities.lua")

function hover_wand(wand_id,altar_id)
  local x,y = EntityGetTransform(altar_id)
  local component_id = EntityGetFirstComponentIncludingDisabled(wand_id, "ItemComponent")
  if component_id ~= nil then
    ComponentSetValue2(component_id, "has_been_picked_by_player", false)
    ComponentSetValue2(component_id, "play_hover_animation", true)
    ComponentSetValue2(component_id, "spawn_pos", x + altar_wand_offset_x, y + altar_wand_offset_y)
  end
  
  component_id = EntityGetFirstComponentWithVariable(wand_id, "LuaComponent", "script_item_picked_up", "data/scripts/particles/wand_pickup.lua")
  if component_id ~= nil then
    EntitySetComponentIsEnabled(wand_id, component_id, true)
  end
  
  component_id = EntityGetFirstComponentIncludingDisabled(wand_id, "SimplePhysicsComponent")
  if component_id ~= nil then
    EntitySetComponentIsEnabled(wand_id, component_id, false)
  end
  
  component_id = EntityGetFirstComponentWithVariable(wand_id, "SpriteParticleEmitterComponent", "velocity_always_away_from_center", nil)
  if component_id ~= nil then
    EntitySetComponentIsEnabled(wand_id, component_id, true)
  end
end

function get_wand_ability_component(wand_id)
  return EntityGetFirstComponentIncludingDisabled(wand_id, "AbilityComponent")
end

local main_altar_tag = "Wand_Altar"

local altars = {
  {
    tag = "Speed_Altar",
    object = "gunaction_config",
    property = "fire_rate_wait",
    var_field = "value_int",
    material = "spark_yellow",
    additive = false
  },
  {
    tag = "Reload_Altar",
    object = "gun_config",
    property = "reload_time",
    var_field = "value_int",
    material = "spark_red",
    additive = false
  },
  {
    tag = "Mana_Altar",
    object = nil,
    property = "mana_max",
    var_field = "value_int",
    material = "spark_blue",
    additive = true
  },
  {
    tag = "Recharge_Altar",
    object = nil,
    property = "mana_charge_speed",
    var_field = "value_int",
    material = "spark_teal",
    additive = true
  },
  {
    tag = "Shuffle_Altar",
    object = "gun_config",
    property = "shuffle_deck_when_empty",
    var_field = "value_bool",
    material = "spark_green",
    additive = false
  },
  {
    tag = "Simulcast_Altar",
    object = "gun_config",
    property = "actions_per_round",
    var_field = "value_int",
    material = "spark_player",
    additive = true
  },
  {
    tag = "Spread_Altar",
    object = "gunaction_config",
    property = "spread_degrees",
    var_field = "value_int",
    material = "spark_yellow",
    additive = false
  },
  {
    tag = "Capacity_Altar",
    object = "gun_config",
    property = "deck_capacity",
    var_field = "value_int",
    material = "spark_white",
    additive = true
  }
}

function link_altar_wand(altar_id, wand_id)
  EntityAddChild(wand_id, altar_id)
  EntitySetComponentsWithTagEnabled(altar_id, "wand_pickup", false )
  EntitySetComponentsWithTagEnabled(altar_id, "wand_effect", true )
  if not EntityHasTag(altar_id, "Wand_Altar") then
    reset_wands(altar_id)
    merge_wands(altar_id)
  else
    merge_wands(altar_id, wand_id)
  end
end

function unlink_altar_wand(altar_id, wand_id)
  EntityRemoveFromParent(altar_id)
  EntitySetComponentsWithTagEnabled(altar_id, "wand_pickup", true )
  EntitySetComponentsWithTagEnabled(altar_id, "wand_effect", false )
  if not EntityHasTag(altar_id, "Wand_Altar") then
    reset_wands(altar_id)
    merge_wands(altar_id)
  else
    for i=1,#altars,1 do
      local altar = altars[i]
      local component_ids = EntityGetComponentIncludingDisabled(wand_id, "VariableStorageComponent", "wand_altar_statbuffer")
      if component_ids ~= nil then
        for j,component_id in pairs(component_ids) do
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
    for i,child in ipairs(children) do
      if EntityHasTag(child,"wand_workshop_altar") then
        return child
      end
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
            --EntityAddComponent(child, "LuaComponent"
          else
            EntityRemoveFromParent(child)
            EntitySetComponentsWithTagEnabled(child, "enabled_in_world", true )
            EntitySetTransform(child, wand_x, wand_y)
            SetRandomSeed(wand_x+wand_id, wand_y+child)
            local rangle = Randomf(-math.pi, math.pi)
            local force = RandomDistributionf( 0, 100, 50)
            ComponentSetValue2( EntityGetFirstComponentIncludingDisabled(child, "VelocityComponent"), "mVelocity", force*math.sin(rangle), force*math.cos(rangle) )
          end
        else
          print("Spell without ItemComponent found. This should not happen: Erasing")
        end
      end
    end
  end
  EntityConvertToMaterial(wand_id,"gold")
  EntityKill(wand_id)
end

function kill_wands(altar_id)
  local pos_x, pos_y = EntityGetTransform(altar_id)
  for i=1,#altars,1 do
    local altar = altars[i]
    local sub_altar_id = EntityGetClosestWithTag(pos_x, pos_y, altar.tag)
    local wand_id = get_wand(sub_altar_id)
    if wand_id ~= 0 then
      kill_wand(wand_id, sub_altar_id, altar.material)
    end
  end
end

function reset_wands(altar_id)
  if not EntityHasTag(altar_id, "Wand_Altar") then
    local pos_x, pos_y = EntityGetTransform(altar_id)
    altar_id = EntityGetClosestWithTag(pos_x, pos_y, "Wand_Altar")
  end
  local wand_id = get_wand(altar_id)
  if wand_id == nil then
    return
  end
  local ability_component_id = get_wand_ability_component(wand_id)
  if ability_component_id == nil then
    return
  end
  for j=1,#altars,1 do
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
    if target_wand == 0 then
      return
    end
  end
  local trg_component_id = get_wand_ability_component(target_wand)
  if trg_component_id == nil then
    print("Error, bad wand on Main_Altar")
    return
  end
  local pos_x, pos_y = EntityGetTransform(altar_id)
  for i=1,#altars,1 do
    local altar = altars[i]
    local isAdditive = altar.additive
    local sub_altar_id = EntityGetClosestWithTag(pos_x, pos_y, altar.tag)
    local wand_id = get_wand(sub_altar_id)
    if wand_id ~= 0 then
      local src_component_id = get_wand_ability_component(wand_id)
      if src_component_id ~= nil then
        local var_component_id = EntityGetFirstComponentWithVariable(target_wand, "VariableStorageComponent", "name", altar.property, "wand_altar_statbuffer")
        if var_component_id == nil then
          var_component_id = EntityAddComponent(target_wand, "VariableStorageComponent", {
            name = altar.property,
            _tags = "wand_altar_statbuffer"
          })
        end
        if altar.object == nil then
          local old = ComponentGetValue2(trg_component_id, altar.property)
          ComponentSetValue2(var_component_id, altar.var_field, old)
          local val = ComponentGetValue2(src_component_id, altar.property)
          local flat = 0
          if type(val) == "number" and type(old) == "number" then
            local ratio = ModSettingGet("wand_workshop.mix_fraction")
            -- if ratio is > 100% and the target has better stats than the sacrifice
            if ratio > 1 and ((isAdditive and old > val) or (not isAdditive and old < val)) then
              -- clamp the ratio at 1 for the next step, but capture an additive bonus
              flat = (ratio - 1) * val
              ratio = 1
              val = old -- don't replace the value, it's worse than the old one!
            end
          	if type(ratio) == "number" then
          	  val = ratio * val + (1 - ratio) * old
          	end
            if type(flat) == "number" and flat > 0 then
              if isAdditive then
                val = val + flat
              else
                val = val - flat
              end
            end
          end
          ComponentSetValue2(trg_component_id, altar.property, val)
        else
          local old = ComponentObjectGetValue2(trg_component_id, altar.object, altar.property)
          ComponentSetValue2(var_component_id, altar.var_field, old)
          
          local val = ComponentObjectGetValue2(src_component_id, altar.object, altar.property)
          local flat = 0
          if type(val) == "number" and type(old) == "number" then
            local ratio = ModSettingGet("wand_workshop.mix_fraction")
            -- if ratio is > 100% and the target has better stats than the sacrifice
            if ratio > 1 and ((isAdditive and old > val) or (not isAdditive and old < val)) then
              -- clamp the ratio at 1 for the next step, but capture an additive bonus
              flat = (ratio - 1) * val
              ratio = 1
              val = old -- don't replace the value, it's worse than the old one!
            end
          	if type(ratio) == "number" then
          	  val = ratio * val + (1 - ratio) * old
          	end
            if type(flat) == "number" and flat > 0 then
              if isAdditive then
                val = val + flat
              else
                val = val - flat
              end
            end
          end
          ComponentObjectSetValue2(trg_component_id, altar.object, altar.property, val)
        end
        --kill_wand(wand_id, sub_altar_id, altar.material)
      else
        print("Error, bad wand on "..altar.tag.."; skipping")
      end
    end
  end
end
