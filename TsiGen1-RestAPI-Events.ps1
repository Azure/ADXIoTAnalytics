# ref: https://learn.microsoft.com/azure/time-series-insights/time-series-insights-authentication-and-authorization#application-registration

# Define Variables
$AppId = "redated-redacted-redacted-redacted-redacted"
$Secret = "~redacted~"
$TenantId = "redacted-redacted-redacted-redacted-redacted"
$Resource = "https://api.timeseries.azure.com/"
$TokenUri = "https://login.microsoftonline.com/$TenantID/oauth2/token/"
$Body     = "client_id=$AppId&client_secret=$Secret&resource=$Resource&grant_type=client_credentials"
$TokenResult = Invoke-RestMethod -Uri $TokenUri -Body $Body -Method "POST"
$token = $TokenResult.access_token

$headers = @{Authorization="Bearer $token"}
# Invoke-WebRequest -Method GET -Headers $headers -Uri 'https://api.timeseries.azure.com/environments?api-version=2016-12-12'
$Response = Invoke-WebRequest -Method POST -Headers $headers `
-Uri 'https://a563527c-3ac8-4cc8-8cfd-ac2633c0eb0e.env.timeseries.azure.com/events?api-version=2016-12-12' `
-Body '{
    "searchSpan": {
      "from": {
        "dateTime": "2023-10-05T15:41:00.000Z"
      },
      "to": {
        "dateTime": "2023-10-05T16:41:00.000Z"
      }
    },
    "take": 5,
  }'
$Response.Content
