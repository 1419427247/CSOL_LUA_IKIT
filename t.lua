(function()
    NULL = {};
    local CLASS = {};
    
    local Object = {

    }



    local function CREATECLASS(_name,_function,_super)
        local object = {};
        _function(object);

        CLASS[_name] = {
            NAME = _name,
            TABLE = object,
            SUPER = (_super or {}).NAME,
        }


        local str = {
            "local Object={__data={},__call=nil,__newindex=nil,__index=nil}",
            "Object.__index = function(table,key)",
            "if Object.__data[key] ~= nil then ",
            "return Object.__data[key];",
            "else ",
            "while table ~= nil do ",
            "if rawget(table,key) ~= nil then ",
            "return rawget(table,key);",
            "end ",
            "table = getmetatable(table);",
            "end ",
            "end ",
            "return nil;",
            "end ",
            "Object.__newindex = function(table,key,value);",
            "if Object.__data[key] ~= nil and type(value) ~= type(Object.__data[key]) then ",
            "error('key:'..key..':赋值类型与原类型不相同' .. type(value) .. '~=' .. type(table[key]));",
            "end ",
            "Object.__data[key] = value;",
            "end \n",
        }
        local classList = {CLASS[_name]}
        while _super ~= nil do
            clazzList[#clazzList+1] = _super.CLASS;
            _super = _super.CLASS.SUPER;
        end
        for i = 1,#classList do
            str[#str+1] = string.format("local %s = {super=nil,__call =nil,__newindex = Object.__newindex,__index = Object.__index,",classList[i].NAME)
            for key, value in pairs(classList[i].TABLE) do
                str[#str+1] = string.format("%s = CLASS['%s'].TABLE.%s,",key,classList[i].NAME,key);
            end
            str[#str+1] = "};\n"
        end
        for i = 1,#classList - 1 do
            str[#str+1] = string.format("setmetatable(%s,%s);",classList[i],classList[i+1]);
            str[#str+1] = string.format("%s.super=%s);",classList[i],classList[i+1]);
            str[#str+1] = string.format("%s.__call=%s.constructor or function() end;",classList[i],classList[i]);
        end
        str[#str+1] = string.format("%s.__call=%s.constructor or function() end;",classList[#classList].NAME,classList[#classList].NAME);
        str[#str+1] = string.format("setmetatable(%s,Object);",classList[#classList].NAME);
        str[#str+1] = string.format("return setmetatable({},%s);",_name);
        print(table.concat(str))
        CLASS[_name].NEW = load(table.concat(str),"","t",{error=error,type=type,rawget=rawget,getmetatable=getmetatable,setmetatable = setmetatable,CLASS = CLASS})


        _G[_name] = setmetatable({
            CLASS = CLASS[_name]
        },{
            __call = function(self,...)
                return self.CLASS.NEW(...);
            end
        });

        s = os.clock()
        for i = 1,1000000 do
            String(1);
        end
        print(os.clock()-s)
    end




    local Object = {
        __data = {},
        __call = function() end,
        __newindex = nil,
        __index = nil,
    };
    Object.__index = function(table,key)
        if Object.__data[key] ~= nil then
            return Object.__data[key];
        else
            while table ~= nil do
                if rawget(table,key) ~= nil then
                    return rawget(table,key);
                end
                table = getmetatable(table);
            end
        end
        return nil;
    end

    Object.__newindex = function(table,key,value)
        Object.__data[key] = value;
    end

    local String = {
        __call = Object.__call,
        __newindex = Object.__newindex,
        __index = Object.__index,
    }
    setmetatable(String,Object);
    
    CREATECLASS("String",function(String)
        function String:charSize(char)
            local seperate = {0, 0xc0, 0xe0, 0xf0}
            for i = #seperate, 1, -1 do
                if char >= seperate[i] then
                    return i;
                end
            end
            return 1;
        end
    
        function String:toString(value)
            local array = {};
            local currentIndex = 1;
            while currentIndex <= #value do
                local cs = String:charSize(value[currentIndex]);
                array[#array+1] = string.char(table.unpack(value,currentIndex,currentIndex + cs - 1));
                currentIndex = currentIndex + cs;
            end
            return table.concat(array);
        end
    
        function String:toBytes(value)
            local bytes = {};
            if type(value) == "string" then
                value = String:toTable(value);
            end
            for i = 1, #value do
                for j = 1, #value[i], 1 do
                    table.insert(bytes,string.byte(value[i],j));
                end
            end
            return bytes;
        end
    
        function String:toTable(value)
            local currentIndex = 1;
            local array = {};
            while currentIndex <= #value do
                local cs = String:charSize(string.byte(value, currentIndex));
                array[#array+1] = string.sub(value,currentIndex,currentIndex+cs-1);
                currentIndex = currentIndex + cs;
            end
            return array;
        end
    end);

end)();



-- Class,InstanceOf,Type = (function()
--     NULL = {};
--     local CLASS = {};
--     CLASS["Object"] = {
--         TABLE = {
--             type = "Object",
--             super = nil,
--             __call = function (table,...)
--                 table:constructor(...);
--             end,
--             __newindex = function(table,key,value)
--                 if value == nil then
--                     error("不可将字段设置为nil");
--                 end
--                 local temporary = table;
--                 if key == "type" and temporary.type ~= nil then
--                     error("type不可修改");
--                 end
--                 while table ~= nil do
--                     for k in pairs(table) do
--                         if key == k then
--                             rawset(table,key,value);
--                             return;
--                         end
--                     end
--                     table = getmetatable(table);
--                 end
--                 rawset(temporary,key,value);
--             end,
--         },
--         SUPER = NULL,
--         TYPE = "Object",
--     }

--     local function CLONE(_table)
--         local object = {};
--         for key, value in pairs(_table.TABLE) do
--             object[key] = value;
--         end
--         object.__index = object;
--         if _table.SUPER ~= NULL then
--             object.super = CLONE(_table.SUPER)
--             object.type = _table.TYPE;
--             object.__call = object.super.__call;
--             object.__newindex = object.super.__newindex;
--             setmetatable(object,object.super);
--         end
--         return object;
--     end

--     local function NEW(_name,...)
--         if CLASS[_name] == nil then
--             error("没有找到类:" .. _name);
--         end
--         local object = CLONE(CLASS[_name]);
--         object(...);
--         rawset(object,"type",_name);
--         return setmetatable({},object);
--     end

--     local function CREATECLASS(_name,_function,_super)
--         _super = (_super or {Name = "Object"}).Name;

--         if CLASS[_name] ~= nil then
--             error("类'".. _name .."'重复定义");
--         end
--         if CLASS[_super] == nil then
--             error("没有找到类:" .. _super);
--         end

--         local object = {};
--         _function(object);

--         CLASS[_name] = {
--             TABLE = object,
--             SUPER = CLASS[_super],
--             TYPE = _name,
--         };
--         _G[_name] = {
--             Name = _name;
--             New = function(self,...)
--                 return NEW(self.Name,...);
--             end
--         };

--     end

--     local function INSTANCEOF(_object,_class)
--         local table = CLASS[_object.type];
--         while table ~= NULL do
--             if table.TYPE == _class.Name then
--                 return true;
--             end
--             table = table.SUPER;
--         end
--         return false;
--     end

--     local function TYPE(value)
--         if type(value) == "table" then
--             if value.type ~= nil then
--                 return value.type;
--             end
--         end
--         return type(value);
--     end

--     return CREATECLASS,INSTANCEOF,TYPE;
-- end)();

-- Class("Node",function(Node)
--     function Node:constructor()
--         self.parent = NULL;
--         self.children = {};
--     end

--     function Node:add(node)
--         if node.parent ~= NULL then
--             node.parent:remove(node);
--         end
--         node.parent = self;
--         self.children[#self.children+1] = node;
--     end

--     function Node:remove(node)
--         for i = 1,#self.children do
--             if self.children[i] == node then
--                 self.children[i].parent = NULL;
--                 table.remove(self.children,i);
--                 return;
--             end
--         end
--     end

-- end);


-- Class("Symbol",function(Symbol)
--     function Symbol:constructor(...)
--         self.symbols = {};
--         self.priorityMap = {};

--         local values = {...};
        
--         for i = 1,#values do
--             for j = 1,#values[i] do
--                 self.symbols[#self.symbols+1] = values[i][j];
--                 self.priorityMap[values[i][j]] = i;
--             end
--         end

--         table.sort(self.symbols,function(a,b)
--             return #a > #b;
--         end);
--     end

--     function Symbol:isSymbol(symbol)
--         return self.priorityMap[symbol] ~= nil;
--     end

--     function Symbol:getPriority(symbol)
--         return self.priorityMap[symbol];
--     end

--     function Symbol:getSymbol(text,index)
--         for i = 1,#self.symbols do
--             if self.symbols[i] == string.sub(text,index,index + #(self.symbols[i]) - 1) then
--                 return self.symbols[i];
--             end
--         end
--         return nil;
--     end

-- end);

-- Class("Keyword",function(Keyword)
--     function Keyword:constructor(...)
--         self.keywordsMap = {};
--         local values = {...};
        
--         for i = 1,#values do
--             self.keywordsMap[values[i]] = {};
--         end
--     end

--     function Keyword:isKeyword(keyword)
--         return self.keywordsMap[keyword] ~= nil;
--     end

-- end);

-- Class("LexicalAnalyzer",function(LexicalAnalyzer)
--     function LexicalAnalyzer:constructor(symbol)
--         self.symbol = symbol;
--     end

--     function LexicalAnalyzer:Explain(text)
--         local value = {};
--         local stack = {};
--         local i = 1;

--         while i <= #text do
--             local symbol = self.symbol:getSymbol(text,i);
--             if symbol ~= nil then
--                 i = i + #symbol;
--                 value[#value+1] = table.concat(stack);
--                 stack = {};
--                 value[#value+1] = symbol;
--             else
--                 if string.sub(text,i,i) ~= ' ' then
--                     stack[#stack+1] = string.sub(text,i,i);
--                 else
--                     value[#value+1] = table.concat(stack);
--                     stack = {};
--                 end
--                 i = i + 1;
--             end
--         end
--         if #stack > 0 then
--             value[#value+1] = table.concat(stack);
--             stack = {};
--         end
--         return value;
--     end
-- end);

-- Symbol = Symbol:New(
--     {"+","-"},
--     {"*","/"},
--     {"%","^"}
-- );

-- LexicalAnalyzer = LexicalAnalyzer:New(Symbol);

-- Class("SyntacticAnalysis",function(SyntacticAnalysis)
--     function SyntacticAnalysis:constructor()

--     end

--     function SyntacticAnalysis:Explain(list)
--         local cursor = NULL;
--         for i = 1,#list do
--             if cursor ==NULL then
--                 cursor = Node:New();
--                 cursor.value = list[i];
--             else
--                 local node = Node:New();
--                 node.value = list[i];
--                 if Symbol:isSymbol(list[i]) then
--                     if cursor.parent == NULL then
--                         node:add(cursor);
--                     else
--                         if Symbol:getPriority(list[i]) > Symbol:getPriority(cursor.parent.value) then
--                             -- print(list[i] .. ">" .. cursor.parent.value)
--                             local tmp = cursor.parent;
--                             node:add(cursor);
--                             tmp:add(node);
--                         elseif Symbol:getPriority(list[i]) < Symbol:getPriority(cursor.parent.value) then
--                             -- print(list[i] .. "<" .. cursor.parent.value)
--                             node:add(cursor.parent);
--                         else
--                             node:add(cursor.parent);
--                         end
--                     end
--                 else
--                     cursor:add(node);
--                 end
--                 cursor = node;
--             end
--         end

--         while cursor.parent ~= NULL do
--             cursor = cursor.parent;
--         end
--         return cursor;
--     end
-- end);

-- SyntacticAnalysis = SyntacticAnalysis:New();

-- local root = SyntacticAnalysis:Explain(LexicalAnalyzer:Explain("42*32^38768672"));

-- function ExplainTree(root)
--     if root.value == "*" then
--         return ExplainTree(root.children[1]) * ExplainTree(root.children[2]);
--     elseif root.value == "/" then
--         return ExplainTree(root.children[1]) / ExplainTree(root.children[2]);
--     elseif root.value == "+" then
--         return ExplainTree(root.children[1]) + ExplainTree(root.children[2]);
--     elseif root.value == "-" then
--         return ExplainTree(root.children[1]) - ExplainTree(root.children[2]);
--     elseif root.value == "^" then
--         return math.pow(ExplainTree(root.children[1]),ExplainTree(root.children[2]));
--     else
--         return tonumber(root.value);
--     end
-- end

-- print(ExplainTree(root));

-- function PrintTree(root,index)
--     index = index or 1;
--     local space = {};
--     space[#space+1] = "|";
--     for i = 2,index-1 do
--         space[#space+1] = "--";
--     end
--     space[#space+1] = "->  | ";
--     space[#space+1] = root.value;
--     print(table.concat(space));
--     for i = 1,#root.children do
--         PrintTree(root.children[i],index + 1)
--     end
-- end

-- print("table")
-- PrintTree(root);

-- -- function PrintTree(root)
-- --     local list = {};
-- --     list[#list+1] = root.value .. "\n";
-- --     for i = 1,#root.children do
-- --         list[#list+1] = PrintTree(root.children[i]);
-- --     end
-- --     return table.concat(list," ");
-- -- end

-- -- print(PrintTree(root))


-- -- Class("Grammar",function(Grammar)
-- --     function Grammar:constructor()
-- --         self.array = {};
-- --         self.root = {};
-- --     end

-- --     function Grammar:Create(...)
-- --         self.array[#self.array+1] = {...};
-- --         table.sort(self.array[#self.array],function(a1,a2)
-- --             return #a1 > #a2;
-- --         end);
-- --     end

-- --     function Grammar:Explain(list,index)
-- --         index = index or 1;
-- --         local i = index;
-- --         while i <= #list do
-- --             for j = 1,#self.array do
-- --                 local grammar = self.array[j];
-- --                 for k = 1,#grammar do
-- --                     if type(grammar[k]) == "table" then
-- --                         local match = grammar[k]:Explain(list,index);
-- --                         if match == true then
-- --                             return true;
-- --                         end
-- --                     elseif list[i] == grammar[k] then
-- --                         return true;
-- --                     end
-- --                 end
-- --                 end
-- --             end
-- --         return false;
-- --     end
-- -- end);

-- -- S = Grammar:New();
-- -- NUMBER = Grammar:New();

-- -- S:Create("123");


-- -- S:Explain(value)
