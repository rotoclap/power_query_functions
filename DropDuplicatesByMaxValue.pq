let
    DropDuplicatesByMaxValue = (Table_ as table, GroupColumns as list, ColumnMax as text) as table =>
        let
            // Function
            #"GroupByMaxField" = Table.Group(
                Table_,
                GroupColumns,
                {
                    {
                        "__max_field",
                        each List.Max(Table.Column(_, ColumnMax)),
                        Type.TableColumn(Value.Type(Table_), ColumnMax)
                    }
                }
            ),
            #"Drop nonmax duplicates" = Table.Join(
                Table_,
                List.Combine({GroupColumns, {ColumnMax}}),
                #"GroupByMaxField",
                List.Combine({GroupColumns, {"__max_field"}})
            ),
            #"Drop temporary column" = Table.RemoveColumns(#"Drop nonmax duplicates", {"__max_field"})
        in
            #"Drop temporary column",
    // Documentation
    DropDuplicatesByMaxValueType = type function (Table_ as table, GroupColumns as list, ColumnMax as text) as list meta [
        Documentation.Name = "DropDuplicatesByMaxValue",
        Documentation.LongDescription = "Group <Table_> by <GroupColumns> names list, get max value of <ColumnMax>
column and return from the original <Table_> only the row where the
<GroupColumns> and max value of <ColumnMax> are present.
",
        Documentation.Examples = {
            [
                Description = "Example description",
                Code = "table_ = Table.FromRecords({
    [ID = 1, Name = ""ServerA"", Domain = ""EMEA"", LastLogon=""2024-07-08""],
    [ID = 2, Name = ""ServerA"", Domain = ""AM"",LastLogon=""2024-07-05""],
    [ID = 3, Name = ""ServerB"", Domain = ""AP"", LastLogon=""2024-07-01""]
}),

no_dup_table = DropDuplicatesByMaxValue(table_, {""Name""}, ""LastLogon"")
",
                Result = "{
    [ID = 1, Name = ""ServerA"", Domain = ""EMEA"", LastLogon=""2024-07-08""],
    [ID = 3, Name = ""ServerB"", Domain = ""AP"", LastLogon=""2024-07-01""]
}"
            ]
        }
    ]
in
    Value.ReplaceType(DropDuplicatesByMaxValue, DropDuplicatesByMaxValueType)
