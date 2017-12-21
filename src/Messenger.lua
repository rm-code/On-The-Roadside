---
-- @module Messenger
--

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Messenger = {}

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local subscriptions = {}
local index = 0

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Publishes a message to all subscribers.
-- @tparam string message The message's type.
-- @tparam vararg ...     One or multiple arguments passed to the subscriber.
--
function Messenger.publish( message, ... )
    for _, subscription in pairs( subscriptions ) do
        if subscription.message == message then
            subscription.callback( ... )
        end
    end
end

---
-- Registers a callback belonging to a certain subscriber.
-- @tparam  string   message  The message to listen for.
-- @tparam  function callback The function to call once the message is published.
-- @treturn number            The index pointing to the subscription.
--
function Messenger.observe( message, callback )
    index = index + 1
    subscriptions[index] = { message = message, callback = callback }
    return index
end

---
-- Removes a subscription based on its index.
-- @tparam number index The index of the subscription to remove.
--
function Messenger.remove( nindex )
    subscriptions[nindex] = nil
end

return Messenger
