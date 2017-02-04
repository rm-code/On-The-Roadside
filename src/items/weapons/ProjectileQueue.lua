local Projectile = require( 'src.items.weapons.Projectile' );
local ProjectilePath = require( 'src.items.weapons.ProjectilePath' );
local Queue = require( 'src.util.Queue' );
local Messenger = require( 'src.Messenger' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ProjectileQueue = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new ProjectileQueue.
-- @param character (Character)       The character who started the attack.
-- @param target    (Tile)            The target tile.
-- @return          (ProjectileQueue) A new instance of the ProjectileQueue class.
--
function ProjectileQueue.new( character, target )
    local self = {};

    local ammoQueue = Queue.new();
    local shots;
    local projectiles = {};
    local index = 0;
    local timer = 0;
    local weapon = character:getWeapon();

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Removes a projectile from the queue and adds it to the table of active
    -- projectiles.
    --
    local function spawnProjectile()
        local round = ammoQueue:dequeue();

        local tiles = ProjectilePath.calculate( character, target, weapon, shots - ammoQueue:getSize() );
        local projectile = Projectile.new( character, tiles, weapon:getDamage(), round:getDamageType(), round:getEffects() );

        -- Play sound and remove the round from the magazine.
        Messenger.publish( 'SOUND_ATTACK', weapon );
        weapon:getMagazine():removeRound();

        -- Spawn projectiles for the spread shot.
        if round:getEffects():spreadsOnShot() then
            for _ = 1, round:getEffects():getPellets() do
                index = index + 1;
                local spreadTiles = ProjectilePath.calculate( character, target, weapon, shots - ammoQueue:getSize() );
                projectiles[index] = Projectile.new( character, spreadTiles, weapon:getDamage(), round:getDamageType(), round:getEffects() );
            end
            return;
        end

        -- Spawn default projectile.
        index = index + 1;
        projectiles[index] = projectile;
    end

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
        shots = math.min( weapon:getMagazine():getRounds(), weapon:getAttacks() );
        for i = 1, shots do
            ammoQueue:enqueue( weapon:getMagazine():getRound( i ));
        end
    end

    ---
    -- Spawns a new projectile after a certain delay defined by the weapon's
    -- rate of fire.
    --
    function self:update( dt )
        timer = timer - dt;
        if timer <= 0 and not ammoQueue.isEmpty() then
            spawnProjectile();
            timer = weapon:getFiringDelay();
        end
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
    -- Gets the character this attack was performed by.
    -- @return (Character) The character.
    --
    function self:getCharacter()
        return character;
    end

    ---
    -- Gets the table of projectiles which are active on the map.
    -- @return (table) A table containing the projectiles.
    function self:getProjectiles()
        return projectiles;
    end

    ---
    -- Checks if this ProjectileQueue is done with all the projectiles.
    -- @return (boolean) True if it is done.
    --
    function self:isDone()
        if not ammoQueue:isEmpty() then
            return false;
        end

        local count = 0;
        for _, _ in pairs( projectiles ) do
            count = count + 1;
        end
        return count == 0;
    end

    return self;
end

return ProjectileQueue;
