function OnPlayerSpawned(entity_player)
    if (GameHasFlagRun("LEEZO_GOLDSUCKER_MOD_INIT")) then return end

    -- EntityRemoveComponent(player, EntityGetFirstComponent(player, "MaterialSuckerComponent"))

    local x, y = EntityGetTransform(entity_player)
    local entity_gold_sucker = EntityLoad("mods/leezo_goldsucker_mod/files/gold_sucker.xml", x, y)
    EntityAddChild(entity_player, entity_gold_sucker)

    GameAddFlagRun("LEEZO_GOLDSUCKER_MOD_INIT")
end