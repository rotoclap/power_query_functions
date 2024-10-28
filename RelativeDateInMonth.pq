let
    RelativeDateInMonth = (
        value as text) as any =>
    let
// Function
        positionRef = {
            [name="first", abbr="1st", value=0],
            [name="second", abbr="2nd", value=1],
            [name="third", abbr="3rd", value=2],
            [name="fourth", abbr="4th", value=3],
            [name="fifth", abbr="5th", value=4],
            [name="last", abbr="last", value=-1]
        },
        weekdayRef = {
            [name="monday", abbr="mon", value=0],
            [name="tuesday", abbr="tue", value=1],
            [name="wednesday", abbr="wed", value=2],
            [name="thursday", abbr="thu", value=3],
            [name="friday", abbr="fri", value=4],
            [name="saturday", abbr="sat", value=5],
            [name="sunday", abbr="sun", value=6]
        },
        monthRef = {
            [name="january", abbr="jan", value=1],
            [name="february", abbr="feb", value=2],
            [name="march", abbr="mar", value=3],
            [name="april", abbr="apr", value=4],
            [name="may", abbr="may", value=5],
            [name="june", abbr="jun", value=6],
            [name="july", abbr="jul", value=7],
            [name="august", abbr="aug", value=8],
            [name="september", abbr="sep", value=9],
            [name="october", abbr="oct", value=10],
            [name="november", abbr="nov", value=11],
            [name="december", abbr="dec", value=12]
        },
        valueList = Text.Split(value, " "),
        valuePosition = Text.Lower(valueList{0}),
        valueWeekday = Text.Lower(valueList{1}),
        valueMonth = Text.Lower(valueList{2}),
        year = if List.Count(valueList) = 4 then
                Number.FromText(valueList{3})
            else
                Date.Year(DateTime.Date(DateTime.FixedLocalNow())),
        position = List.Select(
            positionRef,
            each (
                _[name] = valuePosition or _[abbr] = valuePosition
            )
        ){0}[value],
        weekday = List.Select(
            weekdayRef,
            each(
                _[name] = valueWeekday or _[abbr] = valueWeekday
            )
        ){0}[value],
        month = List.Select(
            monthRef,
            each(
                _[name] = valueMonth or _[abbr] = valueMonth
            )
        ){0}[value],
        startDate = #date(year, month, 1),
        endDate = Date.EndOfMonth(startDate),
        monthDates =  List.Generate(() => startDate, each _ <= endDate, each Date.AddDays(_, 1)),
        weekdayDates = List.Select(monthDates, each Date.DayOfWeek(_, Day.Monday) = weekday),

        return = if position < 0 then
                List.Last(weekdayDates)
            else 
                try weekdayDates{position} otherwise null
    in
        return,

// Documentation
RelativeDateInMonthType = type function
    (
        value as (type text meta 
            [
                Documentation.FieldCaption = "The keywords defining the relative date",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"third tuesday september 2023"}
            ]
        )
    ) as list meta
        [
            Documentation.Name = "RelativeDateInMonth",
            Documentation.LongDescription = 
"Return a relative weekday in a month. The value argument must be a string of 3 or 4 keywords separated by a whitespace, like
""last monday march"" or ""2nd fri sep 2023"". For the first keyword, you can use 'first | second | third | fourth | fifth' or
their abbreviation '1st | 2nd | 3rd | 4th | 5th', or 'last'. For the weekday and month keyword, you can use the full name or
their abbreviation as returned Format='ddd' or Format='mmm' (with culture='en-US')."
            ,

            Documentation.Examples = {
                [
                    Description = "Return the first Monday of December 2023",
                    Code = "RelativeDateInMonth(""first monday december 2023"")",
                    Result = "#date(2023, 12, 4)"
                ],
                [
                    Description = "Return the last Monday of March of the current year (2024)",
                    Code = "RelativeDateInMonth(""last monday march"")",
                    Result = "#date(2024, 3, 25)"
                ],
                [
                    Description = "Return the fifth Wednesday of October 2024, using abbreviations",
                    Code = "RelativeDateInMonth(""5th wed oct 2024"")",
                    Result = "#date(2024, 10, 30)"
                ]
            }
        ]
in
    Value.ReplaceType(RelativeDateInMonth, RelativeDateInMonthType)
