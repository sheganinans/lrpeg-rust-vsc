let Prelude =
      https://prelude.dhall-lang.org/v21.1.0/package.dhall
        sha256:0fed19a88330e9a8a3fbe1e8442aa11d12e38da51eb12ba8bcb56f3c25d0854a

let list = Prelude.List

let Pat = { name : Text, match : Text }

let Include = { include : Text }

let include = \(include : Text) -> { include }

let include_list = list.map Text Include include

let pat =
      \(scope : Text) ->
      \(name : Text) ->
      \(match : Text) ->
        { name = "${scope}.${name}", match }

let comment = { name = "comment.line.lrpeg", begin = "//", end = "\$" }

let keyword =
      { patterns =
        [ pat "keyword" "keyword.lrpeg" "(WHITESPACE|XID_IDENTIFIER|DOT|EOI)" ]
      }

let ops =
      { name = "operators.lrpeg"
      , patterns =
        [ pat "entity.name.function" "operator.lrpeg" "(!|&|\\?|\\*|\\+|/|\\.)"
        ]
      }

let regex =
      { name = "regex.lrpeg"
      , patterns =
        [ pat "string.quoted.double" "regex.lrpeg" "re#([^#\\\\]|\\\\.)*#" ]
      }

let strings =
      { name = "string.quoted.double.lrpeg"
      , patterns =
          list.map
            Text
            Pat
            (pat "string.quoted.double" "string.lrpeg")
            [ "\"([^\"\\\\]|\\\\.)*\"", "'([^'\\\\]|\\\\.)*'" ]
      }

let id_pat = "[\\p{Letter}_]+"

let id =
      { name = "variable.id.lrpeg"
      , patterns = [ pat "variable" "id.lrpeg" id_pat ]
      }

let defn_inner =
      { name = "keyword.control.expr.lrpeg"
      , begin = "<-"
      , end = ";"
      , patterns =
        [ include "#regex"
        , include "#keyword"
        , include "#id"
        , include "#comment"
        , include "#strings"
        , include "#ops"
        ]
      }

in  { name = "lrpeg"
    , scopeName = "source.lrpeg"
    , patterns = include_list [ "#id", "#defn_inner", "#comment" ]
    , repository = { comment, ops, strings, regex, defn_inner, id, keyword }
    }
