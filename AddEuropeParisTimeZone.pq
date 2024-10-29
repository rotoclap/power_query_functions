let
    AddEuropeParisTimeZone = (value as any, ambiguous as logical) as any =>
        let
            // Function
            value_ =
                if Value.Is(value, type datetime) then
                    value
                else
                    let
                        valueUtc = DateTimeZone.ToUtc(value), valueUtcDate = DateTimeZone.RemoveZone(valueUtc)
                    in
                        valueUtcDate,
            valueYear = DateTime.ToText(value_, [Format = "yyyy"]),
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
            dstOff2 = DateTime.FromText(Date.ToText(lastSundayOfOctober, [Format = "yyyy-MM-dd"]) & " 02:00:00"),
            dstOff3 = DateTime.FromText(Date.ToText(lastSundayOfOctober, [Format = "yyyy-MM-dd"]) & " 03:00:00"),
            valueTZ =
                if value_ >= dstOff3 then
                    DateTime.AddZone(value_, 1, 0)
                else if value_ >= dstOff2 and value_ < dstOff3 then
                    if ambiguous then
                        DateTime.AddZone(value_, 2, 0)
                    else
                        DateTime.AddZone(value_, 1, 0)
                else if value_ >= dstOn3 and value_ < dstOff2 then
                    DateTime.AddZone(value_, 2, 0)
                else if value_ >= dstOn2 and value_ < dstOn3 then
                    null
                else
                    DateTime.AddZone(value_, 1, 0)
        in
            valueTZ,
    // Documentation
    AddEuropeParisTimeZoneType = type function (value as any, ambiguous as logical) as list meta [
        Documentation.Name = "AddEuropeParisTimeZone",
        Documentation.LongDescription = "Add a Europe/Paris timezone to a datetime or a datetimezone.
<ambiguous> parameter dictates how ambiguous time should be handled: if true, the time is DST (""+02:00""),
if false, the time is not DST (""+01:00"")
",
        Documentation.Examples = {
            [
                Description = "Adding Europe/Paris timezone to a column",
                Code = "table_ = Table.FromRecords({
    [LastLogon=""2024-01-01 12:00:00""],
    [LastLogon=""2024-07-01 12:00:00""],
    [LastLogon=""2024-12-01 12:00:00""]
}),

table_result = Table.AddColumn(table_, ""LastLogonTZ"", each AddEuropeParisTimeZone([LastLogon], true)
",
                Result = "{
    [LastLogon=""2024-01-01 12:00:00"", LastLogonTZ=""2024-01-01 12:00:00+01:00""],
    [LastLogon=""2024-07-01 12:00:00"", LastLogonTZ=""2024-07-01 12:00:00+02:00""],
    [LastLogon=""2024-12-01 12:00:00"", LastLogonTZ=""2024-12-01 12:00:00+01:00""]
}"
            ]
        }
    ]
in
    Value.ReplaceType(AddEuropeParisTimeZone, AddEuropeParisTimeZoneType)
