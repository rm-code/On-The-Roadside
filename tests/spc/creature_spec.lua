describe( 'Creature template spec', function()
    local FILE_PATH   = 'res/data/creatures/bodies/';

    local function getDirectoryItems( dir )
        local i, t = 0, {};
        local pfile = io.popen( 'ls "'..dir..'"' );
        for filename in pfile:lines() do
            local fn, fe = filename:match( '^(.+)%.(.+)$' );
            if fn and fe then
                i = i + 1;
                t[i] = { name = fn, extension = fe };
            end
        end
        pfile:close();
        return t;
    end

    describe( 'for all creature definitions', function()
        local fileNames = getDirectoryItems( FILE_PATH );

        local creatureTemplates = {};
        local bodyPartTemplates = {};
        for _, file in ipairs( fileNames ) do
            if file.extension == 'lua' then
                local creature = require( FILE_PATH .. file.name );
                bodyPartTemplates[creature.id] = {};
                -- Create template library for this creature.
                for _, sub in ipairs( creature ) do
                    bodyPartTemplates[creature.id][sub.id] = sub;
                end
            end
        end

        it( 'makes sure all layout files have a corresponding template file', function()
            for id, _ in pairs( creatureTemplates ) do
                assert.is_true( bodyPartTemplates[id] ~= nil );
            end
        end)

        it( 'makes sure all nodes have a corresponding template file', function()
            for id, layout in pairs( creatureTemplates ) do
                for _, node in pairs( layout.nodes ) do
                    assert.is_true( bodyPartTemplates[id][node] ~= nil,
                        string.format( "Node %s of creature %s doesn't have a template file.", node, id ));
                end
            end
        end)

        it( 'makes sure all templates are used at least once', function()
            for id, layout in pairs( creatureTemplates ) do
                for tid, _ in pairs( bodyPartTemplates[id] ) do
                    local check = false;
                    for _, node in pairs( layout.nodes ) do
                        if tid == node then
                            check = true;
                            break;
                        end
                    end
                    assert.is_true( check,
                        string.format( "Template %s of creature %s isn't used and can be removed.", tid, id ));
                end
            end
        end)
    end)
end)
