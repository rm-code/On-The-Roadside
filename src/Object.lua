local Object = {};

function Object.new()
    local self = {
        __instances = { 'Object' };
    };

    function self:validateType( typeToCheck, parameter, isObject )
        local valid;

        if isObject then
            valid = parameter:instanceOf( typeToCheck );
        else
            valid = type( parameter ) == typeToCheck;
        end

        if not valid then
            error( tostring( parameter ) .. " is not of type " .. typeToCheck .. '!' );
        end
    end

    function self:addInstance( str )
        self.__instances[#self.__instances + 1] = str;
        return self;
    end

    function self:instanceOf( class )
        for i = 1, #self.__instances do
            if self.__instances[i] == class then
                return true;
            end
        end
        return false;
    end

    return self;
end

return Object;
