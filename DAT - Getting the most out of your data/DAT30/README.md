# Using Artificial Intelligence to Augment Data

Tailwind Traders has a lot of data. We have a catalog that is constantly updated with new products from around the world, but we also keep photos and text for things like product returns and customer feedback. Adding contextual information for all this data (tags, categories, etc.) is a daunting task which can take a single person a very long time to enter into our system, with results that are error prone.

In this session we'll show you how we use Cognitive Services with Microsoft Azure, which uses artificial intelligence to add additional context to our data. We'll use it to "read" and interpret text, apply tags to images, and even help answer customer questions.

## Features

This project framework provides the following features:

* [Azure Cognitive Services - Text analytics](https://azure.microsoft.com/en-au/services/cognitive-services/text-analytics/?WT.mc_id=msignitethetour-github-dat30)
* [Azure Cognitive Services - Computer Vision](https://azure.microsoft.com/en-au/services/cognitive-services/computer-vision/?WT.mc_id=msignitethetour-github-dat30)
* [Azure Custom Vision](https://customvision.ai?WT.mc_id=msignitethetour-github-dat30)
* [Azure Functions](https://azure.microsoft.com/en-au/services/functions/?WT.mc_id=msignitethetour-github-dat30)
* [Azure Web Apps (App Service)](https://azure.microsoft.com/en-au/services/app-service/?WT.mc_id=msignitethetour-github-dat30)
* [Azure SQL Database](https://azure.microsoft.com/en-au/services/sql-database/?WT.mc_id=msignitethetour-github-dat30)

## Additional Links:

* [Azure Cognitive Services Documentation](https://docs.microsoft.com/en-au/azure/cognitive-services/?WT.mc_id=MSIgniteTheTour-github-dat30)
* [Getting started with Azure Cognitive Services in containers](https://azure.microsoft.com/en-us/blog/getting-started-with-azure-cognitive-services-in-containers/?WT.mc_id=msignitethetour-slides-dat30)
* [Learn Azure Cognitive Services](https://docs.microsoft.com/en-us/learn/?WT.mc_id=msignitethetour-github-dat30)

## Getting Started

The Azure Piplines YAML definition will build and package all the required deployables.

Running the ARM templates will define and wire up all the Azure resources required, *EXCEPT*:

* The Azure Web App (lp3s3-comments) needs an additional Application Setting called `FunctionsKey` with the `_master` value of the Azure function. You'll need to set this manually, because Functions v2 does not make this available programmatically.
* The Azure Function needs an additional Application Setting called `customVisionProjectId` with the GUID of the Custom Vision project you're using.

### Prerequisites

A browser and an Azure account for deployment.
To run demo #3 (Azure Cognitive Services in Containers), you will need Docker installed on your local machine.

### Installation

* Azure Pipelines Build to build the application (or you could build it manually!)
  * Fork this repo
  * Update the values in the `ARM/arm-parameters.json` file for your subscription and resource names. The `webapp_serverFarmResourceGroup` variable will need to match the resource group name you are planning to use to deploy this to.
  * Create a new [Azure Devops](https://dev.azure.com) project
  * Create a new Build pipeline pointing to your new repo. This will automatically discover the YAML file and set up the build. Click __RUN__ to create the pipeline and start the build. You will need to wait for this build to finish before you can set up the release pipeline.
* Azure Pipelines Release to deploy the ARM template, the web app, function app, and database seed scripts (or again, manual if you want).
  * Create a new release pipeline
  * Create the first stage as an empty job called _Deploy to Azure_
  * Add the build as an artifact.
  * Edit the first stage that was created.
  * Rename the first job to `Azure resource group`, and set the pool to _Hosted Windows Container_
    * Add a _Azure Resource Group Deployment_ task to this job.
      * Set the display name to `Validate Resource Group`
      * Select your subscription (adding it or authorizing it if required)
      * Set the resource group name to match the one you used for the `webapp_serverFarmResourceGroup` variable in the `ARM/arm-parameters.json` file, and set the location to one nearest to you.
      * Set the template and template parameters to the relevant files in the linked artifacts
      * Set the deployment mode to _Validation only_
    * Clone this task, and name the clone `Deploy Resource Group`.
      * Add the following to the override template parameters:
      
        `-db_administratorLogin "$(DbAdminUsername)" -db_administratorLoginPassword "$(DbAdminPassword)"`
      * Set the deployment mode to be _Incremental_
      * Set the deployment outputs to be `cognitiveKeys`
  * Add a new agent job to the stage called `Deploy Azure Function`, and set the pool to _Hosted Windows Container_
    * Add a new _Azure App Service Deploy_ task to this job
      * Set the version to _4.*_
      * Set the display name to `Azure App Service Deploy: Function App`
      * Set the subscription
      * Set the app service type to _Function app on Linux_
      * Set the App service name to the `$(FunctionName)` variable
      * Set the package or folder to be the `function` folder from the build artifacts
      * Set the runtime stack to be _.NET_
  * Add a new agent job to the stage called `Deploy Web App`, and set the pool to _Hosted Ubuntu 1604_
    * Add a new _Azure App Service Deploy_ task to this job
      * Set the version to _4.*_
      * Set the display name to `Azure App Service Deploy: Web App`
      * Set the subscription
      * Set the app service type to _Web app on Linux_
      * Set the App service name to the `$(WebAppName)` variable
      * Set the package or folder to be the `web` folder from the build artifacts
      * Set the runtime stack to be _.NET Core 2.1_
      * Set the startup command to be `dotnet lp3s3-comments.dll`
  * Add a new agent job to the stage called `Seed Database`, and set the pool to _Hosted VS2017_
    * Add a new _Azure PowerShell_ task to this job
      * Set the display name to `Azure PowerShell: run SQL`
      * Set the subscription
      * Set the script path to the `sql/seed.ps1` file in the build artifacts
      * Set the script arguments to be:
      
        `-dbName $(DbName) -dbAdminPassword $(DbAdminPassword) -serverName $(DbServerName) -workingDir $(System.DefaultWorkingDirectory)/<your repo>`
        To set the `workingDir` parameter, copy the first two parts of the value from the script path that would have been set when selecting the artifact, up to but not including the `sql` folder.
      * Set the Azure powershell version to be the latest installed version
  * Head to the _Variables_ tab and add 4 new pipeline variables by taking values from the ARM template parameters
    * `DbAdminPassword` - the value of `db_administratorLoginPassword`
    * `DbAdminUsername` - the value of `db_administratorLogin`
    * `DbName` - the value of `db_databaseName`
    * `DbServerName` - the value of `db_serverName`
    * `FunctionName` - the value of `function_name`
    * `WebAppName` - the value of `webapp_name`
  * Add the settings as described above:
    * The Azure Web App needs an additional Application Setting called `FunctionsKey` with the `_master` value of the Azure function. You'll need to set this manually, because Functions v2 does not make this available programmatically.
    * The Azure Function needs an additional Application Setting called `customVisionProjectId` with the GUID of the Custom Vision project you're using.

## Demos

Note: Demos are centred around the Tailwind Traders Admin pages. The URLs in these demos are relative to the root of that admin site.

### 1. Text Analytics

Navigate to `/` to see the comments left by customers. These are example comments in different languages that we want to analyse. We want to automatically translate these, and discover positive and negative sentiment so we know what to focus on as a company.

Navigate to `/Extended` to see the same data with some additional columns. Click the `Analyse` button to hit an Azure Function that retrieves Sentiment, language, an English translation (if applicable) and key phrases (if available for the given language).

The logic for these text analytics calls can be found in [lp3s3-comments-function/CogSvc/TextAnalyser.cs](lp3s3-comments-function/CogSvc/TextAnalyser.cs). This example uses the REST API directly to retrieve results.

### 2. Handwriting Recognition

Navigate to `/Returns` to see products that have been returned by customers, along with handwritten notes. This data is valuable, but is currently very difficult to retrieve. We're going to use handwriting recognition to make that data searchable.

Click the `Analyse` button to hit an Azure Function that uses the Computer Vision API to read the handwritten notes. While it's not perfect, it should allow us to filter and search.

The logic for this handwriting recognition can be found in [lp3s3-comments-function/CogSvc/HandwritingAnalyser.cs](lp3s3-comments-function/CogSvc/HandwritingAnalyser.cs). This example uses the .NET SDK to communicate with Cognitive Services.

### 3. Azure Cognitive Services in Containers

Many of these services are able to be accessed without Internet access thanks to the preview release of Container support.

On a commandline, enter the following:

    docker pull mcr.microsoft.com/azure-cognitive-services/sentiment:latest

This will retrieve the sentiment analysis docker image.

To run the container, enter the following:

    docker run --rm -it -p 5000:5000 --memory 8g --cpus 1 mcr.microsoft.com/azure-cognitive-services/sentiment Eula=accept Billing=https://westus.api.cognitive.microsoft.com/text/analytics/v2.0 ApiKey=[your-api-key]

You can navigate to the running container in a browser by going to [localhost:5000](http://localhost:5000). Navigate to the Swagger documentation, and try it out.

You can also disconnect from the Internet to prove that this demo still runs offline!

### 4. Custom Vision

Navigate to `/Products` to see a list of the products on the website and the average comment sentiment left by visitors. These have been sorted with negative sentiments first.

You'll notice that many of the poorly-rated products have incorrect product tags. We want to use Custom Vision to recognise our own product categories, and update the tags for us.

Navigate to https://customvision.ai and create a new project.

Upload the images stored in [training-images/](training-images/), tagging them as "Hammer" and "Wrench" appropriately.

Train the model, and set the newly-trained iteration to the default.

In the URL bar of your browser, copy the GUID that represents the project ID. You will need this for the `customVisionProjectId` setting mentioned in *Getting Started*.

On the Products page of the Tailwind Traders Admin site, click the `Analyse` button to call an Azure Function that will query your trained custom vision model for an appropriate tag. The confidence level will also be set.

The logic for calling the predictions API of the Azure Custom Vision service can be found in [lp3s3-comments-function/CogSvc/CustomVisionAnalyser.cs](lp3s3-comments-function/CogSvc/CustomVisionAnalyser.cs). This example uses the .NET SDK to communicate with Cognitive Services.
