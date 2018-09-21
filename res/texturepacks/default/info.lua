return {
    name = 'default',
    tileset = {
        -- Based on "Simple Mood" tileset by Rogue Yun released as CCO
        -- http://www.bay12forums.com/smf/index.php?topic=144897.0
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
            },
            {
                -- LATIN-1
                -- 00A0-00FF (Excluded: 00A0, 00AD)
                -- ¡¢£¤ ¥¦§¨ ©ª«¬ ®¯°± ²³´µ ¶·¸¹ º»¼½ ¾¿ÀÁ ÂÃÄÅ ÆÇÈÉ ÊËÌÍ ÎÏÐÑ ÒÓÔÕ Ö×ØÙ ÚÛÜÝ Þßàá âãäå æçèé êëìí îïðñ òóôõ ö÷øù úûüý þÿ
                source = 'imagefont_latin_1.png',
                glyphs = [[¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ]]
            }
        }
    }
}
