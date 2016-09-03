local a = {
    {1},{2},{3},{4}
}

for k,v in pairs(a) do
    if v[1] == 2 then v = nil end
end

for k, v in pairs(a) do
    print (v[1])
end