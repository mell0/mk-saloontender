local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()


Citizen.CreateThread(function()
    local SaloonShopPrompt = BccUtils.Prompts:SetupPromptGroup()
    local saloonprompt = SaloonShopPrompt:RegisterPrompt(_U('lang_s1'), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})
    for h,v in pairs(Config.SaloonShops) do
	if v.showblip then
            local blip = BccUtils.Blips:SetBlip(v.shopname, Config.ShopBlip.blipSprite, Config.ShopBlip.blipScale, v.coords.x,v.coords.y,v.coords.z)
	end
    end
    
    while true do
        Wait(1)
        for h,v in pairs(Config.SaloonShops) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = #(playerCoords - v.coords)
            if dist < 2 then
                SaloonShopPrompt:ShowGroup(v.shopname)

                if saloonprompt:HasCompleted() then
                    TriggerEvent('mk-saloontendershop:client:saloonshopMenu', v.jobaccess, v.jobgrade, v.shopid, v.location) break
                end
            end
        end
    end
end)


for _, v in pairs(Config.SaloonShops) do
    local result =  VORPcore.Callback.TriggerAwait('mk-saloontendershop:server:shops', v.shopid)
    if result == nil then
        TriggerServerEvent('mk-saloontendershop:server:CreateShop', v.shopid, v.jobaccess, v.shopname)  
    end
end


RegisterNetEvent('mk-saloontendershop:client:saloonshopMenu', function(jobAccess, jobGrade, shopId, saloonLoc)
    local src = source
    local character = LocalPlayer.state.Character
    local characterJob = character.Job
    local characterJobGrade = character.Grade
    if characterJob == jobAccess and characterJobGrade >= jobGrade then
        lib.registerContext({
            id = 'saloon_owner_shop_menu',
            title = _U('lang_s2'),
            options = {
                {
                    title = _U('lang_s3'),
                    description = _U('lang_s4'),
                    icon = 'fa-solid fa-store',
                    serverEvent = 'mk-saloontendershop:server:GetShopItems',
                    args = { 
	                shopId = shopId
		    },
                    arrow = true
                },
                {
                    title = _U('lang_s5'),
                    description = _U('lang_s6'),
                    icon = 'fa-solid fa-boxes-packing',
                    event = 'mk-saloontendershop:client:InvReFull',
                    args = {
                        saloonLoc = saloonLoc,
			shopId = shopId,
		    },
                    arrow = true
                },
                {
                    title = _U('lang_s7'),
                    description = _U('lang_s8'),
                    icon = 'fa-solid fa-sack-dollar',
                    event = 'mk-saloontendershop:client:CheckMoney',
                    args = { 
	                shopId = shopId
		    },
                    arrow = true
                },
            }
        })
        lib.showContext("saloon_owner_shop_menu")
    else
        lib.registerContext({
            id = 'saloon_customer_shop_menu',
            title = _U('lang_s9'),
            options = {
                {
                    title = _U('lang_s10'),
                    description = _U('lang_s11'),
                    icon = 'fa-solid fa-store',
                    serverEvent = 'mk-saloontendershop:server:GetShopItems',
                    args = { shopId = shopId  },
                    arrow = true
                },
            }
        })
        lib.showContext("saloon_customer_shop_menu")
    end
end)


RegisterNetEvent('mk-saloontendershop:client:ReturnStoreItems')
AddEventHandler('mk-saloontendershop:client:ReturnStoreItems', function(data2, data3, shopId)
    Wait(100)
    TriggerEvent('mk-saloontendershop:client:Inv', data2, data3, shopId)
end)


RegisterNetEvent("mk-saloontendershop:client:Inv", function(store_inventory, data, shopId)
    local result =  VORPcore.Callback.TriggerAwait('mk-saloontendershop:server:shops', shopId)
    
    local options = {}
    for k, v in ipairs(store_inventory) do
        if store_inventory[k].stock > 0 then
	    local itemimg = "nui://"..Config.img..store_inventory[k].item..".png" 
            options[#options + 1] = {
                title = Config.CraftingItems[store_inventory[k].item].name,
                description = 'Stock: '..store_inventory[k].stock..' | '.._U('lang_s12')..string.format("%.2f", store_inventory[k].price),
                icon = itemimg,
                event = 'mk-saloontendershop:client:InvInput',
                args = {
		    storeItem = store_inventory[k],
                    shopId = shopId
		},
                arrow = true,
            }
        end
    end
    lib.registerContext({
        id = 'saloon_shopinv_menu',
        title = _U('lang_s13'),
        position = 'top-right',
        options = options
    })

    lib.showContext('saloon_shopinv_menu')
end)


