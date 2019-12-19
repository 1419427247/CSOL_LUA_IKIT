IKit = (function()
    local class = {};
    class["Object"] = {
        type = "Object",
        __newindex = function (table,key,value)
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
            rawset(table,key,value);
            --error("error: cannot find symbol : " .. key)
        end,
        __call = function(table,...)
            table:constructor(...);
        end
    };

    -- local function instanceof(table,string)
    --     if type(table) == "table" and  type(string) == "string" then
    --         local object = table;
    --         while object ~= nil do
    --             if object.type == string then
    --                 return true;
    --             else
    --                 object = getmetatable(object);
    --             end
    --         end
    --     end
    --     return false;
    -- end

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
        else
            setmetatable(object,class["Object"]);
        end
        class[name] = object;
    end

    local function new(name,...)
        local object = setmetatable({},clone(class[name]));
        object.type = name;
        object:constructor(...);
        return object;
    end

    return {
        Clone = clone,
        Create = create,
        New = new,
    }
end)();