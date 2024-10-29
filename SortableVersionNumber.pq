let
    SortableVersionNumber = (version as text) as text =>
        let
            // Function
            parts = Text.Split(version, "."),
            indexes = {1..List.Count(parts)},
            indexedParts = List.Zip({indexes, parts}),
            maxPartLength = List.Max(List.Transform(parts, each Text.Length(_))),
            paddedParts = List.Transform(
                indexedParts, each if _{0} = 1 then _{1} else Text.PadStart(_{1}, maxPartLength, "0")
            ),
            sortableValue = Text.Combine(paddedParts)
        in
            sortableValue,
    // Documentation
    SortableVersionNumberType = type function (
        version as (
            type text meta [
                Documentation.FieldCaption = "version",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"24.0.15.987"}
            ]
        )
    ) as list meta [
        Documentation.Name = "SortableVersionNumber",
        Documentation.LongDescription = "Transform a version number (xx.yyy.zzz) to a 
            sortable string",
        Documentation.Examples = {
            [
                Description = "Get a sortable version string",
                Code = "SortableVersionNumber(""24.0.15.987"")",
                Result = """24000015987"""
            ]
        }
    ]
in
    Value.ReplaceType(SortableVersionNumber, SortableVersionNumberType)
