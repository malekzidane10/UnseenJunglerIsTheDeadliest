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

local DCConfig

local hiddenObjectList = {}
local objectsToAdd = {
	{ name = "VisionWard", objectType = "wards", spellName = "VisionWard", color = RGB(150, 0, 150), range = 1350, duration = 200000, icon = "yellowPoint"},
	{ name = "SightWard", objectType = "wards", spellName = "SightWard", color = RGB(150, 150, 0), range = 1350, duration = 180000, icon = "greenPoint"},
	{ name = "SightWard", objectType = "wards", spellName = "YellowTrinket", color = RGB(150, 150, 0), range = 1350, duration = 60000, icon = "greenPoint"},
	{ name = "SightWard", objectType = "wards", spellName = "YellowTrinketUpgrade", color = RGB(150, 150, 0), range = 1350, duration = 120000, icon = "greenPoint"},
	{ name = "VisionWards", objectType = "wards", spellName = "SightWard", color = RGB(150, 150, 0), range = 1350, duration = 180000, icon = "greenPoint"},
	{ name = "SightWard", objectType = "wards", spellName = "wrigglelantern", color = RGB(150, 150, 0), range = 1350, duration = 180000, icon = "greenPoint"},
}

local spellsToAdd = {
	{ name = "Jack In The Box", objectType = "boxes", spellName = "JackInTheBox", color = 0x00FF0000, range = 300, duration = 60000, icon = "redPoint"},
	{ name = "Cupcake Trap", objectType = "traps", spellName = "CaitlynYordleTrap", color = 0x00FF0000, range = 300, duration = 240000, icon = "cyanPoint"},
	{ name = "Noxious Trap", objectType = "traps", spellName = "Bushwhack", color = 0x00FF0000, range = 300, duration = 240000, icon = "cyanPoint"},
	{ name = "Noxious Trap", objectType = "traps", spellName = "BantamTrap", color = 0x00FF0000, range = 300, duration = 600000, icon = "cyanPoint"},
	-- to confirm
	--{ name = "MaokaiSproutling", objectType = "boxes", spellName = "MaokaiSapling2", color = 0x00FF0000, range = 300, duration = 35000, icon = "redPoint"}
}

function OnCreateObj(object)
	if object ~= nil and object.name ~= nil then
	
		DelayAction(function(object, timer, gtimer)
			
			if object.team == hero.team then return end
			for _, obj in pairs(objectsToAdd) do
				if object.name == obj.name and object.charName == obj.spellName then

					local tick = GetTickCount()
					table.insert(hiddenObjectList, {objData = obj, objObject = object, seenTick = tick, x = object.pos.x, y = object.pos.y, z = object.pos.z})
					
				end
			end
		
		end, 1, { object, GetTickCount(), GetGameTimer() } )
		
	end
end

function OnProcessSpell(unit, spell)

	if spell ~= nil and unit.team ~= hero.team  then
		for _, obj in pairs(spellsToAdd) do
			if spell.name == obj.spellName then
				local tick = GetTickCount()
				local p = GetLandingPos(spell.endPos)
				
				table.insert(hiddenObjectList, {objData = obj, objObject = spell, seenTick = tick, x = p.x, y = p.y, z = p.z})

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
					end
				end
			end
        end
		
		for _, spell in pairs(spellsToAdd) do
			if object.name == spell.name then
				for f, obj in pairs(hiddenObjectList) do
					if obj.x == object.x and obj.z == object.z then
						table.remove(hiddenObjectList, f)
					end			
				end
			end		
		end
	end
end




