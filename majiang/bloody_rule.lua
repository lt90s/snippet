local table = table

local function recoverTiles(tiles, AAA, ABC)
    for _, i in ipairs(AAA) do
        --print("recover AAA " .. i)
        tiles[i] = tiles[i] + 3
    end
    
    for _, i in ipairs(ABC) do
        --print("recover ABC " .. i)
        tiles[i] = tiles[i] + 1
        tiles[i+1] = tiles[i+1] + 1
        tiles[i+2] = tiles[i+2] + 1
    end
end

-- 判断第i门牌是否能够拆成ABC或者AAA型
local function isAAAorABC(tiles, i, AAA, ABC)
    k = i * 10 + 1
    for j = k, k + 8 do
        while tiles[j] > 0 do   -- loop twice at most
            -- AAA
            if tiles[j] >= 3 then
                --print("AAA: " .. j)
                tiles[j] = tiles[j] - 3
                table.insert(AAA, j)
            else    -- ABC
                if j % 10 > 7 and tiles[j] ~= 0 then  -- 扫到8这里，不可能有ABC，最大是9
                    return false
                end

                -- BC到数量至少等于A的数量
                if tiles[j] > tiles[j+1] then
                    --print("tiles[j] > tiles[j+1] " .. j)
                    return false
                end

                if tiles[j] > tiles[j+2] then
                    --print("tiles[j] > tiles[j+2] " .. j)
                    return false
                end

                -- OK. ABC型匹配成功
                for l = 1, tiles[j] do
                    --print("ABC: " .. j)
                    table.insert(ABC, j)
                end
                tiles[j+1] = tiles[j+1] - tiles[j]
                tiles[j+2] = tiles[j+2] - tiles[j]
                tiles[j] = 0
            end
        end
    end
    return true
end

-- 判断剩余的牌是否全部能够拆成ABC或者AAA型
local function restAAAorABC(tiles)
    local AAA = {}
    local ABC = {}
    for i = 0,2 do
        if not isAAAorABC(tiles, i, AAA, ABC) then
            recoverTiles(tiles, AAA, ABC)
            return false
        end
        recoverTiles(tiles, AAA, ABC)
        AAA = {}
        ABC = {}
    end
    return true
end

--[[
给定3*n + 2张麻将牌，判断是否能够和牌(血流成河规则）
tiles参数为一个数组
索引1-9的值表示1筒到9筒的数量
11-19的值表示1条到9条的数量
21-29的值表示1万到9万的数量
此函数不会改变tiles的值

--]]
local _M = {}

function _M.canWin(tiles)
    for i = 1, #tiles do
        local flag = true
        if tiles[i] >= 2 then
            tiles[i] = tiles[i] - 2
            --print("choose pair: " .. i)
            if not restAAAorABC(tiles) then
                flag = false
            end
            tiles[i] = tiles[i] + 2
            --print(flag)
            if flag then
                return true
            end
        end
    end
    return false
end

function _M.canPeng(tiles, tile)
    assert(tile > 0 and tile ~= 10 and tile ~= 20 and tile < 30)
    return tiles[tile] > 0
end

function _M.canGang(tiles, tile)
    assert(tile > 0 and tile ~= 10 and tile ~= 20 and tile < 30)
    return tiles[tile] == 3
end

function _M.canChi(tiles, tile)
    return false
end

function _M.getAllWinningTiles(tiles)
    local winning = {}
    local helper = function(k)
        local i = k * 10
        for j = i + 1, i + 9 do
            local flag = true

            if tiles[j] == 0 then
                local x = j % 10
                if x > 2 and x < 8 and
                    ((tiles[j-2] == 0 or tiles[j-1] == 0) or -- ABX
                    (tiles[j-1] == 0 or tiles[j+1] == 0) or -- AXC
                    (tiles[j+1] == 0 or tiles[j+2] == 0)) then -- XBC
                    flag = false
                end

                if x == 1 and (tiles[j+1] == 0 or tiles[j+1] == 0) then -- XAB
                    flag = false
                end

                if x == 9 and (tiles[j-2] == 0 or tiles[j-1] == 0) then -- AXC
                    flag = false
                end

                if x == 2 and ((tiles[j-1] == 0 or tiles[j+1] == 0) or -- AXC
                                (tiles[j+1] == 0 or tiles[j+2] == 0)) then -- ABX
                    flag = false
                end

                if x == 8 and ((tiles[j-2] == 0 or tiles[j-1] == 0) or -- ABX
                                (tiles[j-1] == 0 or tiles[j+1] == 0)) then -- AXB
                    flag = false
                end
            end

            if flag then
                print("test if can win " .. j)
                tiles[j] = tiles[j] + 1
                if _M.canWin(tiles) then
                    table.insert(winning, j)
                end
                tiles[j] = tiles[j] - 1
            end
        end
    end

    for i = 0, 2 do
        helper(i)
    end
    return winning
end

return _M
