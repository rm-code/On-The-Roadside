local PATH, TBL = ...

local module = require( PATH )
for i, _ in pairs( module[TBL] or module ) do
    print(i)
end
