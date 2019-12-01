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
		local Component = {};
		Component.x = 0;
		Component.y = 0;
		function Component:constructor(x,y)
			self.x = x;
            self.y = y;
        end
        
		function Component:paint()
			print(self.x .. "Component" .. self.y);
        end
        
		Class:Create(Component,"Component");
	end)();


(function()
        local Box = {};
        function Box:constructor(x,y)
            self.super(x,y);
		end

		function Box:paint()
			self.super:paint();
			print("box");
        end

		Class:Create(Box,"Box","Component");
	end)();

load("c1 = Class:New(\"Box\",32,0);

while c1~=nil do
    print("table")
    for key, value in pairs(c1) do
        if type(value) == "number" then
            print(key .. ":" .. value);
        else
            print(key);
        end
    end
    c1 = getmetatable(c1);
end");