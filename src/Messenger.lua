local Messenger = {};

local subscriptions = {};
local index = 0;

---
-- Publishes a message to all subscribers.
-- @param message (string) The message's type.
-- @param ...     (vararg) One or multiple arguments passed to the subscriber.
--
function Messenger.publish( message, ... )
    for _, subscription in pairs( subscriptions ) do
        if subscription.message == message then
            subscription.callback( ... );
        end
    end
end

---
-- Registers a callback belonging to a certain subscriber.
-- @param message  (string)   The message to listen for.
-- @param callback (function) The function to call once the message is published.
-- @return         (number)   The index pointing to the subscription.
--
function Messenger.observe( message, callback )
    index = index + 1;
    subscriptions[index] = { message = message, callback = callback };
    return index;
end

---
-- Removes a subscription based on its index.
-- @param nindex (number) The index of the subscription to remove.
--
function Messenger.remove( nindex )
    subscriptions[nindex] = nil;
end

return Messenger;
