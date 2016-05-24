local Messenger = {};

local subscriptions = {};

function Messenger.publish( message, ... )
    for _, subscription in ipairs( subscriptions ) do
        if subscription.message == message then
            subscription.callback( ... );
        end
    end
end

function Messenger.observe( message, callback )
    subscriptions[#subscriptions + 1] = { message = message, callback = callback };
end

return Messenger;
