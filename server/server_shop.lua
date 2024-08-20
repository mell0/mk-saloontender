local VORPcore = exports.vorp_core:GetCore()
local VorpInv = exports.vorp_inventory:vorp_inventoryApi()


RegisterServerEvent('mk-saloontendershop:server:GetShopItems')
AddEventHandler('mk-saloontendershop:server:GetShopItems', function(data)
    local _source = source
    MySQL.query('SELECT * FROM saloontendershop_stock WHERE shopid = ?', {data.shopId}, function(data2)
        MySQL.query('SELECT * FROM saloontender_shop WHERE shopid = ?', {data.shopId}, function(data3)
            TriggerClientEvent('mk-saloontendershop:client:ReturnStoreItems', _source, data2, data3, data.shopId)
        end)
    end)
end)

VORPcore.Callback.Register('mk-saloontendershop:server:shops', function(source, cb, shopId)
    MySQL.query('SELECT * FROM saloontender_shop WHERE shopid = ?', {shopId}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

VORPcore.Callback.Register('mk-saloontendershop:server:Stock', function(source, cb, saloonLoc)
    MySQL.query('SELECT * FROM saloontender_stock WHERE saloontender = ?', { saloonLoc }, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('mk-saloontendershop:server:InvReFill')
AddEventHandler('mk-saloontendershop:server:InvReFill', function(shopId, item, name, qt, price, saloonLoc)
    local _source = source
    MySQL.query('SELECT * FROM saloontendershop_stock WHERE shopid = ? AND item = ?',{shopId, item} , function(result)
        if result[1] ~= nil then
            local stockadd = result[1].stock + tonumber(qt)
            MySQL.update('UPDATE saloontendershop_stock SET stock = ?, price = ? WHERE shopid = ? AND item = ?',{stockadd, price, shopId, item})
        else
            MySQL.insert('INSERT INTO saloontendershop_stock (`shopid`, `item`, `stock`, `price`) VALUES (?, ?, ?, ?);',{shopId, item, qt, price})
        end
    end)
    MySQL.query('SELECT * FROM saloontender_stock WHERE saloontender = ? AND item = ?',{saloonLoc, item} , function(result)
        if result[1] ~= nil then
            local stockremove = result[1].stock - tonumber(qt)
            MySQL.update('UPDATE saloontender_stock SET stock = ? WHERE saloontender = ? AND item = ?',{stockremove, saloonLoc, item})
        else
            MySQL.insert('INSERT INTO saloontender_stock (`saloontender`, `item`, `stock`) VALUES (?, ?, ?);', {saloonLoc, item, qt})
        end
    end)

    VORPcore.NotifyTip(_source, _U('lang_s26'), 5000)
end)

RegisterServerEvent('mk-saloontendershop:server:PurchaseItem')
AddEventHandler('mk-saloontendershop:server:PurchaseItem', function(shopId, item, name, amount, stock)
    local _source = source
    if stock < tonumber(amount) then
	VORPcore.NotifyTip(_source, _U('lang_s20'), 5000)
	return
    end

    local Character = VORPcore.getUser(_source).getUsedCharacter
    local money = Character.money
	
    MySQL.query('SELECT * FROM saloontendershop_stock WHERE shopid = ? AND item = ?',{shopId, item} , function(data)
        local stock = data[1].stock - amount
        local price = data[1].price * amount   
        if price <= money then
            MySQL.update("UPDATE saloontendershop_stock SET stock=@stock WHERE shopid=@location AND item=@item", {['@stock'] = stock, ['@location'] = shopId, ['@item'] = item}, function(count)
                if count > 0 then
		    Character.removeCurrency(0, price)
	            VorpInv.addItem(_source, item, amount)
                    MySQL.query("SELECT * FROM saloontender_shop WHERE shopid=@location", { ['@location'] = shopId }, function(data2)
                        local moneymarket = data2[1].money + price
                        MySQL.update('UPDATE saloontender_shop SET money = ? WHERE shopid = ?',{moneymarket, shopId})
                    end)
			VORPcore.NotifyTip(_source, _U('lang_s27').." "..amount.."x "..name, 5000)
                end
            end)
        else 
		VORPcore.NotifyTip(_source, _U('lang_s28'), 5000)
        end
    end)
end)

RegisterServerEvent('mk-saloontendershop:server:CreateShop')
AddEventHandler('mk-saloontendershop:server:CreateShop', function(shopId, jobaccess, displayname)
    MySQL.insert('INSERT INTO saloontender_shop (`shopid`, `jobaccess`, `displayname`) VALUES (?, ?, ?);',{shopId, jobaccess, displayname})    
end)

VORPcore.Callback.Register('mk-saloontendershop:server:GetMoney', function(source, cb, shopId)
    MySQL.query('SELECT * FROM saloontender_shop WHERE shopid = ?', {shopId}, function(checkmoney)
        if checkmoney[1] then
            cb(checkmoney[1])
        else
            cb(nil)
        end
    end)
end)


RegisterServerEvent('mk-saloontendershop:server:Withdraw')
AddEventHandler('mk-saloontendershop:server:Withdraw', function(shopId, smoney)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter

    MySQL.query('SELECT * FROM saloontender_shop WHERE shopid = ?',{shopId} , function(result)
        if result[1] ~= nil then
            if result[1].money >= tonumber(smoney) then
                local nmoney = result[1].money - smoney
                MySQL.update('UPDATE saloontender_shop SET money = ? WHERE shopid = ?',{nmoney, shopId})
		Character.addCurrency(0, smoney)
		VORPcore.NotifyTip(_source, _U('lang_s32')..smoney, 5000)
            end
        end
    end)
end)
