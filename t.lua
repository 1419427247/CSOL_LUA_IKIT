Class,InstanceOf,Type = (function()
    NULL = {};
    local CLASS = {};
    CLASS["Object"] = {
        TABLE = {
            type = "Object",
            super = nil,
            __call = function (table,...)
                table:constructor(...);
            end,
            __newindex = function(table,key,value)
                if value == nil then
                    error("不可将字段设置为nil");
                end
                local temporary = table;
                if key == "type" and temporary.type ~= nil then
                    error("type不可修改");
                end
                while table ~= nil do
                    for k in pairs(table) do
                        if key == k then
                            rawset(table,key,value);
                            return;
                        end
                    end
                    table = getmetatable(table);
                end
                rawset(temporary,key,value);
            end,
        },
        SUPER = NULL,
        TYPE = "Object",
    }

    local function CLONE(_table)
        local object = {};
        for key, value in pairs(_table.TABLE) do
            object[key] = value;
        end
        object.__index = object;
        if _table.SUPER ~= NULL then
            object.super = CLONE(_table.SUPER)
            object.type = _table.TYPE;
            object.__call = object.super.__call;
            object.__newindex = object.super.__newindex;
            setmetatable(object,object.super);
        end
        return object;
    end

    local function NEW(_name,...)
        if CLASS[_name] == nil then
            error("没有找到类:" .. _name);
        end
        local object = CLONE(CLASS[_name]);
        object(...);
        rawset(object,"type",_name);
        return setmetatable({},object);
    end

    local function CREATECLASS(_name,_function,_super)
        _super = (_super or {Name = "Object"}).Name;

        if CLASS[_name] ~= nil then
            error("类'".. _name .."'重复定义");
        end
        if CLASS[_super] == nil then
            error("没有找到类:" .. _super);
        end

        local object = {};
        _function(object);

        CLASS[_name] = {
            TABLE = object,
            SUPER = CLASS[_super],
            TYPE = _name,
        };
        _G[_name] = {
            Name = _name;
            New = function(self,...)
                return NEW(self.Name,...);
            end
        };

    end

    local function INSTANCEOF(_object,_class)
        local table = CLASS[_object.type];
        while table ~= NULL do
            if table.TYPE == _class.Name then
                return true;
            end
            table = table.SUPER;
        end
        return false;
    end

    local function TYPE(value)
        if type(value) == "table" then
            if value.type ~= nil then
                return value.type;
            end
        end
        return type(value);
    end

    return CREATECLASS,INSTANCEOF,TYPE;
end)();

Class("Node",function(Node)
    function Node:constructor()
        self.parent = NULL;
        self.left = {};
        self.right = {};
    end
end);


Class("Symbol",function(Symbol)
    function Symbol:constructor(...)
        self.symbols = {};
        self.priorityMap = {};

        local values = {...};
        
        for i = 1,#values do
            for j = 1,#values[i] do
                self.symbols[#self.symbols+1] = values[i][j];
                self.priorityMap[values[i][j]] = i;
            end
        end

        table.sort(self.symbols,function(a,b)
            return #a > #b;
        end);
    end

    function Symbol:getPriority(symbol)
        return self.symbols[symbol];
    end

    function Symbol:getSymbol(text,index)
        for i = 1,#self.symbols do
            if self.symbols[i] == string.sub(text,index,index + #(self.symbols[i]) - 1) then
                return self.symbols[i];
            end
        end
        return nil;
    end

end);

Class("Keyword",function(Keyword)
    function Keyword:constructor(value)
        self.value = value;
    end
end);

Class("LexicalAnalyzer",function(LexicalAnalyzer)
    function LexicalAnalyzer:constructor(symbol)
        self.symbol = symbol;
    end

    function LexicalAnalyzer:Explain(text)
        local value = {};
        local stack = {};
        local i = 1;
        while i <= #text do
            local symbol = self.symbol:getSymbol(text,i);
            if symbol ~= nil then
                i = i + #symbol;
                value[#value+1] = table.concat(stack);
                stack = {};
                value[#value+1] = symbol;
            else
                if string.sub(text,i,i) ~= ' ' then
                    stack[#stack+1] = string.sub(text,i,i);
                else
                    value[#value+1] = table.concat(stack);
                    stack = {};
                end
                i = i + 1;
            end
        end
        if #stack > 0 then
            value[#value+1] = table.concat(stack);
            stack = {};
        end
        return value;
    end
end);

Symbol = Symbol:New(
    {"+","-"},
    {"*","/"}
);

LexicalAnalyzer = LexicalAnalyzer:New(Symbol);

local value = LexicalAnalyzer:Explain("44+2-3*2");

for i = 1,#value do
    print(value[i])
end

Class("SyntacticAnalysis",function(SyntacticAnalysis)
    function SyntacticAnalysis:constructor()
        self.root = Node:New();
    end

    function SyntacticAnalysis:Create(...)

    end

    function SyntacticAnalysis:Explain(list)
        local cursor = self.root;
        for i = 1,#list do
            local priority = Symbol:getPriority(list[i]);
            print(priority)
            if priority ~= nil then
            end
        end
    end
end);

SyntacticAnalysis = SyntacticAnalysis:New();

SyntacticAnalysis:Explain(value);


-- Class("Grammar",function(Grammar)
--     function Grammar:constructor()
--         self.array = {};
--         self.root = {};
--     end

--     function Grammar:Create(...)
--         self.array[#self.array+1] = {...};
--         table.sort(self.array[#self.array],function(a1,a2)
--             return #a1 > #a2;
--         end);
--     end

--     function Grammar:Explain(list,index)
--         index = index or 1;
--         local i = index;
--         while i <= #list do
--             for j = 1,#self.array do
--                 local grammar = self.array[j];
--                 for k = 1,#grammar do
--                     if type(grammar[k]) == "table" then
--                         local match = grammar[k]:Explain(list,index);
--                         if match == true then
--                             return true;
--                         end
--                     elseif list[i] == grammar[k] then
--                         return true;
--                     end
--                 end
--                 end
--             end
--         return false;
--     end
-- end);

-- S = Grammar:New();
-- NUMBER = Grammar:New();

-- S:Create("123");


-- S:Explain(value)
