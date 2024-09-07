local total_accumulated_gold = 0
local entities_suckers = EntityGetWithTag("leezo_gold_sucker")
if (#entities_suckers == 0) then return end

for index = 1, #entities_suckers do
    local entity_sucker = entities_suckers[index]

    local component_sucker = EntityGetFirstComponent(entity_sucker, "MaterialSuckerComponent")
    local compovar_accumulated = EntityGetFirstComponent(entity_sucker, "VariableStorageComponent")

    if (component_sucker ~= nil and compovar_accumulated ~= nil) then
        local accumulated_currently = ComponentGetValue2(component_sucker, "mGoldAccumulator")
        local accumulated_last_frame = ComponentGetValue2(compovar_accumulated, "value_int")

        if (accumulated_currently ~= accumulated_last_frame) then
            if (accumulated_currently > accumulated_last_frame) then
                total_accumulated_gold = total_accumulated_gold + (accumulated_currently - accumulated_last_frame)
            end
    
            ComponentSetValue(compovar_accumulated, "value_int", accumulated_currently)
        end
    end
end

if (total_accumulated_gold > 0) then
    local player = EntityGetWithTag("player_unit")
    
    if (#player > 0) then
        local x, y = EntityGetTransform(player[1])
        local wallet = EntityGetFirstComponent(player[1], "WalletComponent")
        ComponentSetValue2(wallet, "money", ComponentGetValue2(wallet, "money") + total_accumulated_gold)
    end
end