RegisterNetEvent("mk-saloontendershop:client:InvReFull", function(data)
    local result =  VORPcore.Callback.TriggerAwait('mk-saloontendershop:server:Stock', data.saloonLoc)
	
    if result == nil then
        lib.registerContext({
            id = 'saloon_no_inventory',
            title = _U('lang_s14'),
            menu = 'saloon_owner_shop_menu',
            onBack = function() end,
            options = {
                {
                    title = _U('lang_s29'),
                    description = _U('lang_s30'),
                    icon = 'fa-solid fa-box',
                    disabled = true,
                    arrow = false
                }
            }
        })
        lib.showContext("saloon_no_inventory")

    else
        local options = {}
        for k, v in ipairs(result) do
	    local itemimg = "nui://"..Config.img..v.item..".png"
            options[#options + 1] = {
                title = Config.CraftingItems[result[k].item].name,
                description = 'inventory amount : '..result[k].stock,
                icon = itemimg,
                event = 'mk-saloontendershop:client:InvReFillInput',
                args = {
                    item = result[k].item,
                    name = result[k].name,
                    stock = result[k].stock,
		    saloonLoc = data.saloonLoc,
		    shopId = data.shopId
                },
                arrow = true,
            }
        end
        
	lib.registerContext({
            id = 'saloon_inv_menu',
            title = _U('lang_s14'),
            menu = 'saloon_owner_shop_menu',
            onBack = function() end,
            position = 'top-right',
            options = options
        })
        lib.showContext('saloon_inv_menu')
    end
end)


RegisterNetEvent('mk-saloontendershop:client:InvReFillInput', function(data)
    local item = data.item
    local stock = data.stock
    local name = Config.CraftingItems[data.item].name
    local input = lib.inputDialog(_U('lang_s31').." : "..name, {
        { 
            label = _U('lang_s15'),
            description = _U('lang_s16'),
            type = 'number',
            required = true,
            icon = 'hashtag'
        },
        { 
            label = _U('lang_s17'),
            description = _U('lang_s18'),
            default = '0.10',
            type = 'input',
            required = true,
            icon = 'fa-solid fa-dollar-sign'
        },
    })
    
    if not input then
        return
    end
    
	if stock >= tonumber(input[1]) and tonumber(input[2]) ~= nil then
		TriggerServerEvent('mk-saloontendershop:server:InvReFill', data.shopId, item, name, input[1], tonumber(input[2]), data.saloonLoc)
	else	
		VORPcore.NotifyTip(_U('lang_s19'), 5000)
	end
end)


RegisterNetEvent('mk-saloontendershop:client:InvInput', function(data)
    local _source = source
    local item = data.storeItem.item
    local name = Config.CraftingItems[data.storeItem.item].name
    local price = data.storeItem.price
    local stock = data.storeItem.stock
    local input = lib.inputDialog(name.." | $"..string.format("%.2f", price).." | Stock: "..stock, {
        { 
            label = _U('lang_s15'),
            type = 'number',
            required = true,
            icon = 'hashtag'
        },
    })
    
    if not input then
        return
    end
    
    TriggerServerEvent('mk-saloontendershop:server:PurchaseItem', data.shopId, item, name, input[1], stock)
end)


RegisterNetEvent("mk-saloontendershop:client:CheckMoney", function(data)

	local checkmoney =  VORPcore.Callback.TriggerAwait('mk-saloontendershop:server:GetMoney', data.shopId)
	local result =  VORPcore.Callback.TriggerAwait('mk-saloontendershop:server:shops', data.shopId)
	lib.registerContext({
        id = 'money_menu',
        title = _U('lang_s21') ..string.format("%.2f", checkmoney.money),
        menu = 'saloon_owner_shop_menu',
        onBack = function() end,
        options = {
            {
                title = _U('lang_s22'),
                description = _U('lang_s23'),
                icon = 'fa-solid fa-money-bill-transfer',
                event = 'mk-saloontendershop:client:Withdraw',
                args = {
	            money = checkmoney.money,
		    shopId = data.shopId
		},
                arrow = true
            },
        }
    })
    lib.showContext("money_menu")
end)


RegisterNetEvent('mk-saloontendershop:client:Withdraw', function(data)
    local input = lib.inputDialog(_U('lang_s24')..string.format("%.2f", data.money), {
        { 
            label = _U('lang_s25'),
            type = 'input',
            required = true,
            icon = 'fa-solid fa-dollar-sign'
        },
    })
    
    if not input then
        return
    end
    
    if tonumber(input[1]) == nil then
        return
    end

    if data.money >= tonumber(input[1]) then
        TriggerServerEvent('mk-saloontendershop:server:Withdraw', data.shopId, tonumber(input[1]))
    else
	VORPcore.NotifyTip(_U('lang_s20'), 5000)
    end
end)
