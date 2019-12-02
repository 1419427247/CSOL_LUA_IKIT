Class = {};

function Class:Clone(talbe)
	local object = {};
	for key, value in pairs(talbe) do
		object[key] = value;
	end
	object.__index = object;
	object.__newindex = function (table,key,value)
		local tobject = table;
		while tobject ~= nil do
			for _key, _value in pairs(tobject) do
				if key == _key then
					rawset(tobject,key,value);
					return;
				end
			end
			tobject = getmetatable(tobject);
		end
		error("error: cannot find symbol : " .. key)
	end
    object.__call = function(table,...)
        table:constructor(...);
    end;
	if getmetatable(talbe) ~= nil then
		object.super = self:Clone(getmetatable(talbe))
		setmetatable(object,object.super);
	end
	return object;
end
function Class:Create(object,name,father)
	if object.constructor == nil then
        function object:constructor()
        end
	end
	if father ~= nil then
		setmetatable(object,Class[father]);
	else
		setmetatable(object,{});
	end

	Class[name] = object;
end
function Class:New(name,...)
	local object = self:Clone(Class[name]);
	object:constructor(...);
	return setmetatable({},object);
end

(function()
		local function charSize(str, index)
			local curByte = string.byte(str, index)
			local seperate = {0, 0xc0, 0xe0, 0xf0}
			for i = #seperate, 1, -1 do
				if curByte >= seperate[i] then return i end
			end
			return 1
		end
		local String = {};
		String.array = {};
		String.length = 0;
		function String:constructor(string)
			if string then
				local currentIndex = 1;
				while currentIndex <= #string do
					self.length = self.length +1;
					local cs = charSize(string, currentIndex);
					table.insert(self.array,string.sub(string,currentIndex,currentIndex+cs-1));
					currentIndex = currentIndex + cs;
				end
			end
		end

		function String:charAt(index)
			return self.array[index];
		end

		function String:substring(beginIndex,endIndex)
			local string = {};
			for i = beginIndex, endIndex, 1 do
				table.insert(string,self.array[i]);
			end
			return table.concat(string);
		end

		function String:__tostring()
			return table.concat(self.array);
		end

		function String:__eq(string)
			return self.length == string.length and function()
				for i = 1, self.length, 1 do
					if self.array[i] ~= string.array[i] then
						return false;
					end
				end
				return true;
			end
		end
		Class:Create(String,"String");
	end)();

(function()

	local Event = {
		eventSet = {};
	};

	function Event:constructor()

	end

	function Event:addEvent(event)
		if not self.eventSet[event] then
			self.eventSet[event] = {};
			return;
		end
		error("Event: '" ..event.."' already exists");
	end

	function Event:addEventListener()

	end

	function Event:removeEventListener()

	end
	Class:Create(Event,"Event");
end)();


(function()
	local Frame = {
		width = 0;
		height = 0;
		children = {};
	};
	function Frame:constructor(widht,height)
		self.width = widht;
		self.height = height;
	end

	function Frame:paint()

	end

	Class:Create(Frame,"Frame");
end)();


(function()
		local Component = {
			x = 0,
			y = 0,
			width = 0,
			height = 0,
		};
		function Component:constructor(table)
			self.x = table.x or 0;
			self.y = table.y or 0;
			self.width = table.width or 0;
			self.height = table.height or 0;
		end
		--获取焦点事件
		function Component:onfocus()

		end
		--失去焦点事件
		function Component:onblur()

		end
		--键盘抬起事件
		function Component:keydown()

		end
		--键盘按下事件
		function Component:keyup()

		end
		--键盘按下抬起事件
		function Component:keypress()

		end

		Class:Create(Component,"Component");
end)();


c1 = Class:New("Event");
c1:addEvent("onclick");


print(c1["onclick"]);
