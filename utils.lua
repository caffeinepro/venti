-- (Deep) copy of tables
function table_copy(t, deep, seen)
    seen = seen or {}
    if t == nil then return nil end
    if seen[t] then return seen[t] end

    local nt = {}
    for k, v in pairs(t) do
        if deep and type(v) == 'table' then
            nt[k] = table_copy(v, deep, seen)
        else
            nt[k] = v
        end
    end
    -- setmetatable(nt, table_copy(getmetatable(t), deep, seen))
    seen[t] = nt
    return nt
end

function stub()
end