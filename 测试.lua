Class = {};

function Class:Create(object,name,father)
    object.__index = object;
    if father ~= nil then
        setmetatable(Box,Class[father]);
    end
    Class[name] = object;
end

function Class:Clone(talbe)
    local object = {};
    for key, value in pairs(talbe) do
        object[key] = value;
    end
    if object.constructor == nil then
        function object:constructor()

        end
    end
    function object:__constructor(...)
        if self.super then
            self.super:__constructor(...);
        end
        object:constructor(...);
    end
    object.super = nil;
    if getmetatable(talbe) ~= nil then
        object.super = self:Clone(getmetatable(talbe))
        setmetatable(object,object.super);
    end
    object.__index = object;
    return object;
end

function Class:New(name,...)
    local object = self:Clone(Class[name]);
    object:__constructor(...);
    return object;
end

(function()
Component = {};
Component.x = 123;
function Component:constructor(name)
    print("Component"..name);
end
Class:Create(Component,"Component");

Box = {};
Box.x = 222;
function Box:constructor(name)
    print("Box"..name);
end;
Class:Create(Box,"Box","Component");
end)();

o1 = Class:New("Box","QWQ");
o2 = Class:New("Box","QAQ");



