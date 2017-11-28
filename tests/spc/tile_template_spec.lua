describe( 'Tile template spec', function()
    local FILE_PATH = 'res.data.Tiles'

    local templates

    setup( function()
        templates = require( FILE_PATH )
    end)

    it( 'makes sure all tile templates have and id', function()
        for i, template in ipairs( templates ) do
            assert.is.truthy( template.id, string.format( "Index number %d.", i ))
        end
    end)

    it( 'makes sure all passable tiles have movement costs', function()
        for _, template in ipairs( templates ) do
            if template.passable then
                assert.is.truthy( template.movementCost,        template.id )
                assert.is.truthy( template.movementCost.stand,  template.id )
                assert.is.truthy( template.movementCost.crouch, template.id )
                assert.is.truthy( template.movementCost.prone,  template.id )
            end
        end
    end)

    it( 'makes sure all impassable tiles have no movement costs', function()
        for _, template in ipairs( templates ) do
            if not template.passable then
                assert.is.falsy( template.movementCost,        template.id )
            end
        end
    end)
end)
