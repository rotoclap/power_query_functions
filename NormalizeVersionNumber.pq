let
    NormalizeVersionNumber = (version as text, parts as number) as text =>
        let
            // Function
            version_parts = Text.Split(version, "."),
            nb_parts_missing = parts - List.Count(version_parts),
            normalized =
                if nb_parts_missing <= 0 then
                    Text.Combine(List.FirstN(version_parts, parts), ".")
                else
                    let
                        new_parts = List.Transform(List.Numbers(0, nb_parts_missing, 0), each Text.From(_)),
                        version_normalized = Text.Combine(List.Combine({version_parts, new_parts}), ".")
                    in
                        version_normalized
        in
            normalized,
    // Documentation
    NormalizeVersionNumberType = type function (
        version as (
            type text meta [
                Documentation.FieldCaption = "version",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"2.0.2"}
            ]
        ),
        parts as (
            type number meta [
                Documentation.FieldCaption = "parts",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {4}
            ]
        )
    ) as list meta [
        Documentation.Name = "NormalizeVersionNumber",
        Documentation.LongDescription = "Normalize a version number (xx.yyy.zzz) to a
            specified number of parts.",
        Documentation.Examples = {
            [
                Description = "Normalize version number with a fewer number of parts",
                Code = "NormalizeVersionNumber(""2.0.2"", 2)",
                Result = "2.0"
            ],
            [
                Description = "Normalize version number with larger number of parts",
                Code = "NormalizeVersionNumber(""2.0.2"", 4)",
                Result = "2.0.2.0"
            ]
        }
    ]
in
    Value.ReplaceType(NormalizeVersionNumber, NormalizeVersionNumberType)
