-- Change autoUpdate to false if you wish to not receive auto updates.
-- Change silentUpdate to true if you wish not to receive any message regarding updates
local autoUpdate   = true
local silentUpdate = false

local version = 0.1
local scriptName = "UnseenJunglerIsTheDeadliest"

local towers = {}
local showTowers = true

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


function OnLoad()

	-- find all towers
	for i = 1, objManager.iCount, 1 do
        local obj = objManager:getObject(i)
        if obj ~= nil and string.find(obj.type, "obj_Turret") ~= nil and string.find(obj.name, "_A") == nil and obj.health > 0 then
            table.insert(towers, obj)
        end
    end


end

function OnDraw()

	-- draw towers
	if showTowers then
		for f, tower in ipairs(towers) do
			if tower.health > 0 then
				local col = 0xFF80FF00 
				if tower.team ~= myHero.team then
					col = 0xFFFF0000
				end
				DrawCircle(tower.x, tower.y, tower.z, 1000, col)
			else
				table.remove(towers, f)
			end
		end
	end
	
	if not IsKeyDown(18) then return end

	local enemyMinions = minionManager(MINION_ENEMY, 5000, player, MINION_SORT_HEALTH_ASC)
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil then
			DrawCircle(minion.x, minion.y, minion.z, 1250, 0x00DD00FF)
		end
	end
	
	
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if enemy ~= nil and enemy.health > 0 then 
			DrawCircle(enemy.x, enemy.y, enemy.z, 1450, 0x0000AAFF);
		end
	end

	
	
end


function OnTick()

	if IsKeyPressed(112) then
		if showTowers then
			showTowers = false
		else
			showTowers = true
		end
    end


end
