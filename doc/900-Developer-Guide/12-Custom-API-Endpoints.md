# Developer Guide: Custom API-Endpoints

Starting with Icinga [PowerShell Framework v1.1.0](https://icinga.com/docs/windows/latest) plenty of features and functionality have been added for shipping data by using a REST-API. This Developer Guide will describe on how to write custom API endpoints by using the [PowerShell Framework v1.1.0](https://icinga.com/docs/windows/latest) and the [Icinga PowerShell REST-Api](https://icinga.com/docs/windows/latest/restapi/doc/01-Introduction/). In this example we will write a custom endpoint to simply provide a file list for a specific folder.

## File Structure

Like plugins, API endpoints can contain plenty of different files to keep the code clean. To ensure each module is identical and easier to maintain for users, we would advise the following file structure:

```text
module
  |_ apiendpoint.psd1
  |_ apiendpoint.psm1
  |_ lib
     |_ function1.psm1
     |_ function2.psm1
```

This will ensure these functions can be called separately from the endpoint itself and make re-using them a lot easier. In addition, it will help other developers to build dependencies based on your module and allow an easier re-usage of already existing components.

Additional required files within the `lib` folder can be included by using the `NestedModules` array within your `psd1` file. This will ensure these files are automatically loaded once a new PowerShell session is started.

## Creating A New Module

The best approach for creating a custom API endpoint is by creating an independent module which is installed in your PowerShell modules directly. This will ensure you are not overwriting your custom data with possible other module updates.

### Developer Tools

To get started easier, you can run this command to create the new module:

```powershell
New-IcingaForWindowsComponent -Name 'apitutorial' -ComponentType 'apiendpoint';
```

If you wish to create the module manually, please read on.

### Manual Creation

In this guide, we will assume the name of the module is `icinga-powershell-apitutorial`.

At first we will have to create a new module. Navigate to the PowerShell modules folder the Framework itself is installed to. In this tutorial we will assume the location is

```powershell
C:\Program Files\WindowsPowerShell\Modules
```

Now create a new folder with the name `icinga-powershell-apitutorial` and navigate into it.

As we require a `psm1` file which contains our code, we will create a new file with the name `icinga-powershell-apitutorial.psm1`. This will allow the PowerShell autoloader to load the module automatically.

**Note:** It could be possible, depending on your [execution policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6), that your module is not loaded properly. If this is the case, you can try to unblock the file by opening a PowerShell and use the `Unblock-File` Cmdlet

```powershell
Unblock-File -Path 'C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-apitutorial\icinga-powershell-apitutorial.psm1'
```

## Testing The Module

Once the module files are created and unblocked, we can start testing if the autoloader is properly working and our module is detected.

For this open the file `icinga-powershell-apitutorial.psm1` in your preferred editor and add the following code snippet

```powershell
function Test-MyIcingaAPITutorialCommand()
{
    Write-Host 'Module was loaded';
}
```

Now open a **new** PowerShell terminal or write `powershell` into an already open PowerShell prompt and execute the command `Test-MyIcingaAPITutorialCommand`.

If everything went properly, you should now read the output `Module was loaded` in our prompt. If not, you can try to import the module by using

```powershell
Import-Module 'C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-apitutorial\icinga-powershell-apitutorial.psm1';
```

inside your console prompt. After that try again to execute the command `Test-MyIcingaAPITutorialCommand` and check if it works this time. If not, you might check the naming of your module to ensure `folder name` and `.psm1 file name` is identical.

Once this is working, we can remove the function again as we no longer require it.

## Create A New API-Endpoint

Once everything is working properly we can create our starting function we later use to execute our API endpoint.

At first we create a new folder `lib` inside our module folder and inside the file `Invoke-IcingaAPITutorialRESTCall.psm1`. For naming guidelines we will have to use `Invoke-Icinga{0}RESTCall`. Replace `{0}` with a unique name describing shortly what your module is doing. The user will not require to use this function later and is only required internally and to have a better look on which function is providing REST endpoints.

So lets get started with the function

```powershell
function Invoke-IcingaAPITutorialRESTCall()
{
    # Our code belongs here
}
```

### Basic API Architecture

A developer using the REST-Api integration does not have to worry about anything regarding header fetching, URL encoding or similar. All data is parsed by the  [Icinga PowerShell REST-Api](https://icinga.com/docs/windows/latest/restapi/doc/01-Introduction/) and invoked to our function.

Our API endpoint will be called by a namespace, referring to our actual function executing the code.

### Writing Our Base-Skeleton

For our API endpoint we will start with `param()` to parse arguments to our endpoint which is `standardized`, and has to be followed. Otherwise the integration might not work.

```powershell
function Invoke-IcingaAPITutorialRESTCall()
{
    # Create our arguments the REST-Api daemon will use to parse the request
    param (
        [Hashtable]$Request    = @{ },
        [Hashtable]$Connection = @{ },
        $IcingaGlobals,
        [string]$ApiVersion    = $null
    );
}
```

#### Request Argument

The request argument provides a hashtable with all parsed content of the request to later work with. The following elements are available by default:

##### Method

The HTTP method being used for the request, like `GET`, `POST`, `DELETE` and so on

##### RequestPath

The request path is split into two hashtable entries: `FullPath` and `PathArray`. This tells you exactly which URL the user specified and allows you to build proper handling for different entry points of your endpoint.

For the path array, on index 0 you will always find the `version` and on index 1 `your endpoint alias`. Following this, possible additional path extensions in your module will always start on index 2.

##### Header

A hashtable containing all send headers by the client. If you require your client to send additional headers for certain tasks to work, you can check with this if the header is set with the correct value.

```powershell
Name                           Value
----                           -----
Upgrade-Insecure-Requests      1
User-Agent                     Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
Accept                         text/html,application/json
Host                           example.com:5668
Sec-Fetch-Dest                 document
Accept-Language                de,en-US;q=0.9,en;q=0.8
Connection                     keep-alive
Accept-Encoding                gzip, deflate, br
Sec-Fetch-Mode                 navigate
sec-ch-ua-mobile               ?0
X-CustomHeader                 Custom Content
```

##### RequestArguments

Of course we will also handle possible request arguments. This could either be used for filtering or to modify returned content depending on the input. An example could look like this:

```text
https://example.com:5668/v1/apitutorial?include=*psm1&exclude=*api*
```

```powershell
Name                           Value
----                           -----
include                        {*psm1}
exclude                        {*api*}
```

##### Body

The content send by the client in case a method is used to send data.

**Note**: The body argument is only available in case data is send. If the client is using `POST` and sending no data, the argument is not present.

##### FullRequest

This argument contains the full request string for possible troubleshooting and debugging.

```text
/v1/apitutorial?include=*psm1&exclude=*api*
```

##### ContentLength

This only applies to any request which can send data as body and tells you how many data was send. This part is moved from the header to this location for easier accessing.

#### Connection Argument

This argument is containing the connection details of the client including the TCP stream object. You only require this for sending data back to the client or for troubleshooting. In general you only have to parse this object to other functions without modifying it.

#### IcingaGlobals Argument

This argument contains all global data and content of the REST-Api background daemon. This will then come in handy to share data between API endpoints and to access some global configuration data.

### Sending Data to the Client

Now we are basically ready to process data. To do so, we will fetch the current folder content of our PowerShell module with `Get-ChildItem` and send this content to our client. For sending data to the client, we can use `Send-IcingaTCPClientMessage`. This Cmdlet will use a `Message` as `New-IcingaTCPClientRESTMessage` object which itself contains the `HTTPResponse` and our `ContentBody`. In addition to `Send-IcingaTCPClientMessage` we also have to specify the `Stream` to write to. The stream object is part of our `Connection` argument.

All content will be send as JSON encoded, so please ensure you are using a datatype which is convertible by `ConvertTo-Json`.

```powershell
function Invoke-IcingaAPITutorialRESTCall()
{
    # Create our arguments the REST-Api daemon will use to parse the request
    param (
        [Hashtable]$Request    = @{ },
        [Hashtable]$Connection = @{ },
        $IcingaGlobals,
        [string]$ApiVersion    = $null
    );

    # Fetch all file names within our module directory. We filter this to ensure we
    # do not have to handle all PSObjects, we our client message functionality will
    # try to resolve them. This could end up in an almost infinite loop
    $Content = Get-ChildItem -Path 'C:\Program Files\WindowsPowerShell\Modules\' -Recurse | Select-Object 'Name', 'FullName';

    # Send the response to the client as 200 "Ok" with out Directory body
    Send-IcingaTCPClientMessage -Message (
        New-IcingaTCPClientRESTMessage `
            -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.Ok) `
            -ContentBody $Content
    ) -Stream $Connection.Stream;
}
```

### Registering API-Endpoints

Now as we have written a basic function to fetch folder content and to send it back to our client, we will have to `register` our Cmdlet to the endpoint. For this we will open our `icinga-powershell-apitutorial.psm1` and add a `namespace` function which has to follow this naming guideline: `Register-IcingaRESTAPIEndpoint{0}`

Replace `{0}` with the name you have chosen for your `Invoke-Icinga{0}RESTCall`. Once the REST-Api Daemon is loaded, all functions within this namespace are executed. The function has to return a hashtable with an `Alias` referring to the URL part the user has to enter and a `Command` being executed for this alias.

```powershell
function Register-IcingaRESTAPIEndpointAPITutorial()
{
    return @{
        'Alias'   = 'apitutorial';
        'Command' = 'Invoke-IcingaAPITutorialRESTCall';
    };
}
```

If our module is providing different endpoints, you will have to create multiple register functions. To keep the API how ever clean and prevent conflicting, we advice you to provide only `one` endpoint and handle all other tasks within this endpoint.

As everything is now ready, we can restart our Icinga PowerShell Framework service by using

```powershell
Restart-IcingaWindowsService;
```

and access our API endpoint by browsing to our API location (in our example we assume you use `5668` as default port):

```text
https://example.com:5668/v1/apitutorial
```

```json
[
    {
        "Name": "icinga-powershell-apitutorial",
        "FullName": "C:\\Program Files\\WindowsPowerShell\\Modules\\icinga-powershell-apitutorial"
    },
    {
        "Name": "icinga-powershell-framework",
        "FullName": "C:\\Program Files\\WindowsPowerShell\\Modules\\icinga-powershell-framework"
    },
    {
        "Name": "icinga-powershell-inventory",
        "FullName": "C:\\Program Files\\WindowsPowerShell\\Modules\\icinga-powershell-inventory"
    },
    {
        "Name": "icinga-powershell-plugins",
        "FullName": "C:\\Program Files\\WindowsPowerShell\\Modules\\icinga-powershell-plugins"
    },
    {
        "Name": "icinga-powershell-restapi",
        "FullName": "C:\\Program Files\\WindowsPowerShell\\Modules\\icinga-powershell-restapi"
    },
    ...
]
```

### Conclusion

This is a basic tutorial on how to write custom API-Endpoints and make them available in your environment. Of course you can now start to filter requests depending on the URL the user added, used headers or other input like the body for example. All data send by the client is accessible to developers for writing their own extensions and modules.
