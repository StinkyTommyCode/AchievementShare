local HTTP = require("src/http")


local function onRegisterSuccessful(request)
	HTTP.Sync()
end

local function onRegisterTimedOut(request)
	-- try again up to every 10 seconds	
	UTIL.DelayUntilNext(500, "register", function()
		HTTP.Register(onRegisterSuccessful, onRegisterTimedOut, onRegisterFailed)
	end)
end

local function onRegisterFailed(request)
	-- be sad, maybe some day we'll have a recovery plan
    log(request.url, "request failed, error code =", request.errorCode)
end


HTTP.Register(onRegisterSuccessful, onRegisterTimedOut, onRegisterFailed)