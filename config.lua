Config = {}

Config.defaultlang = 'en_lang'
Config.img = "vorp_inventory/html/img/items/"


Config.SaloonBlip = {
    blipSprite = 'blip_saloon',
    blipScale = 0.2
}

Config.ShopBlip = {
    blipSprite = 'blip_shop_store',
    blipScale = 0.2
}


Config.StorageLimit = 1000 -- Storage limit for each saloon storage
Config.Debug = false
Config.Key = 0x760A9C6F -- G
Config.CraftingAnimation = 'craft' -- Crafting animation when crafting items

-- Saloon Crafting Locations
Config.SaloonCraftingPoint = {

    {
        name = 'Valentine Saloon Crafting', -- crafting station name
        location = 'valsaloon', -- must be unique
        coords = vector3(-313.7462, 806.18127, 118.98072), -- crafting station location coordinates
        job = 'valsaloontender', -- everyone with job valsaloontender will have access to the crafting station
	jobgrade = 1, -- everyone with job grade >= 1 will have access to the crafting station
        showblip = false -- show blip on the map.
    },
    {
        name = "Devil's Throat Crafting",
	location = 'devilsthroat',
	coords = vector3(-1718.99, -435.54, 152.29),
	job = 'eldiablo',
	jobgrade = 1,
	showblip = false
    },
}

-- Saloon Shop Locations
Config.SaloonShops = {
    {
        shopid = 'valsaloonshop', -- must be unique
	location = 'valsaloon', -- must be the same as in SaloonCraftingPoint for a given shop-crafting location
        shopname = 'Valentine Saloon Shop', -- shop name used for the blip also
        coords = vector3(-311.6449, 806.24963, 118.97999), -- shop location coordinates
        jobaccess = 'valsaloontender', -- everyone with job valsaloontender will have access to the shop refill stock and withdraw options
	jobgrade = 1, -- everyone with job grade >= 1 will have access to the shop refill stock and withdraw options
        showblip = true -- show blip on the map
    },
    {
        shopid = 'devilsthroatshop',
	shopname = "Devil's Throat Shop",
	location = 'devilsthroat',
	coords = vector3(-1717.89, -440.66, 152.21),
	jobaccess = 'eldiablo',
	jobgrade = 1,
	showblip = true
    }
}

-- Saloons Cooking Recepies
Config.SaloonCrafting = {
    valsaloon = {     -- This is reference to the location parameters which can be seen above in Crafting and Shop config
        {
            category = 'Drinks',  -- Category where the item must be located
            craft_item = "beer", -- database item
            giveamount = 1 -- how many to recive after crafting
        },
        {
            category = 'Food',
            craft_item = "consumable_meat_greavy",
            giveamount = 1
        }
    },
    devilsthroat = {
        {
            category = 'Drinks',
            craft_item = "beer",
            giveamount = 1
        },
	{
            category = 'Food',
            craft_item = "consumable_meat_greavy",
            giveamount = 1
        }
    }
}

-- Saloon Crafting Items
Config.CraftingItems = {
    consumable_meat_greavy = {  -- database item
        name = "Stew",          -- name of the item
	crafttime = 5000,       -- craft time for the item
	ingredients = {         -- ingredients specified with database items as well as amount required
            [1] = { item = "carrots", amount = 1 },
            [2] = { item = "water", amount = 1 },
	},
    },
    beer = {
        name = "Beer",
	crafttime = 5000,
	ingredients = {
            [1] = { item = "malt",   amount = 1 },
            [2] = { item = "hops",   amount = 1 },
            [3] = { item = "yeast",  amount = 1 },
            [4] = { item = "water",  amount = 1 },
            [5] = { item = "bottle", amount = 1 },
       }
    }
}
