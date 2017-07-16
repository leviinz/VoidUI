_G.HeistHUD = _G.HeistHUD or {}
HeistHUD.mod_path = ModPath
HeistHUD.options_path = SavePath .. "HeistHUD.txt"
HeistHUD.options = {} 
HeistHUD.hook_files = {
    ["lib/managers/hudmanager"] = "lua/hudmanager.lua",
	["lib/managers/hud/hudteammate"] = "lua/hudteammate.lua",
	["lib/managers/hud/hudtemp"] = "lua/hudtemp.lua",
	["lib/managers/hud/hudblackscreen"] = "lua/hudblackscreen.lua",
	["lib/states/ingamewaitingforplayers"] = "lua/hudblackscreen.lua",
    ["lib/managers/hudmanager"] = "lua/hudmanager.lua",
    ["lib/managers/hudmanagerpd2"] = "lua/hudmanager.lua",
	["lib/units/beings/player/huskplayermovement"] = "lua/huddowns.lua",
	["lib/units/beings/player/states/playerbleedout"] = "lua/huddowns.lua",
	["lib/network/handlers/unitnetworkhandler"] = "lua/huddowns.lua",
	["lib/units/equipment/doctor_bag/doctorbagbase"] = "lua/huddowns.lua",
	["lib/managers/hud/hudobjectives"] = "lua/hudobjectives.lua",
	["lib/managers/hud/hudheisttimer"] = "lua/hudheisttimer.lua",
	["lib/managers/hud/hudpresenter"] = "lua/hudpresenter.lua",
	["lib/managers/hud/hudhint"] = "lua/hudhint.lua",
	["lib/managers/hintmanager"] = "lua/hudhint.lua",
	["lib/managers/hud/hudinteraction"] = "lua/hudinteraction.lua",
	["lib/managers/hud/hudchat"] = "lua/hudchat.lua",
	["lib/managers/hud/hudassaultcorner"] = "lua/hudassaultcorner.lua",
	["lib/managers/group_ai_states/groupaistatebase"] = "lua/hudassaultcorner.lua",
	["lib/managers/objectinteractionmanager"] = "lua/hudassaultcorner.lua"
}
function HeistHUD:Save()
	local file = io.open( self.options_path, "w+" )
	if file then
		file:write( json.encode( self.options ) )
		file:close()
	end
end
function HeistHUD:Load()
	local file = io.open( self.options_path, "r" )
	if file then
		self.options = json.decode( file:read("*all") )
		file:close()
	end
end
Hooks:Add("LocalizationManagerPostInit", "HeistHUD_Localization", function(loc)
	loc:load_localization_file(HeistHUD.mod_path .. "loc/english.txt", false)
end)

function HeistHUD:reset_options()
	HeistHUD.options.totalammo = true
	HeistHUD.options.main_loud = true
	HeistHUD.options.main_stealth = true
	HeistHUD.options.mate_loud = true
	HeistHUD.options.mate_stealth = true
	HeistHUD.options.mate_name = true
	HeistHUD.options.show_levelname = true
	HeistHUD.options.show_ghost_icon = true
	HeistHUD.options.show_badge = true
	HeistHUD.options.anim_badge = true
	HeistHUD.options.hud_scale = 1
	HeistHUD.options.hud_main_scale = 1
	HeistHUD.options.hud_mate_scale = 1
	HeistHUD.options.hud_assault_scale = 1
	HeistHUD.options.hud_objectives_scale = 1
	HeistHUD.options.hud_objective_history = 3
	HeistHUD.options.main_health = 2
	HeistHUD.options.mate_health = 2
	HeistHUD.options.armor = 2
	HeistHUD:Save()
end
Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_HeistHUD", function(menu_manager)
	MenuCallbackHandler.callback_heisthud_hudscale = function(self, item)
		HeistHUD.options.hud_scale = item:value()
		HeistHUD.options.hud_main_scale = item:value()
		HeistHUD.options.hud_mate_scale = item:value()
		HeistHUD.options.hud_objectives_scale = item:value()
		HeistHUD.options.hud_assault_scale = item:value()
		local hudteammate = MenuHelper:GetMenu("HeistHUD_options_hudteammate")
		if hudteammate then 
			hudteammate._items_list[2]:set_value(item:value())
			hudteammate._items_list[10]:set_value(item:value())
		end
		local objectives = MenuHelper:GetMenu("HeistHUD_options_objectives")
		if objectives then
			objectives._items_list[1]:set_value(item:value())
		end
		local assault = MenuHelper:GetMenu("HeistHUD_options_assault")
		if assault then
			assault._items_list[1]:set_value(item:value())
		end
	end
	MenuCallbackHandler.basic_option_clbk = function(self, item)
		HeistHUD.options[item:parameters().name] = item:value()
	end
	MenuCallbackHandler.toggle_option_clbk = function(self, item)
		HeistHUD.options[item:parameters().name] = (item:value() == "on" and true or false)
	end
	MenuCallbackHandler.toggle_badge_clbk = function(self, item)
		HeistHUD.options[item:parameters().name] = (item:value() == "on" and true or false)
		
		local assault = MenuHelper:GetMenu("HeistHUD_options_assault")
		if assault then
			assault._items_list[3]:set_enabled(item:value() == "on" and true or false)
		end
	end
	
	MenuCallbackHandler.callback_heisthud_reset = function(self, item)
		local buttons = {
			[1] = { 
				text = managers.localization:text("dialog_yes"), 
				callback = function(self, item)
					HeistHUD:reset_options()
				end,
				},
			[2] = { text = managers.localization:text("dialog_no"), is_cancel_button = true, }
		}
		QuickMenu:new( managers.localization:text("HeistHUD_reset_title"), managers.localization:text("HeistHUD_reset_confirm"), buttons, true )
	end
	
	MenuCallbackHandler.heisthud_save = function(self, item)
		HeistHUD:Save()
	end	
	
	HeistHUD:Load()
	if HeistHUD.options.armor == nil then HeistHUD:reset_options() end
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/options.txt", HeistHUD, HeistHUD.options)
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/assaultcorner.txt", HeistHUD, HeistHUD.options)
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/objectives.txt", HeistHUD, HeistHUD.options)
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/hudteammate.txt", HeistHUD, HeistHUD.options)
end )


if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if HeistHUD.hook_files[requiredScript] then
		dofile( ModPath .. HeistHUD.hook_files[requiredScript] )
	end
end