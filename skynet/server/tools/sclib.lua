-----------------------------------------------------------------------------
-- Script Lib
-- 定义一些通用的脚本逻辑
-----------------------------------------------------------------------------

local sclib = {}

--简单位操作
local mybit = class("MyBit")


function mybit.andBit(left, right)
    return (left == 1 and right == 1) and 1 or 0
end

function mybit.orBit(left, right)
    return (left == 1 or right == 1) and 1 or 0
end

function mybit.xorBit(left, right)
    return (left + right == 1) and 1 or 0
end

function mybit.dealBit(left, right, op)
    if left < right then
        left, right = right, left
    end

    local ret = 0
    local w = 1
    while left ~= 0 do
        local abit = left % 2
        local bbit = right % 2

        local bit = op(abit, bbit)
        if bit ~= 0 then
            ret = ret + w
        end

        w = 2 * w
        left = math.modf(left / 2)
        right = math.modf(right / 2)
    end
    return ret
end

function mybit.band(left, right)
    return mybit.dealBit(left, right, mybit.andBit)
end

function mybit.bor(left, right)
    return mybit.dealBit(left, right, mybit.orBit)
end

function mybit.bxor(left, right)
    return mybit.dealBit(left, right, mybit.xorBit)
end

sclib.bit = mybit

-- draw boudingbox
function sclib:drawRect(node,parent)
    local rect = node:getBoundingBox()
    local draw = cc.DrawNode:create()
    parent:addChild(draw)
    local drawRect = draw:drawRect(cc.p(rect.x,rect.y),cc.p(rect.x+rect.width,rect.y+rect.height),cc.c4f(0,1,0,1))
end

-- 栈
----------------------------------------------------------
local Stack = class("stack")

function Stack:ctor()
    self.list = {}
end

function Stack:top() 
    return self.list[1]
end

function Stack:push(obj)
    table.insert(self.list,1,obj)
end

function Stack:pop()
    local obj = self.list[1]
    table.remove(self.list,1)
    return obj
end

sclib.stack = Stack


-- 队列
----------------------------------------------------------
local Queue = class("queue")

function Queue:ctor()
    self.list = {}
    self.first = 0
    self.last = -1
end

function Queue:front()
    if self:empty() == true then
        return false
    end
    return self.list[self.first]
end

function Queue:pop()
    if self:empty() == true then
        return false
    end
    self.list[self.first] = nil
    self.first = self.first +1
    return true
end

function Queue:push(obj)
    self.last = self.last + 1
    self.list[self.last] = obj
end

function Queue:empty()
    return self.last < self.first
end

function Queue:size()
    return self.last - self.first +1
end

sclib.queue = Queue


function sclib:callBack(tb_callback)
    local instance, func = unpack(tb_callback)
    local function innerCall()
        if type(instance) == "function" then
            return instance(unpack(tb_callback, 2))
        elseif instance and func then
            if type(instance) == "userdata" and type(func) == "function" then
                return func(instance, unpack(tb_callback, 3))
            elseif type(instance) == "userdata" and type(func) == "string" then
                return instance[func](instance, unpack(tb_callback, 3))
            elseif type(instance) == "string" and type(func) == "string" then
                local obj = ObjManager:get(instance)
                if obj and obj[func] then
                    return obj[func](obj, unpack(tb_callback, 3))
                end
            end
        end
        return false, "Error callBack args!!!"
    end
    
    local tbRet = {xpcall(innerCall, sclib.showStack)}
    return unpack(tbRet)
end

function sclib.showStack(s)
    print(debug.traceback(s,2))
    return s
end

-- 函数
----------------------------------------------------------
-- 与服务端此时的os.time()一致
function sclib:getTime()
    return os.time() + (self._delt_sec_ser or 0)
end

-- 参数t必须是sclib:getTime()或是服务端传过来的os.time()的表达式
function sclib:getDate(fmt, t)
    t = t or self:getTime()
    t = t - (self._delt_sec_ser or 0) + (self._delt_sec_fix or 0)
    return os.date(fmt, t)
end

