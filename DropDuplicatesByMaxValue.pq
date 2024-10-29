let
    DropDuplicatesByMaxValue = (
        table_ as table, groupColumns as list, columnMax as text, optional maxFunc as function
    ) as table =>
        let
            // Function
            maxFunc = if maxFunc = null then List.Max else maxFunc,
            #"GroupByMaxField" = Table.Group(
                table_,
                groupColumns,
                {
                    {
                        "__max_field",
                        each maxFunc(Table.Column(_, columnMax)),
                        Type.TableColumn(Value.Type(table_), columnMax)
                    }
                }
            ),
            #"Drop nonmax duplicates" = Table.Join(
                table_,
                List.Combine({groupColumns, {columnMax}}),
                #"GroupByMaxField",
                List.Combine({groupColumns, {"__max_field"}})
            ),
            #"Drop temporary column" = Table.RemoveColumns(#"Drop nonmax duplicates", {"__max_field"})
        in
            #"Drop temporary column",
    // Documentation
    DropDuplicatesByMaxValueType = type function (
        table_ as (
            type table meta [
                Documentation.FieldCaption = "table_",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {}
            ]
        ),
        groupColumns as (
            type list meta [
                Documentation.FieldCaption = "groupColumns",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"{""col1"", ""col2""}"}
            ]
        ),
        columnMax as (
            type text meta [
                Documentation.FieldCaption = "columnMax",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"columnMax"}
            ]
        ),
        optional maxFunc as (
            type function meta [
                Documentation.FieldCaption = "maxFunc",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"List.Max"}
            ]
        )
    ) as list meta [
        Documentation.Name = "DropDuplicatesByMaxValue",
        Documentation.LongDescription = "Performs a groupBy on a table <table_> based on
            a list of columns <groupColumns>, then returns a table in which there is
            only, for each group, the rows containing the maximum value of the specified
            column <columnMax>. An optional function <maxFunc> for calculating the
            maximum value can be used. If <maxFunc> is null, the `List.Max` function
            will be used.",
        Documentation.Examples = {
            [
                Description = "Drop duplicate server entry, keeping the most recent
                    logon infos",
                Code = "table_ = Table.FromRecords({
    [ID = 1, Name = ""ServerA"", Domain = ""AAAA"", LastLogon=""2024-07-08""],
    [ID = 2, Name = ""ServerA"", Domain = ""BBBB"", LastLogon=""2024-07-05""],
    [ID = 3, Name = ""ServerB"", Domain = ""CCCC"", LastLogon=""2024-07-01""]
}),

no_dup_table = DropDuplicatesByMaxValue(table_, {""Name""}, ""LastLogon"")",
                Result = "{
    [ID = 1, Name = ""ServerA"", Domain = ""AAAA"", LastLogon=""2024-07-08""],
    [ID = 3, Name = ""ServerB"", Domain = ""CCCC"", LastLogon=""2024-07-01""]
}"
            ]
        }
    ]
in
    Value.ReplaceType(DropDuplicatesByMaxValue, DropDuplicatesByMaxValueType)
