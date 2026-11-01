local UTIL = { }

-- Sets up a delayed execution of a function, waiting at most [logicTick / 50] seconds.
function UTIL.DelayUntilNext(logicTick, delayName, func)
	Event.Logic.Subscribe(delayName, function(logicEvent) 
		if logicEvent.logicTick % logicTick == 0 then 
			Event.Logic.Unsubscribe(delayName)
			func()
		end
	end)
end

-- Serialize a flat table into json, returning nil if the table is empty
function UTIL.Serialize(data)
	local serialized = { }
	for k,v in pairs(data) do
		table.insert(serialized, formatStr('"{}":{}',k,v))
	end

	if #serialized > 0 then
		return "{"..table.concat(serialized, ",").."}"
	else
		return nil
	end
end

return UTIL