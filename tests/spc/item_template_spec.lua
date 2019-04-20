describe( 'Item template spec', function()
    local modules;

    setup( function()
        modules = {
            require( 'res.data.items.Armor' ),
            require( 'res.data.items.weapons.Melee' ),
            require( 'res.data.items.weapons.Ranged' ),
            require( 'res.data.items.weapons.Thrown' ),
            require( 'res.data.items.Containers' ),
            require( 'res.data.items.Miscellaneous' )
        }
    end)

    it( 'makes sure all templates have the necessary item attributes', function()
        for _, templates in ipairs( modules ) do
            for _, template in ipairs( templates ) do
                assert.is.not_nil( template.id );
                assert.is.not_nil( template.idDesc );
                assert.is.not_nil( template.itemType );
                assert.is.not_nil( template.weight );
                assert.is.not_nil( template.volume );
                assert.is.not_nil( template.equippable );
                assert.is.not_nil( template.permanent, template.id );
            end
        end
    end)

    it( 'makes sure item IDs are unqiue', function()
        local ids = {};
        for _, templates in ipairs( modules ) do
            for _, template in ipairs( templates ) do
                assert.is_true( not ids[template.id] );
                ids[template.id] = true;
            end
        end
    end)

    it( 'makes sure item description IDs are unqiue', function()
        local ids = {};
        for _, templates in ipairs( modules ) do
            for _, template in ipairs( templates ) do
                assert.is_true( not ids[template.idDesc] );
                ids[template.idDesc] = true;
            end
        end
    end)

    it( 'makes sure the template has a valid item type', function()
        local ITEM_TYPES = require('src.constants.ITEM_TYPES')
        for _, templates in ipairs( modules ) do
            for _, template in ipairs( templates ) do
                local valid;
                for _, v in pairs( ITEM_TYPES ) do
                    if template.itemType == v then
                        valid = true;
                        break;
                    end
                end
                assert.is_true( valid );
            end
        end
    end)
end)
