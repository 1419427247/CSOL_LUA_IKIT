Class = {};

function Class:Clone(talbe)
    local object = {};
    for key, value in pairs(talbe) do
        object[key] = value;
    end
    if object.constructor == nil then
        function object:constructor()

        end
    end
    object.super = nil;
    if getmetatable(talbe) ~= nil then
        object.super = self:Clone(getmetatable(talbe))
        setmetatable(object,object.super);
    end
    object.__index = object;
    return object;
end
function Class:Create(object,name,father)
    object.__index = object;
    if father ~= nil then
        setmetatable(object,Class[father]);
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
    local Char = {};
    Char.char = {};
    function Char:constructor()
        self.super:constructor("QWQ");
    end
    Class:Create(Char,"Char","String");
end)();


o1 = Class:New("Char");
