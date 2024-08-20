local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local Animations = exports.vorp_animations.initiate()
local progressbar = exports.vorp_progressbar:initiate()
local CategoryMenus = {}


Citizen.CreateThread(function()
    local SaloonPrompt = BccUtils.Prompts:SetupPromptGroup()
    local saloonprompt = SaloonPrompt:RegisterPrompt(_U('lang_0'), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})

    for h,v in pairs(Config.SaloonCraftingPoint) do
        if v.showblip then	
            BccUtils.Blips:SetBlip(v.name, Config.SaloonBlip.blipSprite, Config.SaloonBlip.blipScale, v.coords.x,v.coords.y,v.coords.z)
	end
    end

    while true do
        Wait(1)
        for h,v in pairs(Config.SaloonCraftingPoint) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = #(playerCoords - v.coords)
            if dist < 2 then
                SaloonPrompt:ShowGroup(v.name)
                if saloonprompt:HasCompleted() then
                    TriggerEvent('mk-saloontender:client:mainmenu', v.job, v.jobgrade, v.location, v.name) break
                end
            end
        end
    end
end)


RegisterNetEvent('mk-saloontender:client:mainmenu', function(jobAccess, jobGrade, saloonLoc, saloonName)
   
    local playerJob = LocalPlayer.state.Character.Job 
    local playerJobGrade = LocalPlayer.state.Character.Grade

    if playerJob == jobAccess and playerJobGrade >= jobGrade then
        lib.registerContext({
            id = 'saloon_mainmenu',
            title = _U('lang_1'),
            options = {
                {
                    title = _U('lang_2'),
                    description = _U('lang_3'),
                    icon = 'fa-solid fa-screwdriver-wrench',
                    event = 'mk-saloontender:client:craftingmenu',
		    args = {
                        saloonLoc = saloonLoc
                    },
                    arrow = true
                },
                {
                    title = _U('lang_4'),
                    description = _U('lang_5'),
                    icon = 'fas fa-box',
                    event = 'mk-saloontender:client:storage',
		    args = {
		        jobAccess = jobAccess,
			jobGrade = jobGrade,
			saloonLoc = saloonLoc,
			saloonName = saloonName
		    },
                    arrow = true
                }
            }
        })
        lib.showContext("saloon_mainmenu")
    else
        VORPcore.NotifyTip(_U('lang_8'), 5000)
    end
end)


for _, scp in ipairs(Config.SaloonCraftingPoint) do
    local saloonLoc = scp.location
    
    if not CategoryMenus[saloonLoc] then
        CategoryMenus[saloonLoc] = {}
    end

    for _, v in ipairs(Config.SaloonCrafting[saloonLoc]) do
    local IngredientsMetadata = {}
    local setheader = Config.CraftingItems[v.craft_item].name
    local itemimg = "nui://"..Config.img..v.craft_item..".png"
    for i, ingredient in ipairs(Config.CraftingItems[v.craft_item].ingredients) do
        table.insert(IngredientsMetadata, { label = ingredient.item, value = ingredient.amount })
    end
    local option = {
        title = setheader,
	icon = itemimg,
        event = 'mk-saloontender:client:checkingredients',
        metadata = IngredientsMetadata,
        args = {
            title = setheader,
            category = v.category,
            ingredients = Config.CraftingItems[v.craft_item].ingredients,
            crafttime = Config.CraftingItems[v.craft_item].crafttime,
            receive = v.craft_item,
            giveamount = v.giveamount,
	    saloonLoc = saloonLoc,
	    jobAccess = jobAccess,
	    jobGrade = jobGrade,
	    saloonName = saloonName
        }
    }

    if not CategoryMenus[saloonLoc][v.category] then
        CategoryMenus[saloonLoc][v.category] = {
            id = 'crafting_menu_' .. v.category,
            title = v.category,
            menu = 'saloon_mainmenu',
            onBack = function() end,
            options = { option }
        }
    else
        table.insert(CategoryMenus[saloonLoc][v.category].options, option)
    end
    end
end

RegisterNetEvent('mk-saloontender:client:categorymenu')
AddEventHandler('mk-saloontender:client:categorymenu', function(MenuData)
    lib.registerContext(MenuData)
    lib.showContext(MenuData.id)	
end)

RegisterNetEvent('mk-saloontender:client:craftingmenu')
AddEventHandler('mk-saloontender:client:craftingmenu', function(data)
    local Menu = {
        id = 'crafting_menu',
        title = _U('lang_9'),
        menu = 'saloon_mainmenu',
        onBack = function() end,
        options = {}
    }
    
    for category, MenuData in pairs(CategoryMenus[data.saloonLoc]) do
        table.insert(Menu.options, {
            title = category,
            description = _U('lang_10') .. category,
            icon = 'fa-solid fa-pen-ruler',
            event = 'mk-saloontender:client:categorymenu',
	    args = MenuData,
            arrow = true
        })
    end

    lib.registerContext(Menu)
    lib.showContext(Menu.id)
end)


RegisterNetEvent('mk-saloontender:client:checkingredients', function(data)
    local hasRequired =  VORPcore.Callback.TriggerAwait('mk-saloontender:server:checkingredients', data.ingredients)
    if (hasRequired) then
        if Config.Debug == true then
            print("Check ingredients passed")
        end
        TriggerEvent('mk-saloontender:client:craftitem', data.saloonLoc, data.title, 
	             data.category, data.ingredients, tonumber(data.crafttime), 
		     data.receive, data.giveamount)
    else
        if Config.Debug == true then
            print("Check ingredients failed")
        end
        return
    end

end)


RegisterNetEvent('mk-saloontender:client:craftitem', function(saloonLoc, title, category, ingredients, crafttime, receive, giveamount)
        local animation = Config.CraftingAnimation
        Animations.startAnimation(animation)
	progressbar.start(_U("lang_11")..title..' '..category, crafttime, function ()
		TriggerServerEvent('mk-saloontender:server:finishcrafting', saloonLoc, ingredients, title, receive, giveamount)
		Animations.endAnimation(animation)
    end, 'linear')
end)


RegisterNetEvent('mk-saloontender:client:storage', function(data)
    
    local Character = LocalPlayer.state.Character
    local playerjob = Character.Job
    local playerjobgrade = Character.Grade

    if playerjob == data.jobAccess and playerjobgrade >= data.jobGrade then
	TriggerServerEvent("mk-saloontender:server:OpenContainer", data.saloonLoc, data.saloonName, Config.StorageLimit)
    end
end)

