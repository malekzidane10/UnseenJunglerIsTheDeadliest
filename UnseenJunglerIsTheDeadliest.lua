--[[
	FUTURE SCRIPT a14.31.1215.8742
	J4's Unseen jungler is the deadliest 
	
	
	Copy-pasterino code however you want!
	
	
	F1 to switch tower-mode!
	Hold down ALT to see vision radii of enemies and objects
	
]]
local version = 0.1
--[[
-- Change autoUpdate to false if you wish to not receive auto updates.
local autoUpdate   = true

local scriptName = "UnseenJunglerIsTheDeadliest"


-- SourceLib auto download
local sourceLibFound = true
if FileExist(LIB_PATH .. "SourceLib.lua") then
    require "SourceLib"
else
    sourceLibFound = false
    DownloadFile("https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua", LIB_PATH .. "SourceLib.lua", function() print("<font color=\"#6699ff\"><b>" .. scriptName .. ":</b></font> <font color=\"#FFFFFF\">SourceLib downloaded! Please reload!</font>") end)
end
-- Return if SourceLib has to be downloaded
if not sourceLibFound then return end

-- Updater
if autoUpdate then
    SourceUpdater(scriptName, version, "raw.github.com", "/UnseenJunglerIsTheDeadliest/master/UnseenJunglerIsTheDeadliest.lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/UnseenJunglerIsTheDeadliest/master/UnseenJunglerIsTheDeadliest.version"):SetSilent(silentUpdate):CheckUpdate()
end
]]



local towers = {}
local showTowersMode = 1
local col
hero = GetMyHero()

local hiddenObjectList = {}
local objectsToAdd = {
	{ name = "VisionWard", objectType = "wards", spellName = "VisionWard", color = 0x00FF00FF, range = 1450, duration = 180000, icon = "yellowPoint"},
	{ name = "SightWard", objectType = "wards", spellName = "SightWard", color = 0x0055FF00, range = 1450, duration = 180000, icon = "greenPoint"},
}

local spellsToAdd = {
	{ name = "Jack In The Box", objectType = "boxes", spellName = "JackInTheBox", color = 0x00FF0000, range = 300, duration = 60000, icon = "redPoint"},
	{ name = "Cupcake Trap", objectType = "traps", spellName = "CaitlynYordleTrap", color = 0x00FF0000, range = 300, duration = 240000, icon = "cyanPoint"},
	{ name = "Noxious Trap", objectType = "traps", spellName = "Bushwhack", color = 0x00FF0000, range = 300, duration = 240000, icon = "cyanPoint"},
	{ name = "Noxious Trap", objectType = "traps", spellName = "BantamTrap", color = 0x00FF0000, range = 300, duration = 600000, icon = "cyanPoint"},
	-- to confirm
	{ name = "MaokaiSproutling", objectType = "boxes", spellName = "MaokaiSapling2", color = 0x00FF0000, range = 300, duration = 35000, icon = "redPoint"}
}

function OnCreateObj(object)
	if object ~= nil and object.name ~= nil and object.team ~= hero.team then
		for _, obj in pairs(objectsToAdd) do
			if object.name == obj.name then
				print("Found ward of team: " .. tostring(object.team) .. " Your team: " .. tostring(player.team))
				local tick = GetTickCount()
				table.insert(hiddenObjectList, {objData = obj, objObject = object, seenTick = tick, x = object.pos.x, y = object.pos.y, z = object.pos.z})
				
			end
        end
	end
end

function OnProcessSpell(unit, spell)

	if spell ~= nil and spell.team ~= hero.team  then
		for _, obj in pairs(spellsToAdd) do
			if spell.name == obj.spellName then
				print("Found spell of team: " .. tostring(spell.team) .. " Your team: " .. tostring(player.team))
				local tick = GetTickCount()
				table.insert(hiddenObjectList, {objData = obj, objObject = spell, seenTick = tick, x = spell.endPos.x, y = spell.endPos.y, z = spell.endPos.z})

			end
		end
	end
end   

