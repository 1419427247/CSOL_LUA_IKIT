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

		function String:__len()
			return self.length;
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
	local Event = {};
	function Event:__add(event)
		if not self[event] then
			rawset(self,event,setmetatable({},{
				__add = function(lis,handle)
					table.insert(lis,handle);
					return lis;
				end,
				 __sub = function(lis,handle)
					for i = 1, #lis, 1 do
						if lis[i] == handle then
							table.remove(lis,i);
							break;
						end
					end
					return lis;
				end
			}));
			return self;
		end
		error("Event: '" ..event.."' already exists");
	end

	function Event:__sub(event)
		if self[event] then
			rawset(self,event,nil);
			return self;
		end
		error("Event: '" ..event.."' does not exist");
	end

	function Event:constructor()

	end
	Class:Create(Event,"Event");
end)();


(function()
	local Windows = {
		root = {};
	};
	function Windows:constructor(frame)
		local function paint(node,component)
			for i = 1, #component.children, 1 do
				paint(component.children[i]);
			end
		end
		paint(self.root,frame);
	end

	Class:Create(Windows,"Windows");
end)();

(function()
	local Frame = {
		x = 0,
		y = 0,
		width = 0;
		height = 0;
		children = {};
	};
	function Frame:constructor(widht,height)
		self.width = widht;
		self.height = height;
	end

	Class:Create(Frame,"Frame");
end)();


(function()
		local Component = {
			tag = "Component";
			style = {
				x = 0,
				y = 0,
				width = 0,
				height = 0,
			},
			children = {},
		};
		function Component:constructor(tag)
			self.tag = tag;
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



-- c1 = Class:New("Component",{x = 15,y = 33,width = 33,height = 345;});
-- function c1:keyup()
-- 	print("QAQ");
-- end
		--table.remove(self,1);