lib.callback.register('vehmaint:hasItem', function(source, item)
if not item or item == '' then return false end
local count = exports.ox_inventory:Search(source, 'count', item) or 0
return (count and count > 0) or false
end)


lib.callback.register('vehmaint:consumeItem', function(source, item, amount)
    if not item or item == '' then return false end
    amount = amount or 1

    local removed = exports.ox_inventory:RemoveItem(source, item, amount)

    if type(removed) == 'boolean' then
        return removed
    elseif type(removed) == 'number' then
        return removed > 0
    else
        return false
    end
end)
