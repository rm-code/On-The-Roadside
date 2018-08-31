return {
    name = 'default',
    tileset = {
        -- Tiles by Rogue Yun released as CCO (http://www.bay12forums.com/smf/index.php?topic=144897.0)
        source = 'spritesheet.png',
        tiles = {
            width = 16,
            height = 16
        }
    },
    font = {
        width = 8,
        height = 16,
        charsets = {
            {
                -- LATIN BASIC
                -- 0020-007F (Excluded: 007F)
                --  !"# $%&' ()*+ ,-./ 0123 4567 89:; <=>? @ABC DEFG HIJK LMNO PQRS TUVW XYZ[ \]^_ `abc defg hijk lmno pqrs tuvw xyz{ |}
                source = 'imagefont_latin_basic.png',
                glyphs = [[ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~]]
            }
        }
    }
}
