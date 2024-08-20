local VORPcore = exports.vorp_core:GetCore()
local VorpInv = exports.vorp_inventory:vorp_inventoryApi()


VORPcore.Callback.Register('mk-saloontender:server:checkingredients', function(source, cb, ingredients)
    local _source = source
    local hasItems = false
    local icheck = 0
	
    for k, v in pairs(ingredients) do
	if VorpInv.getItemCount(_source, v.item) >= v.amount then
            icheck = icheck + 1
            if icheck == #ingredients then
                cb(true)
            end
        else
            VORPcore.NotifyTip(_source, _U('lang_12'), 5000)
            cb(false)
            return
        end
    end
end)


RegisterServerEvent('mk-saloontender:server:finishcrafting')
AddEventHandler('mk-saloontender:server:finishcrafting', function(saloonCraftingLoc, ingredients, title, receive, giveamount)
    local _source = source
    for k, v in pairs(ingredients) do
        VorpInv.subItem(_source, v.item, v.amount)
    end

    MySQL.query('SELECT * FROM saloontender_stock WHERE saloontender = ? AND item = ?',{saloonCraftingLoc, receive} , function(result)
        if result[1] ~= nil then
            local stockadd = result[1].stock + giveamount
            MySQL.update('UPDATE saloontender_stock SET stock = ? WHERE saloontender = ? AND item = ?',{stockadd, saloonCraftingLoc, receive})
        else
            MySQL.insert('INSERT INTO saloontender_stock (`saloontender`, `item`, `stock`) VALUES (?, ?, ?);', {saloonCraftingLoc, receive, giveamount})
        end
    end)
    VORPcore.NotifyTip(_source, 'You cooked '..title, 3000)
    return
end)


RegisterNetEvent("mk-saloontender:server:OpenContainer") -- inventory system
AddEventHandler("mk-saloontender:server:OpenContainer", function(containerid, name, storage_limit)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local data = {
        id = containerid,
        name = name,
        limit = storage_limit,
        acceptWeapons = false,
        shared = true,
        ignoreItemStackLimit = false,
        whitelistItems = false,
        UsePermissions = false,
        UseBlackList = false,
        whitelistWeapons = false
    }
    exports.vorp_inventory:registerInventory(data)
    exports.vorp_inventory:openInventory(_source, containerid)
        
end)