function OnLoad()
	
	print("[---] FUTURE SCRIPT: Unseen Jungler is the deadliest [---]")
	
	DCConfig = scriptConfig("Unseen Jungler is the deadliest", "UJISTD")
	DCConfig:addParam("TowerMode", "Show Towers", SCRIPT_PARAM_LIST, 3, {"Closeby", "All", "None" })
	DCConfig:addParam("EnemyVisionMode", "Enemy vision range selection", SCRIPT_PARAM_LIST, 3, {"Circle", "All", "None" })
	DCConfig:addParam("SelectionSize", "Vision circle selection size", SCRIPT_PARAM_SLICE, 451, 50, 750, 50)
	DCConfig:addParam("HiddenObjectMode", "Hidden objects vision range", SCRIPT_PARAM_LIST, 3, {"Mouseover", "All", "None" })	
	DCConfig:addParam("ObjectsOnMinimap", "Show objects on minimap", SCRIPT_PARAM_ONOFF, false, 32)
	DCConfig:addParam("visionKey", "Render Vision Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))

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
	
	--hidden objects
	for f, obj in pairs(hiddenObjectList) do
		
			if DCConfig.HiddenObjectMode == 3 then
				renderObjectText(obj)
				DrawCircle2(obj.x, obj.y, obj.z, 100, obj.objData.color)	
			end
			
			if DCConfig.ObjectsOnMinimap then
				local minimapPosition = GetMinimap(obj.x, obj.z)
				DrawTextWithBorder('.', 60, minimapPosition.x - 3, minimapPosition.y - 43, obj.objData.color, RGB(0,0,0))
			end
		
			if DCConfig.HiddenObjectMode == 1 then
			
				renderObjectText(obj)
				if DCConfig.visionKey and mouseOver(obj.x, obj.z, 100) then
					DrawCircle2(obj.x, obj.y, obj.z, obj.objData.range, obj.objData.color)
				else
					DrawCircle2(obj.x, obj.y, obj.z, 100, obj.objData.color)
				end
				
			end
			
			if DCConfig.HiddenObjectMode == 2 then
				
				renderObjectText(obj)
				if DCConfig.visionKey then
					DrawCircle2(obj.x, obj.y, obj.z, obj.objData.range, obj.objData.color)
				else
					DrawCircle2(obj.x, obj.y, obj.z, 100, obj.objData.color)
				end			
			end
		
		
	end
	
	-- draw towers
	if DCConfig.TowerMode ~= 3 then
		for f, tower in ipairs(towers) do
		
			if tower.health > 0 then
				if DCConfig.TowerMode == 1 then
					local dis = GetDistance(GetMyHero(), tower)		
					if dis > 3000 then dis = 3000 end
					dis = 3000 - dis
					if dis < 0 then dis = 0 end	
					dis = dis/3000*255
					
					col = RGB(0, dis, 0)
					if tower.team ~= myHero.team then
						col = RGB(dis, 0, 0)
					end
					if dis > 0 then
						DrawCircle2(tower.x, tower.y, tower.z, 950, col)
					end
				end
				
				if DCConfig.TowerMode == 2 then
					col = RGB(0, 255, 0)
					if tower.team ~= myHero.team then
						col = RGB(255, 0, 0)
					end
					DrawCircle2(tower.x, tower.y, tower.z, 950, col)
				end

				
			else
				table.remove(towers, f)
			end
		end
	end
	
	
	if not DCConfig.visionKey then return end
	if DCConfig.EnemyVisionMode == 3 then return end

	
	local enemyMinions = minionManager(MINION_ENEMY, 20000, player, MINION_SORT_HEALTH_ASC)
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil and minion.visible then
		
			if DCConfig.EnemyVisionMode == 1 then
				DrawCircle2(mousePos.x, mousePos.y, mousePos.z, DCConfig.SelectionSize, RGB(200, 0, 200));
				if mouseOver(minion.x, minion.z, DCConfig.SelectionSize) then
					DrawCircle2(minion.x, minion.y, minion.z, 1250, 0x00DD00FF)
				end
			end
			if DCConfig.EnemyVisionMode == 2 then
				DrawCircle2(minion.x, minion.y, minion.z, 1250, 0x00DD00FF)
			end
			
		end
	end
	
	
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if enemy ~= nil and enemy.health > 0 and enemy.visible then
		
			if DCConfig.EnemyVisionMode == 1 then
				DrawCircle2(mousePos.x, mousePos.y, mousePos.z, DCConfig.SelectionSize, RGB(200, 0, 200));
				if mouseOver(enemy.x, enemy.z, DCConfig.SelectionSize) then
					DrawCircle2(enemy.x, enemy.y, enemy.z, 1450, RGB(200, 200, 200))
				end
			end
			if DCConfig.EnemyVisionMode == 2 then
				DrawCircle2(enemy.x, enemy.y, enemy.z, 1250, 0x00DD00FF)
			end
			
		end
	end

	
	
end



function mouseOver(x, z, radius)
	local xMin = x-(radius)
	local xMax = x+(radius)
	local zMin = z-(radius)
	local zMax = z+(radius)
	
	if x == nil or z == nil or radius == nil or mousePos.x == nil or mousePos.z == nil then
		return false
	end
	
	if mousePos.x < xMax and mousePos.x > xMin and mousePos.z < zMax and mousePos.z > zMin then
		return true
	else
		return false
	end
	
end


function OnTick()


	for f, obj in pairs(hiddenObjectList) do
		if obj.objData.duration + obj.seenTick < GetTickCount() then
			table.remove(hiddenObjectList, f)
			return
		end
	end

end




function GetLandingPos(CastPoint)
        local wall = IsWall(D3DXVECTOR3(CastPoint.x, CastPoint.y, CastPoint.z))
        local Point = Vector(CastPoint)
        local StartPoint = Vector(Point)
        if not wall then return Point end
        for i = 0, 700, 25--[[Decrease for better precision, increase for less fps drops:]] do
                for theta = 0, 2 * math.pi + 0.2, 0.2 --[[Same :)]] do
                        local c = Vector(StartPoint.x + i * math.cos(theta), StartPoint.y, StartPoint.z + i * math.sin(theta))
                        if not IsWall(D3DXVECTOR3(c.x, c.y, c.z)) then
                                return c
                        end
                end
        end
        return Point
end

function DrawTextWithBorder(textToDraw, textSize, x, y, textColor, backgroundColor)
        DrawText(textToDraw, textSize, x + 1, y, backgroundColor)
        DrawText(textToDraw, textSize, x - 1, y, backgroundColor)
        DrawText(textToDraw, textSize, x, y - 1, backgroundColor)
        DrawText(textToDraw, textSize, x, y + 1, backgroundColor)
        DrawText(textToDraw, textSize, x , y, textColor)
end




--[[Low fps circles by barasia, vadash and viseversa]]--
function DrawCircle2NextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
		quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
		quality = 2 * math.pi / quality
		radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end


function round(num) 
	if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end


function DrawCircle22(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircle2NextLvl(x, y, z, radius, 1, color, 75)	
    end
end
--[[/Low fps circles by barasia, vadash and viseversa]]--
