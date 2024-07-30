let
    ConvertVersionNumberToInteger = (
        version as text, optional separator as text) as number =>
    let
// Function
        separator_ = if separator = null then "." else separator,
        parts = Text.Split(version, separator_),
        maxPadLength = List.Max(List.Transform(parts, each Text.Length(_))),
        paddedParts = List.Transform(
            parts, each Text.PadStart(_, maxPadLength, "0")
        )
    in
        Int64.From(Text.Combine(paddedParts)),

// Documentation
ConvertVersionNumberToIntegerType = type function
    (
        version as text, optional separator as text
    ) as list meta
        [
            Documentation.Name = "ConvertVersionNumberToInteger",
            Documentation.LongDescription = 
"Transform a version number (xx.yyy.zzz) to an integer
",
            Documentation.Examples = {
                [
                    Description = "Example description",
                    Code = 
"table_ = Table.FromRecords({
    [version = ""1.0.3.25""],
    [version = ""0.0.17.1""],
    [version = ""21.2""]
}),

table2_ = Table.TransformColumns(
    table_,
    {
        {""version"", each ConvertVersionNumberToInteger([_], ""."")}
    }
",
                    Result = 
"{
    [version = 1000325],
    [version = 1701],
    [version = 21020000]
}"
                ]
            }
        ]
in
    Value.ReplaceType(
        ConvertVersionNumberToInteger, ConvertVersionNumberToIntegerType)