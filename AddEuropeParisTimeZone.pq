let
    AddEuropeParisTimeZone = (value as any, ambiguous as logical) as any =>
        let
            result =
            // Calculation for a datetime value
            if Value.Is(value, type datetime) then
                let
                    valueYear = DateTime.ToText(value, [Format = "yyyy"]),
                    march31 = Date.FromText(valueYear & "-03-31"),
                    october31 = Date.FromText(valueYear & "-10-31"),
                    lastSundayOfMarch =
                        if Date.DayOfWeek(march31, Day.Monday) = 6 then
                            march31
                        else
                            Date.AddDays(march31, -Date.DayOfWeek(march31, Day.Monday) - 1),
                    lastSundayOfOctober =
                        if Date.DayOfWeek(october31, Day.Monday) = 6 then
                            october31
                        else
                            Date.AddDays(october31, -Date.DayOfWeek(october31, Day.Monday) - 1),
                    dstOn2 = DateTime.FromText(Date.ToText(lastSundayOfMarch, [Format = "yyyy-MM-dd"]) & " 02:00:00"),
                    dstOn3 = DateTime.FromText(Date.ToText(lastSundayOfMarch, [Format = "yyyy-MM-dd"]) & " 03:00:00"),
                    dstOff2 = DateTime.FromText(
                        Date.ToText(lastSundayOfOctober, [Format = "yyyy-MM-dd"]) & " 02:00:00"
                    ),
                    dstOff3 = DateTime.FromText(
                        Date.ToText(lastSundayOfOctober, [Format = "yyyy-MM-dd"]) & " 03:00:00"
                    ),
                    valueWithTZ =
                        if value >= dstOff3 then
                            DateTime.AddZone(value, 1, 0)
                        else if value >= dstOff2 and value < dstOff3 then
                            if ambiguous then
                                DateTime.AddZone(value, 2, 0)
                            else
                                DateTime.AddZone(value, 1, 0)
                        else if value >= dstOn3 and value < dstOff2 then
                            DateTime.AddZone(value, 2, 0)
                        else if value >= dstOn2 and value < dstOn3 then
                            null
                        else
                            DateTime.AddZone(value, 1, 0)
                in
                    valueWithTZ
                // Calculation for a datetimezone value
            else if Value.Is(value, type datetimezone) then
                let
                    valueUtc = DateTimeZone.ToUtc(value),
                    valueYear = DateTimeZone.ToText(valueUtc, [Format = "yyyy"]),
                    march31 = Date.FromText(valueYear & "-03-31"),
                    october31 = Date.FromText(valueYear & "-10-31"),
                    lastSundayOfMarch =
                        if Date.DayOfWeek(march31, Day.Monday) = 6 then
                            march31
                        else
                            Date.AddDays(march31, -Date.DayOfWeek(march31, Day.Monday) - 1),
                    lastSundayOfOctober =
                        if Date.DayOfWeek(october31, Day.Monday) = 6 then
                            october31
                        else
                            Date.AddDays(october31, -Date.DayOfWeek(october31, Day.Monday) - 1),
                    dstOnUtc = DateTimeZone.FromText(
                        Date.ToText(lastSundayOfMarch, [Format = "yyyy-MM-dd"]) & " 01:00:00+00:00"
                    ),
                    dstOffUtc = DateTimeZone.FromText(
                        Date.ToText(lastSundayOfOctober, [Format = "yyyy-MM-dd"]) & " 01:00:00+00:00"
                    ),
                    valueSwitchedTZ =
                        if valueUtc >= dstOnUtc and valueUtc < dstOffUtc then
                            DateTimeZone.SwitchZone(value, 2, 0)
                        else
                            DateTimeZone.SwitchZone(value, 1, 0)
                in
                    valueSwitchedTZ
            else
                null
        in
            result,
    // Documentation
    AddEuropeParisTimeZoneType = type function (
        value as (
            type any meta [
                Documentation.FieldCaption = "value",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"2024-01-01 15:00:00"}
            ]
        ),
        ambiguous as (
            type logical meta [
                Documentation.FieldCaption = "ambiguous",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"true", "false"}
            ]
        )
    ) as list meta [
        Documentation.Name = "AddEuropeParisTimeZone",
        Documentation.LongDescription = "Add a Europe/Paris timezone to a datetime or 
            a datetimezone. <ambiguous> parameter dictates how ambiguous datetime should
            be handled: if true, the time is DST (""+02:00""), if false, the time is not
            (""+01:00"")",
        Documentation.Examples = {
            [
                Description = "Adding Europe/Paris timezone to a datetime",
                Code = "AddEuropeParisTimeZone(DateTime.FromText(""2024-01-01 12:00:00""), false)",
                Result = "#datetimezone(2024, 01, 01, 12, 0, 0, 1, 0)"
            ],
            [
                Description = "Adding Europe/Paris timezone to an ambiguous datetime. 
                <ambiguous> parameter is true, so the result has a +01:00 timezone",
                Code = "AddEuropeParisTimeZone(DateTime.FromText(""2024-10-27 02:30:00""), true)",
                Result = "#datetimezone(2024, 10, 27, 2, 30, 0, 1, 0)"
            ],
            [
                Description = "Switching a datetimezone to Europe/Paris timezone.",
                Code = "AddEuropeParisTimeZone(DateTimeZone.FromText(""2024-10-29 15:00:00+05:00""), true)",
                Result = "#datetimezone(2024, 10, 29, 11, 00, 0, 1, 0)"
            ]
        }
    ]
in
    Value.ReplaceType(AddEuropeParisTimeZone, AddEuropeParisTimeZoneType)
