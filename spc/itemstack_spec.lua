describe( 'ItemStack class', function()
    local ItemStack = require( 'src.inventory.ItemStack' );
    local Item = require( 'src.items.Item' );

    describe( 'when creating a new ItemStack', function()
        describe( 'when created without parameters', function()
            it( 'should throw an error', function()
                assert.has_errors( function() ItemStack.new() end );
            end)
        end)

        describe( 'when created with parameters', function()
            it( 'should fail if parameter is not of type string', function()
                assert.has_errors( function() ItemStack.new( 123 ) end );
            end)

            local stack = ItemStack.new( 'id_dummy' );
            it( 'should have an id for items to add', function()
                assert.is_true( stack:getID() == 'id_dummy' );
            end)
        end)
    end)

    describe( 'when adding an Item', function()
        it( 'should fail if item ID does not fit the stack ID', function()
            local stack = ItemStack.new( 'id_dummy' );
            local item = Item.new({ id = 'id_not_dummy', itemType = 'Dummy', weight = 2, stackable = true });
            assert.has_errors( function() stack:addItem( item ) end );
        end)
        it( 'should return true if the item was added successfully', function()
            local stack = ItemStack.new( 'id_dummy' );
            local item = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true });
            assert.is_true( stack:addItem( item ));
        end)
        it( 'should update the item count correctly', function()
            local stack = ItemStack.new( 'id_dummy' );
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            assert.is_true( stack:getItemCount() == 1 );
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            assert.is_true( stack:getItemCount() == 2 );
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            assert.is_true( stack:getItemCount() == 3 );
        end)
    end)

    describe( 'when removing an Item', function()
        it( 'should return true if the item was removed successfully', function()
            local stack = ItemStack.new( 'id_dummy' );
            local item = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true });
            stack:addItem( item );
            assert.is_true( stack:removeItem( item ));
            assert.is_true( stack:isEmpty() );
        end)
        it( 'should update the item count correctly', function()
            local stack = ItemStack.new( 'id_dummy' );
            local item = Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true });
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            stack:addItem( item );
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            stack:removeItem( item );
            assert.is_true( stack:getItemCount() == 3 );
        end)
    end)

    describe( 'when calculating the weight', function()
        it( 'should use the weight of all items in the stack', function()
            local stack = ItemStack.new( 'id_dummy' );
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            assert.is_true( stack:getWeight() == 6 );
        end)
    end)

    describe( 'when splitting the stack', function()
        it( 'should create a new item stack with half the item count', function()
            local stack = ItemStack.new( 'id_dummy' );
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            stack:addItem( Item.new({ id = 'id_dummy', itemType = 'Dummy', weight = 2, stackable = true }));
            local nstack = stack:split();
            assert.is_not_nil( nstack );
            assert.is_true( nstack:instanceOf( 'ItemStack' ));
            assert.is_true(  stack:getItemCount() == 2 );
            assert.is_true( nstack:getItemCount() == 2 );
        end)
    end)
end)
