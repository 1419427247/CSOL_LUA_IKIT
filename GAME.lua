IKit = (function()
    local class = {};

    local classtree = {};

    local call = function(table,...)
        table:constructor(...);
    end;

    local newindex = function(table,key,value)
        local tobject = table;
        while tobject ~= nil do
            for k in pairs(tobject) do
                if key == k then
                    rawset(tobject,key,value);
                    return;
                end
            end
            tobject = getmetatable(tobject);
        end
        rawset(table,key,value);
    end

    local basic = {
        __newindex = newindex,
        __call = call,
    };

    class["Object"] = {
        type = "Object",
        __newindex = newindex,
        __call = call,
    };

    classtree["Object"] = nil;

    local function instanceof(value,string)
        if type(value) == "table" and  type(string) == "string" then
            local ttype = value.type;
            while ttype ~= nil do
                if ttype == string then
                    return true;
                end
                ttype = classtree[ttype];
            end
        end
        return false;
    end

    local function clone(talbe)
        local object = {};
        for key, value in pairs(talbe) do
            object[key] = value;
        end
        object.__index = object;
        if getmetatable(talbe) ~= nil then
            object.super = clone(getmetatable(talbe))
            object.__newindex = object.super.__newindex;
            object.__call = object.super.__call;
            setmetatable(object,object.super);
        else
            setmetatable(object,basic);
        end
        return object;
    end

    local function create(object,name,father)
        if object.constructor == nil then
            function object:constructor()
            end
        end

        if father ~= nil then
            setmetatable(object,class[father]);
            classtree[name]=father;
        else
            setmetatable(object,class["Object"]);
            classtree[name]="Object";
        end
        class[name] = object;
    end

    local newindex = function(table,key,value)
        local tobject = table;
        while tobject ~= nil do
            for k in pairs(tobject) do
                if key == k then
                    rawset(tobject,key,value);
                    return;
                end
            end
            tobject = getmetatable(tobject);
        end
        error("没有找到字段'" .. key .. "'在'" .. table.type .."'内");
    end
    local function new(name,...)
        local object = clone(class[name]);
        object.type = name;
        object:constructor(...);
        local tobject = object;
        while tobject ~= nil do
            rawset(tobject,"__newindex",newindex);
            tobject = getmetatable(tobject);
        end
        return setmetatable({},object);
    end

    return {
        Create = create,
        New = new,
        Instanceof = instanceof,
    }
end)();


(function()
    local Component = {};

    function Component:constructor(id)
        self.id = id;
        self.isvisible = true;
        --self.isfreeze = false;
        self.x = 0;
        self.y = 0;
        self.width = 0;
        self.height = 0;
        self.style = {
            left = 0,
            top = 0,
            width = 0,
            height = 0,
            position = "relative",
            backgroundcolor = {red = 255,green = 255,blue=255,alpha=255},
            border = {top = 1,left = 1,right = 1,bottom = 1},
            bordercolor = {red = 0,green = 0,blue=0,alpha=255},
            newline = false,
        };
        self.father = 0;
        self.children = {};
    end

    function Component:printf(arg1, arg2, arg3)
        print("QAQ:"..self.x);
    end

    IKit.Create(Component,"Component");
end)();


local a = {};
for i = 1, 5, 1 do
    a[#a+1] = IKit.New("Component");
end

local ComponentBox = (function()
    local ComponentBox = {
        components = {};
    };
    function ComponentBox:__call(components)
        rawset(self,"components",components);
    end

    function ComponentBox:__newindex(key,value)
        for i = 1, #self.components, 1 do
            self.components[i][key] = value;
        end
    end
    
    function ComponentBox:call(key,...)
        for i = 1, #self.components, 1 do
            self.components[i][key](self.components[i],...);
        end
    end

    function ComponentBox:get(tag)
        local array = {};
        for i = 1, #self.components, 1 do
            if self.components[i] == tag then
                array[#array+1] = self.components[i];
            end
        end
        return array;
    end
    
    return setmetatable({},ComponentBox);
end)();

ComponentBox(a);

ComponentBox.x = 5;

