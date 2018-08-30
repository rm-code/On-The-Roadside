---
-- @module MessageQueue
--

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MessageQueue = {}

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local messages = {}

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Enqueues a new message.
-- @tparam string msg The text to display.
-- @tparam string type The type of message (INFO, IMPORTANT, WARNING, DANGER).
--
function MessageQueue.enqueue( msg, type )
    messages[#messages+1] = { text = msg, type = type, count = 1 }
end

---
-- Removes the next message from the queue.
--
function MessageQueue.dequeue()
    return table.remove( messages, 1 )
end

---
-- Clears the message queue of any old messages.
--
function MessageQueue.clear()
    messages = {}
end

---
-- Checks wether the message queue is empty.
-- @treturn boolean True if the queue is empty.
--
function MessageQueue.isEmpty()
    return #messages == 0
end

return MessageQueue
