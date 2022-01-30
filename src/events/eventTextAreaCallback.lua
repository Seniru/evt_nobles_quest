eventTextAreaCallback = function(id, name, event)
	p({id, name, event})
	Panel.handleActions(id, name, event)
end