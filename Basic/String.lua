(function()
    local function charSize(curByte)
        local seperate = {0, 0xc0, 0xe0, 0xf0}
        for i = #seperate, 1, -1 do
            if curByte >= seperate[i] then return i end
        end
        return 1
    end
    local String = {};

    function String:constructor(value)
        self.array = {};
        self.length = 0;
        self:insert(value);
    end

    function String:charAt(index)
        return self.array[index];
    end

    function String:substring(beginIndex,endIndex)
        local text = {};
        for i = beginIndex, endIndex, 1 do
            table.insert(text,self.array[i]);
        end
        return table.concat(text);
    end

    function String:isEmpty()
        return self.length == 0;
    end

    function String:insert(value,pos)
        pos = pos or #self.array + 1;
        if type(value) == "string" then
            local currentIndex = 1;
            while currentIndex <= #value do
                local cs = charSize(string.byte(value, currentIndex));
                table.insert(self.array,pos,string.sub(value,currentIndex,currentIndex+cs-1));
                currentIndex = currentIndex + cs;
                self.length = self.length + 1;
            end
        elseif type(value) == "table" then
            if value.type == "String" then 
                for i = 1, value.length, 1 do
                    table.insert(self.array,pos,value.array[i]);
                end
                self.length = self.length +  value.length;
            else
                local currentIndex = 1;
                while currentIndex <= #value do
                    local cs = charSize(value[currentIndex])
                    if cs == 1 then
                        table.insert(self.array,pos,string.char(value[currentIndex]));
                    elseif cs == 2 then
                        table.insert(self.array,pos,string.char(value[currentIndex],value[currentIndex+1]));
                    elseif cs == 3 then
                        table.insert(self.array,pos,string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2]));
                    elseif cs == 4 then
                        table.insert(self.array,pos,string.char(value[currentIndex],value[currentIndex+1],value[currentIndex+2],value[currentIndex+3]));
                    end
                    currentIndex = currentIndex+cs;
                    self.length = self.length + 1;
                end
            end
        end
    end
    function String:clean()
        self.array = {};
        self.length = 0;
    end

    function String:toBytes()
        local bytes = {};
        for i = 1, self.length, 1 do
            for j = 1, #self.array[i], 1 do
                table.insert(bytes,string.byte(self.array[i],j));
            end
        end
        return bytes;
    end

    function String:toString()
        return table.concat(self.array);
    end

    function String:__len()
        return self.length;
    end

    function String:__eq(value)
        return self.length == value.length and function()
            for i = 1, self.length, 1 do
                if self.array[i] ~= value.array[i] then
                    return false;
                end
            end
            return true;
        end
    end

    function String:__add(value)
        self:insert(value);
        return self;
    end

    function String:__concat(value)
        local str1 = IKit.New("String",self);
        str1:insert(value);
        return str1;
    end

    function String:__call(index)
        return self.array[index];
    end

    IKit.Create(String,"String");
end)();