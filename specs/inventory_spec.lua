describe( 'Inventory class', function()
    local ITEM_TYPES = require( 'src.constants.ItemTypes' );
    local Inventory = require( 'src.inventory.Inventory' );
    local Item = require( 'src.items.Item' );

    describe( 'when creating a new Inventory', function()
        local inventory;

        describe( 'when created without parameters', function()
            inventory = Inventory.new()
            it( 'should have a weight limit of 50', function()
                assert.is_true( inventory:getWeightLimit() == 50 );
            end)
        end)

        describe( 'when created with parameters', function()
            inventory = Inventory.new( 20 )
            it( 'should have the specified weight limit', function()
                assert.is_true( inventory:getWeightLimit() == 20 );
            end)
        end)

        it( 'should be empty', function()
            assert.is_true( inventory:isEmpty() );
        end)
    end)

    describe( 'when adding a new item', function()
        local inventory = Inventory.new();
        local item = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2 });

        it( 'should return true if the item was added successfully', function()
            assert.is_true( inventory:addItem( item ));
        end)

        it( 'should no longer be empty', function()
            assert.is_false( inventory.isEmpty() );
        end)

    end)

    describe( 'when adding a stackable item', function()
        local inventory = Inventory.new();
        local item = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true });
        local stack;

        it( 'should create an ItemStack for the new item', function()
            assert.is_true( inventory:addItem( item ));
            stack = inventory:getItems()[1];
            assert.is_not_nil( stack );
            assert.is_true( stack:instanceOf( 'ItemStack' ));
        end)
        it( 'should add items to an existing ItemStack if the IDs match', function()
            local newItem = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true });
            inventory:addItem( newItem );
            assert.is_true( #inventory:getItems() == 1 );
            assert.is_true( stack:getItemCount() == 2 );
        end)
    end)

    describe( 'when removing an unstackable item', function()
        local inventory = Inventory.new();
        local item = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = false });
        inventory:addItem( item );

        it( 'should return true if the item has been removed successfully', function()
            assert.is_true( inventory:removeItem( item ));
        end)
        it( 'should be empty when all items have been removed', function()
            assert.is_true( inventory:isEmpty() );
        end)
        it( 'should return false if the removal of an item has failed', function()
            local other = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = false });
            assert.is_false( inventory:removeItem( other ));
        end)
        it( 'should be able to get and remove a specific item type', function()
            inventory:addItem( item );
            assert.is_false( inventory:isEmpty() );
            assert.is_true( inventory:getAndRemoveItem( 'Dummy' ):getItemType() == 'Dummy' );
            assert.is_true( inventory:isEmpty() );
        end)
    end)

    describe( 'when removing a stackable item', function()
        local inventory = Inventory.new();
        local item = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true });
        inventory:addItem( item );

        it( 'should return true if the item has been removed successfully', function()
            assert.is_true( inventory:removeItem( item ));
        end)
        it( 'should be empty when all items have been removed', function()
            assert.is_true( inventory:isEmpty() );
        end)
        it( 'should return false if the removal of an item has failed', function()
            local other = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true });
            assert.is_false( inventory:removeItem( other ));
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
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.WEAPON,   weight = 2 }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.BAG,      weight = 2 }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.HEADGEAR, weight = 2 }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.GLOVES,   weight = 2 }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.JACKET,   weight = 2 }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.SHIRT,    weight = 2 }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.TROUSERS, weight = 2 }));
        inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.FOOTWEAR, weight = 2 }));

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

    describe( 'when being at full capacity', function()
        it( 'should fail when adding an item', function()
            local inventory = Inventory.new( 10 );
            inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.WEAPON, weight = 6 }));
            assert.is_false( inventory:addItem( Item.new({ id = 'id_dummy', itemType = ITEM_TYPES.BAG, weight = 6 })));
        end)
    end)
end)
