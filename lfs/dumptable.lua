local o,z = ...
 if z == nil then z = 0 end
 if type(o) == 'table' then
    local s = '\n'
    local prefix = string.rep(' ',z)
    for k,v in pairs(o) do
       if type(v) == 'table' then z = z+1 s = s..'\n' end
       s = s..prefix..k..': '..string.rep(' ', 20-#k) .. LFS.dumptable(v, z) .. '\n'
    end
    return s
 else
    return tostring(o)
 end
