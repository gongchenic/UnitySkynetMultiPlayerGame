--[[
-- 禁止全局变量
setmetatable(_G, {
    __newindex = function (_, n)
        error("attempt to write to undeclared variable "..n, 2)
    end,
    __index = function (_, n)
        error("attempt to read undeclared variable "..n, 2)
    end,
})
]]

crypto = require("tools/crypto")
sclib = require("tools/sclib")

-- 设置随机数种子
math.randomseed(os.time())

-- 一些全局函数
max = math.max
min = math.min

-- 定义一些快捷函数
local format = string.format
local concat = table.concat
local strbyte = string.byte

----------------------------------------------------------
-- 重载/自定义 table函数
----------------------------------------------------------
-- 返回一个table一级key个数
table.count = function(tab)
    local num = 0
    for k,v in pairs(tab) do
        num = num + 1
    end
    return num
end

-- 对数组的操作
table.removebyvalue = function (tab,val)
    local ind = nil
    for i,o in pairs(tab) do
        if o == val then
            ind = i
            break
        end
    end
    if ind then
        table.remove(tab,ind)
    end
end

table.select = function (tab,key,value)
    local result = {}
    for _,row in pairs(tab) do
        if row[key] == value then
            table.insert(result,row)
        end
    end
    return result
end

----------------------------------------------------------
-- 重载/自定义 string函数
----------------------------------------------------------
function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 1, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        local str = string.sub(input, pos, st - 1)
        if str ~= "" then
            table.insert(arr, str)
        end
        pos = sp + 1
    end
    if pos <= string.len(input) then
        table.insert(arr, string.sub(input, pos))
    end
    return arr
end

-- 不合法
function string.onlynumandletter(str)
    local len = string.len(str)
    for i=1,len do
        local ch = string.sub(str,i,i)
        local num = string.byte(ch)
        if (num <= string.byte("Z") and num >= string.byte("A")) 
            or (num <= string.byte("z") and num >= string.byte("a"))  
            or (num <= string.byte("9") and num >= string.byte("0")) then
        else
            return false
        end
    end
    return true
end

function string.onlynumandletterandchinese( str )
    local char_tab = string.splitchar( str)
    local len = #char_tab
    for i=1,len do
        local ch = char_tab[i]
        local num = string.byte(ch)
        if (num <= string.byte("Z") and num >= string.byte("A")) 
            or (num <= string.byte("z") and num >= string.byte("a"))
            or (num >= 128 )  
            or (num <= string.byte("9") and num >= string.byte("0")) then
        else
            return false
        end
    end
    return true
end

function string.maskwordReplace(str)
    if Maskword == nil then
        return str
    end
    local oldstr = str
    str = string.lower(str)
    for _,v in pairs(Maskword) do
        --print(str,v.maskword)
       local maskword = string.lower(v.maskword)
       local len = string.rlen(string.lower(maskword))
       local replacestr =""
       for i=1,len do
           replacestr = replacestr .."*"
       end
        str = string.gsub(str,maskword,replacestr)
    end
    local old_char_tab = string.splitchar(oldstr)
    local char_tab = string.splitchar(str)
    local retstr = ""
    for k,char in pairs(old_char_tab) do
        if char_tab[k] == "*" then
            retstr =  retstr .."*"
        else
            retstr =  retstr .. old_char_tab[k]
        end
    end
    return retstr
end

-- 计算包括中文的字符长度(一个汉字算两个字符)
function string.clen( str )
    local sum_len= 0
    local char_tab = string.splitchar(str)
    for k,char in pairs(char_tab) do
        sum_len = sum_len +1
        if string.len(char) >1 then
           sum_len = sum_len +1
        end
    end
    return sum_len 
end

-- 计算包括中文的字符长度(一个汉字算1个字符)
function string.rlen( str )
    local sum_len= 0
    local char_tab = string.splitchar(str)
    for k,char in pairs(char_tab) do
        sum_len = sum_len +1
    end
    return sum_len 
end

-- 计算包括中文的字符个数
function string.charnum( str )
     local _, count = string.gsub(str, "[^\128-\193]", str)
     return count
end

-- 返回包含中文的 字符
function string.splitchar( str)
     local tab = {}
     local _, count = string.gsub(str, "[^\128-\193]", str)
     for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do tab[#tab+1] = uchar end
     return tab
end

-- 返回文字自动换行 行数 文本框的高度
function string.auto_height(str,width,front_size,line_dis)
    if line_dis == nil then
        line_dis = 5
    end
    local charnum = string.clen(str)
    local total_len = front_size * charnum /2
    local line_num = math.ceil(total_len/width)
    local height = line_num * front_size + (line_num-1) * line_dis
    return math.floor(height)
end

function string.checkUserId(id)
    local maxidlen = 18 
    local minidlen = 3
    local idlen = string.clen(id)
    if string.onlynumandletter(id) == false  or idlen > maxidlen or idlen < minidlen then
        return false 
    end
    return true
end

function string.checkNickname(id)
    local maxidlen = 14 
    local minidlen = 4
    local idlen = string.clen(id)
    if string.onlynumandletterandchinese(id) == false  or idlen > maxidlen or idlen < minidlen then
        return false 
    end
    return true
end

--e.g 011 0001 -> 0111
function string.mergeBitString(str1, str2)
    local len1 = string.len(str1)
    local len2 = string.len(str2)

    local str_ret = ""
    for i = 1, math.max(len1, len2) do 
        local state1 = i <= len1 and string.sub(str1, i, i) or "0"
        local state2 = i <= len2 and string.sub(str2, i, i) or "0"
        local state = state1 == "1" and "1" or state2
        str_ret = str_ret..state
    end
    return str_ret
end

-- 用于字符分析
function string.bencode(s)
    return (string.gsub(s, "(.)", function (x)
    return string.format("\\%03d", string.byte(x))
    end))
end

function string.bdecode(s)
    return (string.gsub(s, "\\(%d%d%d)", function (d)
    return string.char(d)
    end))
end

-- 字符串转十六进制数
function string.dumphex(data)
    return string.gsub(data, ".", function(x) return format("%02x ", strbyte(x)) end)
end

-- 十六进制数转字符串
function string.dedump(data)
    local bytes = string.split(data," ")
    for i, byte in pairs(bytes) do
        bytes[i] = string.char(format("%d", tonumber(byte,16)))
    end
    return concat(bytes)
end

function g_heros_compare(a,b)
    if a.level > b.level then
        return true
    elseif a.level < b.level then
        return false
    elseif a.level == b.level then
        if a.quality > b.quality then
            return true
        elseif a.quality < b.quality then
            return false
        end
    end
    return false
end

