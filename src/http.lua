local UTIL = require("src/util")

local HTTP = { }

local synced = { }
local function syncCallback(data)
	return function(request) 
		if request.successful then
			-- cache what we sent so we don't need to resend it
			for k,v in pairs(data) do
				synced[k] = v;

				-- resubscribe to the sync event
				UTIL.DelayUntilNext(500, "sync", HTTP.Sync)
			end
        end
	end
end

function HTTP.Sync() 
	local toSync = { }
	for _,v in pairs(config.Achievement) do
		if synced[v.configName] ~= v.progress then
			toSync[v.configName] = v.progress
		end
	end

	local data = UTIL.Serialize(toSync)
	if data ~= nil then
		local urlPath = formatStr("/api/player/{}", tostring(Player.GetTrackingID()))
		local request = HTTPRequest.new(Plugin.urls.database, urlPath)

		request:AddHeader("content-type", "application/json")
		request:AddHeader("content-encoding", "utf-8")
		request:Post(data, syncCallback(toSync))

		-- unsubscribe from the triggering event while we sync
		return true
	else
		-- don't unsubscribe from the triggering event
		return false
	end
end

function HTTP.Register(onRegisterSuccessful, onRegisterTimedOut, onRegisterFailed)
	local name = string.gsub(Player.GetEntity().displayName, "\xC2\xA0", "_")
	local urlPath = formatStr("/api/player/register/{}", tostring(Player.GetTrackingID()))
	local request = HTTPRequest.new(Plugin.urls.database, urlPath)

	request:AddHeader("content-type", "application/json")
	request:AddHeader("content-encoding", "utf-8")
	request:Post(name, function(request) 
		if request.successful then
			onRegisterSuccessful(request)
	    elseif request.timedOut then
	        onRegisterTimedOut(request)
	    elseif request.failed then
	        onRegisterFailed(request)
	    end
	end)
end

return HTTP