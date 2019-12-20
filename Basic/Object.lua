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