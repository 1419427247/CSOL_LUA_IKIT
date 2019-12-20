-- IKit = (function()
--     local class = {};
    
--     local call = function(table,...)
--         table:constructor(...);
--     end;

--     local newindex = function(table,key,value)
--         local tobject = table;
--         while tobject ~= nil do
--             for k in pairs(tobject) do
--                 if key == k then
--                     rawset(tobject,key,value);
--                     return;
--                 end
--             end
--             tobject = getmetatable(tobject);
--         end
--         rawset(table,key,value);
--     end

--     class["Object"] = {
--         type = "Object",
--         __newindex = newindex;
--         __call = call;
--     };

--     -- local function instanceof(table,string)
--     --     if type(table) == "table" and  type(string) == "string" then
--     --         local object = table;
--     --         while object ~= nil do
--     --             if object.type == string then
--     --                 return true;
--     --             else
--     --                 object = getmetatable(object);
--     --             end
--     --         end
--     --     end
--     --     return false;
--     -- end

--     local function clone(talbe)
--         local object = {};
--         for key, value in pairs(talbe) do
--             object[key] = value;
--         end
--         object.__index = object;
--         if getmetatable(talbe) ~= nil then
--             object.super = clone(getmetatable(talbe))
--             object.__newindex = object.super.__newindex;
--             object.__call = object.super.__call;
--             setmetatable(object,object.super);
--         end
--         return object;
--     end

--     local function create(object,name,father)
--         if object.constructor == nil then
--             function object:constructor()
--             end
--         end
--         if father ~= nil then
--             setmetatable(object,class[father]);
--         else
--             setmetatable(object,class["Object"]);
--         end
--         class[name] = object;
--     end

--     local function new(name,...)
--         local object = clone(class[name]);
--         object.type = name;
--         object:constructor(...);
--         return setmetatable({},object);
--     end

--     return {
--         Create = create,
--         New = new,
--     }
-- end)();


-- (function()
--     local function charSize(curByte)
--         local seperate = {0, 0xc0, 0xe0, 0xf0}
--         for i = #seperate, 1, -1 do
--             if curByte >= seperate[i] then return i end
--         end
--         return 1
--     end
--     local String = {};

--     function String:constructor(value)
--         self.array = {};
--         self.length = 0;
--         self:insert(value);
--     end

--     function String:charAt(index)
--         return self.array[index];
--     end

--     function String:substring(beginIndex,endIndex)
--         local text = IKit.New("String");
--         for i = beginIndex, endIndex, 1 do
--             text:insert(self.array[i]);
--         end
--         return text;
--     end

--     function String:isEmpty()
--         return self.length == 0;
--     end

--     function String:insert(value,pos)
--         pos = pos or self.length + 1;
--         if type(value) == "string" then
--             local currentIndex = 1;
--             while currentIndex <= #value do
--                 local cs = charSize(string.byte(value, currentIndex));
--                 if pos > self.length then
--                     self.array[#self.array+1] = string.sub(value,currentIndex,currentIndex+cs-1);
--                 else
--                     table.insert(self.array,pos,string.sub(value,currentIndex,currentIndex+cs-1));
--                 end
--                 currentIndex = currentIndex + cs;
--                 self.length = self.length + 1;
--                 pos = pos + 1;
--             end
--         elseif type(value) == "table" then
--             if value.type == "String" then
--                 for i = 1, value.length, 1 do
--                     if pos > self.length then
--                         self.array[#self.array+1] = value.array[i];
--                     else
--                         table.insert(self.array,pos,value.array[i]);
--                     end
--                     pos = pos + 1;
--                 end
--                 self.length = self.length +  value.length;
--             else
--                 local currentIndex = 1;
--                 while currentIndex <= #value do
--                     local cs = charSize(value[currentIndex])
--                     if pos > self.length then
--                         if cs == 1 then
--                             self.array[#self.array+1] = string.char(value[currentIndex]);
--                         elseif cs == 2 then
--                             self.array[#self.array+1] = string.char(value[currentIndex],value[currentIndex+1]);
--                         elseif cs == 3 then
--                             self.array[#self.array+1] = string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2]);
--                         elseif cs == 4 then
--                             self.array[#self.array+1] = string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2],value[currentIndex+3]);
--                         end
--                     else
--                         if cs == 1 then
--                             table.insert(self.array,pos,string.char(value[currentIndex]));
--                         elseif cs == 2 then
--                             table.insert(self.array,pos,string.char(value[currentIndex],value[currentIndex+1]));
--                         elseif cs == 3 then
--                             table.insert(self.array,pos,string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2]));
--                         elseif cs == 4 then
--                             table.insert(self.array,pos,string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2],value[currentIndex+3]));
--                         end
--                     end
--                     currentIndex = currentIndex+cs;
--                     self.length = self.length + 1;
--                     pos = pos + 1;
--                 end
--             end
--         end
--     end

--     function String:clean()
--         self.array = {};
--         self.length = 0;
--     end

--     function String:toBytes()
--         local bytes = {};
--         for i = 1, self.length, 1 do
--             for j = 1, #self.array[i], 1 do
--                 table.insert(bytes,string.byte(self.array[i],j));
--             end
--         end
--         return bytes;
--     end

--     function String:toNumber()
--         local sum = 0;
--         if self.array[1] == '-' then
--             for i = 2, #self.array, 1 do
--                 sum = sum * 10 + string.byte(self.array[i]) - 48;
--             end
--             sum = sum * -1;
--         else
--             for i = 1, #self.array, 1 do
--                 sum = sum * 10 + string.byte(self.array[i]) - 48;
--             end
--         end
--         return sum;
--     end

--     function String:toString()
--         return table.concat(self.array);
--     end

--     function String:__len()
--         return self.length;
--     end

--     function String:__eq(value)
--         return self.length == value.length and function()
--             for i = 1, self.length, 1 do
--                 if self.array[i] ~= value.array[i] then
--                     return false;
--                 end
--             end
--             return true;
--         end
--     end

--     function String:__add(value)
--         self:insert(value);
--         return self;
--     end

--     function String:__concat(value)
--         local str1 = IKit.New("String",self);
--         str1:insert(value);
--         return str1;
--     end

--     function String:__call(index)
--         return self.array[index];
--     end

--     IKit.Create(String,"String");
-- end)();






-- local s = os.clock()

-- local str = IKit.New("String");
-- for i = 1, 5000, 1 do
--     str = str .. IKit.New("String") .. "我的天啊";
-- end

-- local e = os.clock()
-- print("used time"..e-s.." seconds")