function OnDeleteObj(object)
	
	if object ~= nil and object.name ~= nil then --and object.team ~= hero.team 
		for i,objectToAdd in pairs(objectsToAdd) do
			if object.name == objectToAdd.name then
				for f, obj in pairs(hiddenObjectList) do
					if obj.x == object.x and obj.z == object.z then
						table.remove(hiddenObjectList, f)
						print("Deleted ward of team: " .. tostring(object.team) .. " Your team: " .. tostring(player.team))
					end
				end
			end
        end
		
		for _, spell in pairs(spellsToAdd) do
			if object.name == spell.name then
				for f, obj in pairs(hiddenObjectList) do
					if obj.x == object.x and obj.z == object.z then
						table.remove(hiddenObjectList, f)
						print("Deleted spell of team: " .. tostring(object.team) .. " Your team: " .. tostring(player.team))
					end			
				end
			end		
		end
	end
end




function OnLoad()
	
	print("[---] FUTURE SCRIPT Unseen Jungler is the deadliest, version: " .. tostring(version) .. " [---]")
	-- find all towers
	for i = 1, objManager.iCount, 1 do
        local obj = objManager:getObject(i)
        if obj ~= nil and string.find(obj.type, "obj_Turret") ~= nil and string.find(obj.name, "_A") == nil and obj.health > 0 then
            table.insert(towers, obj)
        end
    end


end


function renderObjectText(obj)
	local t =  tostring(math.floor((obj.objData.duration-(GetTickCount() - obj.seenTick))/1000))
	local minLeft = tostring(math.floor(t/60))
	local secLeft = t%60
	if secLeft < 10 then
		secLeft = "0"..tostring(secLeft)
	else
		secLeft = tostring(secLeft)
	end
			
	DrawText3D(minLeft..":"..secLeft,obj.x,obj.y,obj.z, 16, RGB(255,255,255), true)
end


function OnDraw()
	

	for f, obj in pairs(hiddenObjectList) do
		renderObjectText(obj)

		if IsKeyDown(18) then
			DrawCircle(obj.x, obj.y, obj.z, obj.objData.range, obj.objData.color)
		else
			DrawCircle(obj.x, obj.y, obj.z, 100, obj.objData.color)
		end
	end
	

	-- draw towers
	if showTowersMode ~= 2 then
		for f, tower in ipairs(towers) do
		
			if tower.health > 0 then
				if showTowersMode == 1 then
					local dis = GetDistance(GetMyHero(), tower)		
					if dis > 3000 then dis = 3000 end
					dis = 3000 - dis
					if dis < 0 then dis = 0 end	
					dis = dis/3000*255
					
					col = RGB(0, dis, 0)
					if tower.team ~= myHero.team then
						col = RGB(dis, 0, 0)
					end
				end
				
				if showTowersMode == 0 then
					col = RGB(0, 255, 0)
					if tower.team ~= myHero.team then
						col = RGB(255, 0, 0)
					end
				end

				DrawCircle(tower.x, tower.y, tower.z, 950, col)
				
				
			else
				table.remove(towers, f)
			end
		end
	end
	
	if not IsKeyDown(18) then return end

	local enemyMinions = minionManager(MINION_ENEMY, 5000, player, MINION_SORT_HEALTH_ASC)
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil and minion.visible then
			DrawCircle(minion.x, minion.y, minion.z, 1250, 0x00DD00FF)
		end
	end
	
	
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if enemy ~= nil and enemy.health > 0 and enemy.visible then 
			DrawCircle(enemy.x, enemy.y, enemy.z, 1450, 0x0000AAFF);
		end
	end

	
	
end


function OnTick()

	if IsKeyPressed(112) then
		if showTowersMode == 0 then
			showTowersMode = 1
			print("Showing nearby towers")			
		elseif showTowersMode == 1 then
			showTowersMode = 2
			print("Showing no towers")
		else
			showTowersMode = 0
			print("Showing all towers")
		end
    end

	for f, obj in pairs(hiddenObjectList) do
		if obj.objData.duration + obj.seenTick < GetTickCount() then
			table.remove(hiddenObjectList, f)
			return
		end
	end

end
