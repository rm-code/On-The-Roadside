describe( 'Text file spec', function()
    local MODULE_PATH = 'res.text.%s'

    describe( 'for english locale', function()
        local file = require( string.format( MODULE_PATH, 'en_EN' ))

        it( 'makes sure all text lines have a unique key', function()
            local keys = {}
            for key, _ in pairs( file.strings ) do
                assert.is_not_true( keys[key], key )
                keys[key] = true
            end
        end)
    end)
end)
