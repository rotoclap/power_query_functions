let
    DropDuplicatesByMaxValue = (table_ as table, groupColumns as list, columnMax as text) as table =>
        let
            // Function
            #"GroupByMaxField" = Table.Group(
                table_,
                groupColumns,
                {
                    {
                        "__max_field",
                        each List.Max(Table.Column(_, columnMax)),
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
        )
    ) as list meta [
        Documentation.Name = "DropDuplicatesByMaxValue",
        Documentation.LongDescription = "Group <table_> by <groupColumns> names list,
            get max value of <columnMax> column and return from the original <table_>
            only the row where the <groupColumns> and max value of <columnMax> are
            present.",
        Documentation.Examples = {
            [
                Description = "Example description",
                Code = "table_ = Table.FromRecords({
    [ID = 1, Name = ""ServerA"", Domain = ""AAAA"", LastLogon=""2024-07-08""],
    [ID = 2, Name = ""ServerA"", Domain = ""BBBB"",LastLogon=""2024-07-05""],
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
