module Utils.Time exposing (formatDate)

import DateFormat as DF
import Time


formatDate : Time.Posix -> String
formatDate =
    DF.format
        [ DF.monthNameFull
        , DF.text " "
        , DF.dayOfMonthNumber
        , DF.text ", "
        , DF.yearNumber
        ]
        Time.utc
