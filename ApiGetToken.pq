let
    ApiGetToken = (url as text, credentials as record, format as text) =>
        let
            headers = if format = "form" then
                    [
                        #"Content-Type" = "application/x-www-form-urlencoded",
                        Accept =  "application/json"
                    ]
                else if format = "json" then
                    [
                        #"Content-Type" = "application/json",
                        Accept =  "application/json"
                    ]
                else
                    [],
            postData = if format = "form" then
                    Text.ToBinary(Text.Combine(
                        List.Transform(
                            Record.FieldNames(credentials),
                            each _ & "=" & Uri.EscapeDataString(Record.Field(credentials, _))
                        ),
                        "&"
                    ))
                else if format = "json" then
                    Json.FromValue(credentials)
                else
                    "",
            response = Web.Contents(url, [Headers = headers, Content=postData]),
            data = Json.Document(response)
        in
            data,
    // Documentation
    ApiGetTokenType = type function (
        url as (
            type text meta [
                Documentation.FieldCaption = "url",
                Documentation.FieldDescription = "The endpoint returning the access token",
                Documentation.SampleValues = {"https://base_url/api/token"}
            ]
        ),
        credentials as (
            type record meta [
                Documentation.FieldCaption = "username",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"my_user"}
            ]
        ),
        format as (
            type text meta [
                Documentation.FieldCaption = "format",
                Documentation.FieldDescription = "",
                Documentation.SampleValues = {"`form` or `json`"}
            ]
        )
    ) as record meta [
        Documentation.Name = "ApiGetToken",
        Documentation.LongDescription = "Get an access token.",
        Documentation.Examples = {
            [
                Description = "Returns an access token for APIs using token bearer authentication.",
                Code = "ApiGetToken(""https://base_url/api/token"", [username = ""my_user"", password = ""my_password""], ""form"")",
                Result = "[
    refresh = ""eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.yyy.zzz"",
    access = ""eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.yyy.zzz"",
    user_id = 18
]"
            ]
        }
    ]
in
    Value.ReplaceType(ApiGetToken, ApiGetTokenType)
