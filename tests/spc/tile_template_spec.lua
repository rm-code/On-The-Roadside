describe( 'Tile template spec', function()
    local FILE_PATH = 'res.data.Tiles'

    local templates

    setup( function()
        templates = require( FILE_PATH )
    end)

    it( 'makes sure all tile templates have an id', function()
        for i, template in ipairs( templates ) do
            assert.not_nil( template.id, string.format( "Index number %d.", i ))
        end
    end)

    it( 'makes sure all passable tiles have movement costs', function()
        for _, template in ipairs( templates ) do
            if template.passable then
                assert.not_nil( template.movementCost,        template.id )
                assert.not_nil( template.movementCost.stand,  template.id .. ' => stand'  )
                assert.not_nil( template.movementCost.crouch, template.id .. ' => crouch'  )
                assert.not_nil( template.movementCost.prone,  template.id .. ' => prone'  )
            end
        end
    end)

    it( 'makes sure all impassable tiles have no movement costs', function()
        for _, template in ipairs( templates ) do
            if not template.passable then
                assert.is_nil( template.movementCost,        template.id )
            end
        end
    end)
end)
