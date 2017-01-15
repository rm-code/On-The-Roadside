local Projectile = require( 'src.items.weapons.Projectile' );
local ProjectilePath = require( 'src.items.weapons.ProjectilePath' );
local Messenger = require( 'src.Messenger' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ThrownProjectileQueue = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new ThrownProjectileQueue.
-- @param character (Character)       The character who started the attack.
-- @param target    (Tile)            The target tile.
-- @return          (ThrownProjectileQueue) A new instance of the ThrownProjectileQueue class.
--
function ThrownProjectileQueue.new( character, target )
    local self = {};

    local projectiles = {};
    local index = 0;
    local weapon = character:getWeapon();

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Generates projectiles based on the weapons firing mode. The value is
    -- limited by the amount of rounds in the weapon's magazine. For each
    -- projectile an angle of derivation is calculated before it is placed in
    -- the queue.
    --
    function self:init()
        assert( weapon:getWeaponType() == 'Thrown', 'Expected a weapon of type Thrown.' );

        -- Thrown weapon is removed from the inventory.
        local success = character:getEquipment():removeItem( weapon );
        assert( success, "Couldn't remove the item from the character's equipment." );

        local tiles = ProjectilePath.calculate( character, target, weapon );
        local projectile = Projectile.new( character, tiles, weapon:getDamage(), weapon:getDamageType(), weapon:getEffects() );
        index = index + 1;
        projectiles[index] = projectile;

        -- Play sound.
        Messenger.publish( 'SOUND_ATTACK', weapon );
    end

    ---
    -- Spawns a new projectile after a certain delay defined by the weapon's
    -- rate of fire.
    --
    function self:update()
        return;
    end

    ---
    -- Removes a projectile from the table of active projectiles.
    -- @param id (number) The id of the projectile to remove.
    --
    function self:removeProjectile( id )
        projectiles[id] = nil;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Gets the table of projectiles which are active on the map.
    -- @return (table) A table containing the projectiles.
    function self:getProjectiles()
        return projectiles;
    end

    ---
    -- Checks if this ThrownProjectileQueue is done with all the projectiles.
    -- @return (boolean) True if it is done.
    --
    function self:isDone()
        local count = 0;
        for _, _ in pairs( projectiles ) do
            count = count + 1;
        end
        return count == 0;
    end

    return self;
end

return ThrownProjectileQueue;