function sclib:initTime(sec_fix, sec_ser)
    local now = os.time()
    self._delt_sec_fix = sec_fix - now
    self._delt_sec_ser = sec_ser - now
end

function sclib:isSameArray(tb1, tb2)
    if tb1 and tb2 then
        table.sort(tb1)
        table.sort(tb2)
        if #tb1 == #tb2 then
            for k, v in ipairs(tb1) do
                if v ~= tb2[v] then
                    return false
                end
            end
            return true
        end
    end
    return false
end

function sclib:countTB(tbVar)
    local nCount = 0;
    for _, _ in pairs(tbVar) do
        nCount  = nCount + 1;
    end;
    return nCount;
end

function sclib:isEmptyTB(tbVar)
    for _, _ in pairs(tbVar) do
        return 0;
    end;
    return 1;
end

-- 合并2个表，用于下标默认的表
function sclib:mergeTable(tableA, tableB)
    for _, item in ipairs(tableB) do
        tableA[#tableA + 1] = item;
    end
    
    return tableA;
end

-- 合并2个非顺序表，用于下标默认的表
function sclib:mergeTable2(tableA, tableB)
    local tbMerge = {};
    for _, item in pairs(tableA or {}) do
        table.insert(tbMerge, item);
    end
    for _, item in pairs(tableB or {}) do
        table.insert(tbMerge, item);
    end 
    return tbMerge;
end

-- 合并2个非顺序表  key 必须不同
function sclib:unionTable(tableA, tableB)
    local tbMerge = {};
    for k, v in pairs(tableA or {}) do
        tbMerge[k] = v 
    end
    for k, v in pairs(tableB or {}) do
        tbMerge[k] = v
    end 
    return tbMerge;
end
function sclib:strVal2Str(szVal)
    szVal   = string.gsub(szVal, "\\", "\\\\");
    szVal   = string.gsub(szVal, '"', '\\"');
    szVal   = string.gsub(szVal, "\n", "\\n");
    szVal   = string.gsub(szVal, "\r", "\\r");
    --szVal = string.format("%q", szVal);
    return '"'..szVal..'"';
end

-- 去除指定字符串首尾指定字符
function sclib:strTrim(szDes, szTrimChar)
    if (not szTrimChar) then
        szTrimChar = " ";
    end
    
    if (string.len(szTrimChar) ~= 1) then
        return szDes;
    end
    
    local szRet, nCount = string.gsub(szDes, "("..szTrimChar.."*)([^"..szTrimChar.."]*.*[^"..szTrimChar.."])("..szTrimChar.."*)", "%2");
    if (nCount == 0) then
        return "";
    end
    
    return szRet;
end

function sclib:val2Str(var, szBlank)
    local szType    = type(var);
    if (szType == "nil") then
        return "nil";
    elseif (szType == "number") then
        return tostring(var);
    elseif (szType == "string") then
        return self:strVal2Str(var);
    elseif (szType == "function") then
        local szCode    = string.dump(var);
        local arByte    = {string.byte(szCode, 1, #szCode)};
        szCode  = "";
        for i = 1, #arByte do
            szCode  = szCode..'\\'..arByte[i];
        end;
        return 'loadstring("' .. szCode .. '")';
    elseif (szType == "table") then
        if not szBlank then
            szBlank = "";
        end;
        local szTbBlank = szBlank .. "  ";
        local szCode    = "";
        for k, v in pairs(var) do
            local szPair    = szTbBlank.."[" .. self:val2Str(k) .. "]   = " .. self:val2Str(v, szTbBlank) .. ",\n";
            szCode  = szCode .. szPair;
        end;
        if (szCode == "") then
            return "{}";
        else
            return "\n"..szBlank.."{\n"..szCode..szBlank.."}";
        end;
    else    --if (szType == "userdata") then
        return '"' .. tostring(var) .. '"';
    end;
end

function sclib:str2Val(szVal)
    return assert(loadstring("return "..szVal))();
end

function sclib:concatStr(tbStrElem, szSep)
    if (not szSep) then
        szSep = ",";
    end
    return table.concat(tbStrElem, szSep);
end

function sclib:splitStr(szStrConcat, szSep)
    if (not szSep) then
        szSep = ",";
    end;
    local tbStrElem = {};
    
    --特殊转义字符指定长度
    local tbSpeSep = {
        ["%."] = 1;
    };
    
    local nSepLen = tbSpeSep[szSep] or #szSep;
    local nStart = 1;
    local nAt = string.find(szStrConcat, szSep);
    while nAt do
        tbStrElem[#tbStrElem+1] = string.sub(szStrConcat, nStart, nAt - 1);
        nStart = nAt + nSepLen;
        nAt = string.find(szStrConcat, szSep, nStart);
    end
    tbStrElem[#tbStrElem+1] = string.sub(szStrConcat, nStart);
    return tbStrElem;
end

-- 获得一个32位数中指定位段(0~31)所表示的整数
function sclib:loadBits(nInt32, nBegin, nEnd)
    if (nBegin > nEnd) then
        local _ = nBegin;
        nBegin = nEnd;
        nEnd   = _;
    end
    if (nBegin < 0) or (nEnd >= 32) then
        return 0;
    end
    nInt32 = nInt32 % (2 ^ (nEnd + 1));
    nInt32 = nInt32 / (2 ^ nBegin);
    return math.floor(nInt32);
end

-- 设置一个32位数中的指定位段(0~31)为指定整数
function sclib:setBits(nInt32, nBits, nBegin, nEnd)
    if (nBegin > nEnd) then
        local _ = nBegin;
        nBegin = nEnd;
        nEnd   = _;
    end
    nBits = nBits % (2 ^ (nEnd - nBegin + 1));
    nBits = nBits * (2 ^ nBegin);
    nInt32 = nInt32 % (2 ^ nBegin) + nInt32 - nInt32 % (2 ^ (nEnd + 1));
    nInt32 = nInt32 + nBits;
    return nInt32;
end

-- 功能:  把字符串扩展为长度为nLen,左对齐, 其他地方用空格补齐
-- 参数:  szStr   需要被扩展的字符串
-- 参数:  nLen    被扩展成的长度
function sclib:strFillL(szStr, nLen, szFilledChar)
    szStr               = tostring(szStr);
    szFilledChar        = szFilledChar or " ";
    local nRestLen      = nLen - string.len(szStr);                             -- 剩余长度
    local nNeedCharNum  = math.floor(nRestLen / string.len(szFilledChar));  -- 需要的填充字符的数量
    
    szStr = szStr..string.rep(szFilledChar, nNeedCharNum);                  -- 补齐
    return szStr;
end

-- 中文字符左对齐
function sclib:strFillL_CN(szStr, nLen, szFilledChar)
    szStr               = tostring(szStr);
    szFilledChar        = szFilledChar or " ";
    local nRestLen      = nLen - string.clen(szStr);                             -- 剩余长度
    local nNeedCharNum  = math.floor(nRestLen / string.clen(szFilledChar));  -- 需要的填充字符的数量
    
    szStr = szStr..string.rep(szFilledChar, nNeedCharNum);                  -- 补齐
    return szStr;
end

-- 功能:  把字符串扩展为长度为nLen,右对齐, 其他地方用空格补齐
-- 参数:  szStr   需要被扩展的字符串
-- 参数:  nLen    被扩展成的长度
function sclib:strFillR(szStr, nLen, szFilledChar)
    szStr               = tostring(szStr);
    szFilledChar        = szFilledChar or " ";
    local nRestLen      = nLen - string.clen(szStr);                             -- 剩余长度
    local nNeedCharNum  = math.floor(nRestLen / string.clen(szFilledChar));  -- 需要的填充字符的数量
    
    szStr = string.rep(szFilledChar, nNeedCharNum).. szStr;                 -- 补齐
    return szStr;
end

-- 中文字符右对齐
function sclib:strFillR_CN(szStr, nLen, szFilledChar)
    szStr               = tostring(szStr);
    szFilledChar        = szFilledChar or " ";
    local nRestLen      = nLen - string.len(szStr);                             -- 剩余长度
    local nNeedCharNum  = math.floor(nRestLen / string.len(szFilledChar));  -- 需要的填充字符的数量
    
    szStr = string.rep(szFilledChar, nNeedCharNum).. szStr;                 -- 补齐
    return szStr;
end

-- 功能:  把字符串扩展为长度为nLen,居中对齐, 其他地方以空格补齐
-- 参数:  szStr   需要被扩展的字符串
-- 参数:  nLen    被扩展成的长度
function sclib:strFillC(szStr, nLen, szFilledChar)
    szStr               = tostring(szStr);
    szFilledChar        = szFilledChar or " ";
    local nRestLen      = nLen - string.len(szStr);                             -- 剩余长度
    local nNeedCharNum  = math.floor(nRestLen / string.len(szFilledChar));  -- 需要的填充字符的数量
    local nLeftCharNum  = math.floor(nNeedCharNum / 2);                         -- 左边需要的填充字符的数量
    local nRightCharNum = nNeedCharNum - nLeftCharNum;                          -- 右边需要的填充字符的数量

    szStr = string.rep(szFilledChar, nLeftCharNum)
            ..szStr..string.rep(szFilledChar, nRightCharNum);               -- 补齐
    return szStr;
end

-- 功能：调用JAVA层函数回调
function sclib:callJava(className,methodName,args,sigs)    
        local luaj = require "cocos.cocos2d.luaj"
        local ok,ret = luaj.callStaticMethod(className,methodName,args,sigs)
        if not ok then
            print("luaj error:", ret)
        end
end

-- 从 1 - N 里面 随机选 M 个不同的数 (N >= M)
function sclib:genRandNum(N, M)
    if N < M then
        return;
    end
    local tbSeq = {};
    for i = 1, N do
        tbSeq[i] = i;
    end
    local tbRet = {};
    for i = 1, M do
        local j = math.random(i, N);
        if i ~= j then
            local t = tbSeq[i];
            tbSeq[i] = tbSeq[j];
            tbSeq[j] = t;
        end
        tbRet[i] = tbSeq[i];
    end
    return tbRet;
end

-- 概率随机 例: tbRate = {5, 3, 2}, 50%返回1, 30%返回2, 20%返回3
function sclib:randByRate(tbRate)
    local nSum = 0;
    for i, v in ipairs(tbRate) do
        nSum = nSum + v;
    end
    local nRand = math.random(nSum);
    for i, v in ipairs(tbRate) do
        if nRand <= v then
            return i;
        end
        nRand = nRand - v;
    end
    return 0;
end

-- 从带权重的N个数里面随机M个数，既上面两者的结合
function sclib:getRandNumByRate(tbRate, M)
	local N = #tbRate
	
    if N < M then
        return;
    end
	
    local tbSeq = {};
    for i = 1, N do
        tbSeq[i] = i;
    end
    local tbRet = {};
	
	local nSum = {};
    for i, v in ipairs(tbRate) do
		if i == 1 then
			nSum[i] = v
		else
			nSum[i] = nSum[i - 1] + v;
		end
    end

    for i = 1, M do
		local k = N - i  + 1
	    local nRand = math.random(1, nSum[k]);
		local j = k
		while( j > 1 and nRand <= nSum[j - 1] )
		do
			j = j - 1
		end
        if k ~= j then
            local t = tbSeq[k];
            tbSeq[k] = tbSeq[j];
            tbSeq[j] = t;
			for l = j, k - 1 do
				local v = tbRate[tbSeq[l]]
				if l == 1 then
					nSum[l] = v
				else
					nSum[l] = nSum[l - 1] + v;
				end
			end
        end
        tbRet[i] = tbSeq[k];
    end
    return tbRet;
end

-- 随机 M 个正整数，使其和为 N (N >= M)
function sclib:getRandDepart(N, M)
    if N < M then
        return;
    end
	if M == 1 then
		return {N}
	end
	local tbRet = self:genRandNum(N - 1, M - 1)
	table.sort(tbRet)
	for i = M, 2, -1 do
		if i == M then
			tbRet[i] = N - tbRet[i - 1]
		else
			tbRet[i] = tbRet[i] - tbRet[i - 1]
		end
	end
	return tbRet;
end

return sclib