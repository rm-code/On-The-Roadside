describe( 'Inventory class', function()
    local ITEM_TYPES = require( 'src.constants.ItemTypes' );
    local Inventory = require( 'src.inventory.Inventory' );
    local Item = require( 'src.items.Item' );

    describe( 'when creating a new Inventory', function()
        local inventory = Inventory.new();

        it( 'should be empty', function()
            assert.is_true( inventory.isEmpty() );
        end)
    end)

    describe( 'when adding a new item', function()
        local inventory = Inventory.new();
        local item = Item.new({ id = 'id_dummy', itemType = 'Dummy' });

        it( 'should return true if the item was added successfully', function()
            assert.is_true( inventory:addItem( item ));
        end)

        it( 'should no longer be empty', function()
            assert.is_false( inventory.isEmpty() );
        end)
    end)

    describe( 'when removing an item', function()
        local inventory = Inventory.new();
        local item = Item.new({ id = 'id_dummy', itemType = 'Dummy' });
        inventory:addItem( item );

        it( 'should return true if the item has been removed successfully', function()
            assert.is_true( inventory:removeItem( item ));
        end)

        it( 'should be empty when all items have been removed', function()
            assert.is_true( inventory:isEmpty() );
        end)

        it( 'should return false if the removal of an item has failed', function()
            assert.is_false( inventory:removeItem( 'fail' ));
        end)

        it( 'should be able to get and remove a specific item type', function()
            inventory:addItem( item );
            assert.is_false( inventory:isEmpty() );
            assert.is_true( inventory:getAndRemoveItem( 'Dummy' ):getItemType() == 'Dummy' );
            assert.is_true( inventory:isEmpty() );
        end)
    end)

    describe( 'when accessing items', function()
        local inventory = Inventory.new();
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.WEAPON   }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.BAG      }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.HEADGEAR }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.GLOVES   }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.JACKET   }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.SHIRT    }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.TROUSERS }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.FOOTWEAR }));

        it( 'should find items of a specific type', function()
            assert.is_true( inventory:containsItemType( ITEM_TYPES.WEAPON ));
        end)

        it( 'should be able to return specific items', function()
            assert.is_true( inventory:getWeapon():getItemType() == ITEM_TYPES.WEAPON );
            assert.is_true( inventory:getBackpack():getItemType() == ITEM_TYPES.BAG );
            assert.is_true( inventory:getItem( ITEM_TYPES.HEADGEAR ):getItemType() == ITEM_TYPES.HEADGEAR );
            assert.is_true( inventory:getItem( ITEM_TYPES.GLOVES   ):getItemType() == ITEM_TYPES.GLOVES   );
            assert.is_true( inventory:getItem( ITEM_TYPES.JACKET   ):getItemType() == ITEM_TYPES.JACKET   );
            assert.is_true( inventory:getItem( ITEM_TYPES.SHIRT    ):getItemType() == ITEM_TYPES.SHIRT    );
            assert.is_true( inventory:getItem( ITEM_TYPES.TROUSERS ):getItemType() == ITEM_TYPES.TROUSERS );
            assert.is_true( inventory:getItem( ITEM_TYPES.FOOTWEAR ):getItemType() == ITEM_TYPES.FOOTWEAR );
        end)
    end)
end)
