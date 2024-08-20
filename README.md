# mk-saloontender
This is modified implementation for saloontender for VORP using no so liked ox_lib (might update in future to vorp_menu/vorp_input)

# Description
You can craft food at your saloon crafting station which will add the items to a stock inventory then you may fill the shop with the craftet items from the stock inventory to your saloon shop for whatever price you want for each item and people can buy it. Money from the sold items will go to the cash register and you can withdraw any available amount at anytime. Refill-ing already existing items from the stock inventory with a higher price will overload the current item price. Only people with given job can access the crafting station and see the extended shop options for withdrawing money and refilling the stock.

NOTES:

Carefully look at the config and defined proper unique "location" and "shopid" items. "location" is needed at several places in order to map properly the items, shop and crafting station together.
Items for crafting are specified in the config file. You need to have each item and ingredient items in the database with images in vorp_inventory in order to work properly.

# Features
- You can have different menus for each saloon
- You can reuse already defined crafing items and each store if needed
- Job and Job Grade access separately for the crafting and shop stock refill/withdraw options

# Dependancies
- bcc-utils
- vorp_core
- vorp_animations
- ox_lib

# Installation
- ensure that the dependancies are added and started
- add mk-saloontender to your resources folder
- Add tables executing install/mk-saloontender.sql to your database

# Starting the resource
- add the following to your server.cfg file : ensure mk-saloontender

# Credits
- rsg-saloontender : https://github.com/B4NGDAI/rsg-saloontender

