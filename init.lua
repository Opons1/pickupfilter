local storage = core.get_mod_storage()

core.register_on_item_pickup(function(itemstack, player)
    if not player or not player:is_player() then
        return
    end
    local name = player:get_player_name()
    local item = itemstack:get_name()
    if storage:get_string(name .. " " .. item) == "f" then
        return itemstack 
    end
end)
core.register_chatcommand("toggle_blacklist", {
    params = "[item_name]",
    description = "Toggle blacklist for picking up item (uses held item if blank)",
    func = function(name, param)
        param = param:trim()
        if param == "" then
            local player = core.get_player_by_name(name)
            if player then
                param = player:get_wielded_item():get_name()
            end
        end
        if param == "" then
            return false, " You must specify an item or hold one!"
        end
        local key = name .. " " .. param
        if storage:get_string(key) == "f" then
            storage:set_string(key, "")
            return true, " Allowed pickup for: " .. param
        else
            storage:set_string(key, "f")
            return true, " Blacklisted pickup for: " .. param
        end
    end
})

core.register_on_mods_loaded(function()
    local old_handle_node_drops = core.handle_node_drops
    core.handle_node_drops = function(pos, drops, digger)
        if not digger or not digger:is_player() then
            return old_handle_node_drops(pos, drops, digger)
        end
        local name = digger:get_player_name()
        local filtered_drops = {}
        for _, item in ipairs(drops) do
            local item_name = ItemStack(item):get_name() or item
            if storage:get_string(name .. " " .. item_name) ~= "f" then
                table.insert(filtered_drops, item)
            end
        end
        return old_handle_node_drops(pos, filtered_drops, digger)
    end
end)
