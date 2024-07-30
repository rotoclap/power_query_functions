let
    NormalizeVersionNumber = (
        version as text,
        parts as number, 
        optional separator as text) as text =>
    let
// Function
        separator_ = if separator = null then "." else separator,
        version_parts = Text.Split(version, separator_),
        nb_parts_missing = parts - List.Count(version_parts),
        normalized = if nb_parts_missing <= 0 then
                Text.Combine(List.FirstN(version_parts, parts), separator_)
            else
                let
                    new_parts = List.Transform(
                        List.Numbers(0, nb_parts_missing, 0),
                        each Text.From(_)
                    )
                in
                    Text.Combine(
                        List.Combine({version_parts, new_parts}), separator_)
    in
        normalized,

// Documentation
NormalizeVersionNumberType = type function
    (
        version as text, parts as number, optional separator as text
    ) as list meta
        [
            Documentation.Name = "NormalizeVersionNumber",
            Documentation.LongDescription = 
"Normalize a version number (xx.yyy.zzz) to a specified number of parts.
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
        {""version"", each ConvertVersionNumberToInteger([_], 3)}
    }
",
                    Result = 
"{
    [version = ""1.0.3""],
    [version = ""0.0.17""],
    [version = ""21.2.0""]
}"
                ]
            }
        ]
in
    Value.ReplaceType(NormalizeVersionNumber, NormalizeVersionNumberType)