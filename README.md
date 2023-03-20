# mfa_sh-ll

```powershell
Invoke-MFAEnterPSSession -ComputerName "DCSERVER01" -Credential (Get-Credential)
```

### Video of version 1.0 in use
https://youtu.be/8I5w7onWPr0



### TODO: Version 1.01
> Rename repository to something less obscure. ****Fixxed - 20.03.2023** **   
> Make the recipient phone number dynamic based on the user's Azure AD account.   

I need to modify the Azure Function to accept the user's email address as input and use the Microsoft Graph API to fetch the associated phone number.  

  
1. Register a new application in Azure AD:  
  
2. Grant the necessary API permissions:  
  
3. Obtain the client ID, tenant ID, and client secret:

> Edit Azure Function to fetch the user's phone number from Azure AD using the Microsoft Graph API:

1. Install the required npm packages:

+ In the Kudu console, navigate to the "site/wwwroot" folder.
+ Run npm install @azure/ms-rest-nodeauth @azure/ms-rest-js @microsoft/microsoft-graph-client --save  .

2. Update the index.js file in the "RequestMFAOTP" function:

```javascript
const {Twilio} = require('twilio');
const {MSRestAzure, InteractiveLogin} = require('@azure/ms-rest-nodeauth');
const {GraphRbacManagementClient} = require('@azure/graph');
const {Client: GraphClient} = require('@microsoft/microsoft-graph-client');

module.exports = async function (context, req) {
    const userEmail = req.query.email;

    if (!userEmail) {
        context.res = {
            status: 400,
            body: 'Missing email parameter'
        };
        return;
    }

    const clientId = process.env.AZURE_AD_CLIENT_ID;
    const clientSecret = process.env.AZURE_AD_CLIENT_SECRET;
    const tenantId = process.env.AZURE_AD_TENANT_ID;

    try {
        const credentials = await MSRestAzure.loginWithServicePrincipalSecret(clientId, clientSecret, tenantId);
        const graphClient = GraphClient.initWithMiddleware({
            authProvider: {
                getAccessToken: async () => credentials.tokenCache._entries[0].accessToken
            }
        });

        const user = await graphClient.api(`/users/${userEmail}`).get();
        const recipientPhone = user.mobilePhone;

        if (!recipientPhone) {
            context.res = {
                status: 404,
                body: 'Phone number not found for the specified user'
            };
            return;
        }

        const otp = generateOTP();

        const accountSid = process.env.TWILIO_ACCOUNT_SID;
        const authToken = process.env.TWILIO_AUTH_TOKEN;
        const twilioPhone = process.env.TWILIO_PHONE_NUMBER;

        const twilioClient = new Twilio(accountSid, authToken);

        const message = await twilioClient.messages.create({
            body: `Your OTP is: ${otp}`,
            from: twilioPhone,
            to: recipientPhone
        });
        
        
        context.res = {
            status: 200,
            body: {otp}
        };
    } catch (error) {
        context.res = {
            status: 500,
            body: `Error: ${error.message}`
        };
    }
};

function generateOTP() {
    return Math.floor(100000 + Math.random() * 900000);
}
```

3. Update the Application settings in the Azure Function App:

+ In the Azure portal, open your Function App, and go to the "Configuration" tab.
+ Click on the "Application settings" section, and add the following new entries:
  + AZURE_AD_CLIENT_ID: Your Azure AD App client ID
  + AZURE_AD_CLIENT_SECRET: Your Azure AD App client secret
  + AZURE_AD_TENANT_ID: Your Azure AD tenant ID
+ Click "Save" to apply the changes.  
  
  

Now the Azure Function expects an email parameter, which should be the user's email address. The function will fetch the associated phone number from Azure AD and send the OTP to that number.  
  
Modify the Request-MFAOTP function in the MFAEnterPSSession.psm1 file to include the user's email address as a parameter when calling the Azure Function:  
  
```powershell
function Request-MFAOTP ([string]$UserEmail) {
    # Replace this URL with the URL of your RequestMFAOTP Azure Function
    $functionUrl = 'https://your-function-app.azurewebsites.net/api/otp?code=your-function-key&email=' + $UserEmail

    try {
        $response = Invoke-WebRequest -Uri $functionUrl -Method Get
        $result = $response | ConvertFrom-Json

        if ($response.StatusCode -eq 200) {
            return $result.otp
        } else {
            throw "Error calling Azure Function: $($result.message)"
        }
    } catch {
        Write-Error $_.Exception.Message
        return $null
    }
}
```  
  
Now, when calling the Request-MFAOTP function, you need to provide the user's email address as an argument. The Azure Function will use the Microsoft Graph API to fetch the user's phone number from Azure AD and send the OTP to that number.
