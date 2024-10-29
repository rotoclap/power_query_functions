let
    MaxVersionNumber = (versions as list) as text =>
        let
            // Function
            versions2 = List.RemoveMatchingItems(versions, {"", null}),
            sortedVersions = List.Sort(
                versions2,
                (versionL, versionR) =>
                    let
                        vlList = List.Transform(Text.Split(versionL, "."), each Number.From(_)),
                        vrList = List.Transform(Text.Split(versionR, "."), each Number.From(_)),
                        parts = List.Count(vlList),
                        vRanked = List.Zip({vlList, vrList}),
                        vSortByRank = List.Transform(vRanked, each if _{0} < _{1} then -1 else if _{0} > _{1} then
                            1
                        else
                            0
                        ),
                        vSortResultWithoutZero = List.RemoveMatchingItems(vSortByRank, {0}),
                        result = if List.Count(vSortResultWithoutZero) = 0 then 0 else vSortResultWithoutZero{0}
                    in
                        result
            )
        in
            List.Last(sortedVersions),
    // Documentation
    MaxVersionNumberType = type function (
        versions as (
            type text meta [
                Documentation.FieldCaption = "List of versions numbers",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"{""21.1.2.1"", ""24.5.2.0"", ""22.0.1.1""}"}
            ]
        )
    ) as text meta [
        Documentation.Name = "MaxVersionNumber",
        Documentation.LongDescription = "Return the greater version number. All version numbers in the list must have the same number of parts and each part must be separated by `.`
",
        Documentation.Examples = {
            [
                Description = "Get the greater version number in a list",
                Code = "MaxVersionNumber({""21.1.2.1"", ""24.5.2.0"", ""22.0.1.1""})",
                Result = "24.5.2.0"
            ]
        }
    ]
in
    Value.ReplaceType(MaxVersionNumber, MaxVersionNumberType)
