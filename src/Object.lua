local Object = {};

function Object.new()
    local self = {
        __instances = {
            Object = true
        };
    };

    function self:addInstance( class )
        self.__instances[class] = true;
        return self;
    end

    function self:instanceOf( class )
        return self.__instances[class];
    end

    return self;
end

return Object;
