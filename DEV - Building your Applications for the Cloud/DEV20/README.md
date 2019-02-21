# Deploying your application faster and safer

Application deployment has changed drastically over the years, with tedious, manual tasks being replaced by scripted routines. It’s even easier today with cloud services to help you out.

In this talk, we’ll take a deep dive into automating and continuously deploying your application using Azure Services. We’ll start with the basics, discussing automated operations that developers control (DevOps) like A/B testing and automated approval gates. We’ll then take that entirely to the cloud using Azure’s new DevOps project, showing you how you can automate the deployment of a frontend web application, backend web service and database, and mobile application with a few clicks of a button.

## Features

This project demonstrates the following:

* [Azure Pipelines](https://azure.microsoft.com/en-au/services/devops/pipelines/?WT.mc_id=msignitethetour-github-dev20)
* [Azure Pipelines App for GitHub](https://github.com/marketplace/azure-pipelines)
* [Azure DevOps Deployment Gates](https://docs.microsoft.com/en-us/azure/devops/pipelines/release/approvals/gates?WT.mc_id=msignitethetour-github-dev20)
* [Azure App Service Deployment Slots](https://docs.microsoft.com/en-us/azure/app-service/web-sites-staged-publishing?WT.mc_id=msignitethetour-github-dev20)

## Additional Links

* [Azure DevOps Documentation](https://docs.microsoft.com/en-us/azure/devops/index?WT.mc_id=MSIgniteTheTour-github-dev20)
* [DevOps Resource Center](https://docs.microsoft.com/en-us/azure/devops/learn/?WT.mc_id=MSIgniteTheTour-github-dev20)

# Demo Walkthrough:

This is the demo script for the DevOps session. In this session, we will cover

- creating a CI Yaml based pipeline from Github to Azure Pipelines.
- adding advanced devops best practices with AB Testing
- Adding automated approval gates between stages using Azure Monitoring as a quality gate
- Fast track starting a project for any language using Azure DevOps Project
- Walk through real world build and release pipelines for Tailwind Trading.

## Setup
This session's demos are done using the browser and one instance of VSCode. Open up an instance of your favorite browser and have the following tabs

1. `Tab 1 - Git hub repo for tailwind front end` https://github.com/damovisa/AbelTailWindFrontEnd 
![](readmeImages/2018-11-09-07-48-15.png)
1. `Tab 2 - DevOps dashboard in Azure` https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/dashboard/private/b490f4aa-5eaf-49d9-af61-3381ac839138
![](readmeImages/2018-11-19-21-01-00.png)
1. `Tab 3 - Tailwind Build All Up` https://dev.azure.com/azuredevopsdemo-a/AbelTailwindInventoryService/_apps/hub/ms.vss-ciworkflow.build-ci-hub?_a=edit-build-definition&id=27
![](readmeImages/2018-11-09-07-59-05.png) 
1. `Tab 4 - Tailwind Release All Up` https://dev.azure.com/azuredevopsdemo-a/AbelTailwindInventoryService/_releaseDefinition?definitionId=1&_a=definition-pipeline
![](readmeImages/2018-11-09-09-09-09.png)
1. `Tab 5 - Release Gate Docusign Example`
https://msvstsdemo-a.visualstudio.com/YoCoreDemo/_releaseProgress?releaseId=10&_a=release-pipeline-progress
![](readmeImages/2018-11-09-09-10-39.png)
1. `Tab 6 - Release Gate Dynatrace Unbreakable Pipeline Pass`
https://msvstsdemo-a.visualstudio.com/AbelUnbreakablePipelineDemo/_releaseProgress?releaseId=275&_a=release-pipeline-progress
![](readmeImages/2018-11-09-09-11-41.png)
1. `Tab 7 - Release Gate Dynatrace Unbreakable Pipeline Fail`
https://msvstsdemo-a.visualstudio.com/AbelUnbreakablePipelineDemo/_releaseProgress?releaseId=276&_a=release-pipeline-progress
![](readmeImages/2018-11-09-09-12-34.png)

Open up another instance of a different browser. If you opened up the first set using chrome, open up another browser using firefox or edge and in this browser have 2 tabs

1. `Tab 1 - Tailwind Traders Staging` https://abeltailwindfrontend4staging.azurewebsites.net/
![](readmeImages/2018-11-09-09-14-45.png)
2. `Tab 2 - Tailwind Traders Production` https://abeltailwindfrontend4.azurewebsites.net/
![](readmeImages/2018-11-09-09-15-37.png)

This demo will also use VSCode to make some code changes

1. VSCode open with src/style.css open

## CLEANUP

1. Delete build and release pipelines for https://dev.azure.com/azuredevopsdemos-a/AbelTailWind
    - [Damovisa.ignite-tour-lp1s2 - CD](https://dev.azure.com/azuredevopsdemo-a/AbelTailWind/_release?view=mine)
    - [Damovisa.ignite-tour-lp1s2](https://dev.azure.com/azuredevopsdemo-a/AbelTailWind/_build_)
1. Change [Testing In Production for ABTesting slot](https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/e97f6c4e-c830-479b-81ad-1aff1dd07470/resourceGroups/AbelIgnite2018WServers/providers/Microsoft.Web/sites/AbelTailWindFrontEnd4/testingInProduction) to 0%
1. Delete [ABTesting slot](https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/e97f6c4e-c830-479b-81ad-1aff1dd07470/resourceGroups/AbelIgnite2018WServers/providers/Microsoft.Web/sites/AbelTailWindFrontEnd4/deploymentSlots)
1. Delete az-pipelines.yml file
1. [Remove marketplace app access to the ignite-tour-lp1s2 repo in GitHub](https://github.com/settings/installations/380745)
1. go to `/src/Nav.js` and reset the heading
![](readmeImages/2018-11-28_15-56-20.png)

## Session script

### Slide Deck
1. I am so excited to be here today to talk to you all about DevOps. Now, I know some of you are thinking, cool DevOps! And some others are probably thinking, DevOps? Who cares? That's just CI/CD Pipelines right? Why should I care about that?
 ![](readmeImages/2018-11-09-09-25-15.png)

 1. I can give you all the reasons and I can pull out charts and graphs to back up my statements. But I wanted to show you a short film that really personifies the difference of before and after DevOps
![](readmeImages/2018-11-09-09-32-26.png)

1. ![](readmeImages/2018-11-09-09-33-37.png)

1. And THAT is why we need to do DevOps!!! NOT the way we used to. All hitting servers with hammers tryng to get our code to deploy once a year. We need to be a well oiled machine like that pit crew! Continuously delivering value!

1. Now I've mentioned DevOps a lot, but what exactly is DevOps. I bet if I ask 10 people in this room what DevOps is, we will get 10 different responses. And I'm not saying anyone elses definition is wrong. But in order to frame this conversation we are having, let me give you Microsoft's Definintion of DevOps
![](readmeImages/2018-11-09-09-36-39.png)

1. At Microsoft, DevOps is something very specific. Devops is the union of people, process and products to enable the continous delivery of value to our end users. Now notice I said that super carefully. I didn't say continously deliver code. Because what will that give us, just piples and piles of code that's no use to our end users. And notice, I didn't even say continously deliver features. Because we could be delivering feature after feature, but if we are not delivering value, we are just wasting time!
![](readmeImages/2018-11-09-09-38-08.png)

1. Now why is this important? Why do should we care about DevOps. The speed of business today is SO fast, that we must adopt DevOps best practices just to keep up. If we don't, our competitors either have or they will adopt DevOps best practices. And whey they do, they WILL out innovate us and they WILL render us obsolete. And no one wants to be rendered obsolete.
![](readmeImages/2018-11-09-09-40-39.png)
1. This isn't just theory anymore. We now have the cold hard imperical facts that cleary demonstrate this. Adopting DevOps best practices means you are faster to market, you have lower failure rates. Much faster lead time for changes and much faster Mean time to recover. And what does all of this translate into? INCREASED REVENUE!
![](readmeImages/2018-11-09-09-42-09.png). 

1. To implement DevOps successfully, you have to attack all three pillars when writing software. You must address the People, the Process and the Products
![](readmeImages/2018-11-09-09-45-07.png)

1. For the people portion, that's the toughest change to make. This is a cultural shift that needs to take place in the organization. Where everybody from the top down all become hyperfocused on continuously delivering value. I don't want to hear, well, that's how we always do things from anyone. Everyone needs to focus on continuously delivering vaue. ![](readmeImages/2018-11-09-09-52-52.png)

1. For the process, we need to have a process that will let us interate fast enough, yet still deliver code of high enough quality. So what does that mean? I need to be able to plan my sprints, and I need to be able to check my code in and out while tracking against the work I'm doing. And as I'm checking code in and out? Builds need to kick off. Automated Tests need to be run. Security scans need to happen. And if the build are good, an automated system needs to pick up my bits and deploy them into my Dev, QA, UAT all the way out in to production. And why does this need to be automated? Potentially, this can happen many times a day! So we need to make sure the process is consistent and repeatable. Every single time like clock work. And once the code reaches production, it doesn't end there. We still need to be able to monitor our code in production. We need to know things like, is my app up or down, is my app performing well, and what are users really doing in my app? Because answers to those questions let me know if I'm delivering vaue to my end users. And if I am, we can double down on those types of activities in the next sprint. And if we aren't, then we can quickly reprioritize our backlog and course correct.![](readmeImages/2018-11-09-09-54-28.png)

1. Now all of this requires the right products and tools to help enable all of this. So we need tools that will let us track our work throughout our sprint. We need source control systems that can corrolate our work to our checkins. We need automated build and release systems that can build on everycheckin, run all of our unit tests and automate deployment all the way to production. And we need systems in place to monitor our app in production. 
![](readmeImages/2018-11-09-09-58-25.png)

1. Out there in the world, there are all sorts of tools that do these things. And Azure is an open system, which means you can keep using all of the DevOps tools you are most familiar with.
![](readmeImages/2018-11-09-10-00-45.png)

1. However, you can replace ALL of them with just one product. Azure DevOps
![](readmeImages/2018-11-09-10-01-40.png)

1. Azure DevOps is literally everything you need to take an idea and turn that idea into a working piece of software in the hands of your end users, for ANY language targeting ANY platform. Azure DevOps is a suite of 5 sepparate products that work SEAMLESSLY together. There's a work item tracking product called Azure Boards, where you can track any unit of work in your software project with visual tools to help you manage all of your work. There is Azure Pipelines, where you can build yout your CI/CD pipelines for any language targeting any platform. There is Azure Repos where you can host your own Git repo or a centralized version control system. There is Azure Test Plans for you to create, plan and run all of your manual tests. And finally there is Azure Artifacts, where you can host your package management systems, whethere they be nuget, maven or even generic packages.
![](readmeImages/2018-11-09-10-03-00.png)

1. In today's session, we will be concentrating on Azure Pipelines, where we will deploy our code faster yet safer!
![](readmeImages/2018-11-09-10-06-46.png)

### Demo
[Bring up main browser with all the tabs and bring up tab 1]

So the code for TailWind is all in github, and we need to build a CI/CD pipeline from github to Azure Pipelines. That's super easy to do with the Azure Pipelines market place extension. Lets go into the marketplace and search for the Azure Pipeline Extension

![](readmeImages/2018-11-09-10-50-00.png)

![](readmeImages/2018-11-09-10-51-07.png)

![](readmeImages/2018-11-09-10-52-12.png)

I've already installed the extension so let's just go in and configure this

![](readmeImages/2018-11-09-10-52-57.png)

![](readmeImages/2018-11-09-10-53-32.png)

![](readmeImages/2018-11-09-10-53-55.png)

And we will configure it to create a CI pipeline for our Tailwind Front End repo
    
![](readmeImages/2018-11-09-10-55-14.png)

This takes us to the login screen of Azure DevOps

![](readmeImages/2018-11-09-10-56-02.png)

![](readmeImages/2018-11-09-10-57-27.png)

Where it will take you through a wizard to help you set up a CI pipeline quickly

![](readmeImages/2018-11-09-12-10-36.png)

![](readmeImages/2018-11-09-14-16-22.png)

![](readmeImages/2018-11-09-14-16-38.png)

Notice Azure Pipelines analyzes the repo and offers you templates that make sense for the technolgogies and languages in your repo. This repo is a node.js app so let's chose the Node.js template

![](readmeImages/2018-11-09-14-18-15.png)

This creates for us an **azure-pipelines.yml** file. So it creates for you a yaml build pipeline. The build engine in Azure pipelines is basically a task runner. It does one task after another after another. And you can describe the tasks either with a visual editor or with a yaml file. There are many benefits to using yaml builds or **Pipeline as Code**. Primarily, now your build pipeline is checked right into source control so your build pipeline is versioned right alongside your source code. If you need more info on yaml builds, just follow the docs link which will take you to our docs page which descrive everything you will need to know.
   
![](readmeImages/2018-11-09-14-23-27.png) 
   
![](readmeImages/2018-11-09-14-24-23.png)

Let's go ahead and save and run this build

![](readmeImages/2018-11-09-14-26-03.png)

![](readmeImages/2018-11-09-14-26-41.png) 

![](readmeImages/2018-11-09-14-27-39.png)

This saves the azure-pipeines.yml file into our git repo which in turn fires off our build. And what happens in the build?  First it downloads all the source code from git hub, then it executes the build steps described in the yml file. So in our case it does

 - Downloads the source code
 - Installs Node.js
 - Does an npm install and build

Now this is fine but I want to customize the build a little, and I want to show you all what the visual editor looks like. So let's hope into the visual editor

![](readmeImages/2018-11-09-14-38-59.png)

![](readmeImages/2018-11-09-14-40-24.png)

So here, you can see each individual step and now, i'm configuring my build to 

   - Install npm
   - Setup the DB connection strings
   - Build the app because we are creating a staic web app out of the node.js app
   - Zip everything up so it's ready to be deployed
   - publish the zip of the website as our build artifact back to Azure Pipelines

The build system in Azure Pipelines is 100% configurable to do ANYTHING. Any language targeting any platform! And the way you customize this build is by adding and removing tasks.

![](readmeImages/2018-11-09-14-48-23.png)

![](readmeImages/2018-11-09-14-49-20.png)

Where out of the box, there are a little over a hunred tasks that you can drag over to the left and just start using.

And what if hyou want to do something that's not out of the box?

![](readmeImages/2018-11-09-14-52-17.png)

Not a big deal, just go to our marketplace where our partners have created over 500 build and release tasks that you can just download and start using.

And if you want to do something that's not out of the box and not in the marketplace? It's still not a problem because you can write your own custom tasks. Custom tasks are nothing more than powershell or node.js. So what that means is that anything you can do from the command line, you can easily get this build and release system to do as well. Which translates into you can make this build and release system do ANYTHING! Any language targeting any platform!

Ok, so we have a visual build that describe the customized build that I want to happen, so the easiest way to add this to our YAML build is to 

![](readmeImages/2018-11-09-14-55-49.png)

view the yaml that gets generated by this visual build

Let's go ahead and copy it, and then we'll just paste this into our azure-pipelines.yml file

![](readmeImages/2018-11-09-14-56-59.png)

Let's go back into VSCode and we'll pull down the latest changes with a git pull

![](readmeImages/2018-11-09-14-58-24.png)

and now let's paste the yaml and replace everything in azure-pipelines.yml 

![](readmeImages/2018-11-09-15-00-32.png)

And now lets push that yaml file back into GitHub. And once the code hits github, it will kick off a new build

![](readmeImages/2018-11-09-15-06-54.png)

![](readmeImages/2018-11-09-15-07-14.png)
   
And what's this build doing? It's downloading the latest source from github, including the azure-pipelines.yml file. It then kicks off a build and executes the build steps described in the yml file! Pipeline as code!!!. And then it will

   - Do an npm install
   - Setup my db connections
   - Build app
   - zip up the website so it's ready to be deployed
   - publish the zip file as the build artifact for this build back to Azure Pipelines

Oh and if you notice, right now, I'm just hardcoding my database end points. If we want to become more secure, we can even store secrets in the pipeline and then use the secrets in the yaml file. 

To set up secrets let's edit our build

![](readmeImages/2018-11-09-15-11-11.png)

![](readmeImages/2018-11-09-15-13-28.png)

Where we can now add variables, lock them to encrypt it and now, if we go back to our azure-pipelines.yml file, we can reference the secret build variables by adding line 32 and 33

![](readmeImages/2018-11-09-15-15-56.png)

Ok, looks like our build has completed

![](readmeImages/2018-11-09-15-17-08.png)

And we get a nice build report that shows everything that happened during the build includeing tests. 

![](readmeImages/2018-11-09-15-17-42.png)

We can even examine the build artifact by clicking on the drop

![](readmeImages/2018-11-09-15-19-02.png)

Where you can see we created a zip file of the website

![](readmeImages/2018-11-09-15-19-29.png)

So just like that, we can create a build pipeline. But we still need to create a release pipeline to release this app. To do that, we'll just click on the Release button

![](readmeImages/2018-11-09-15-20-41.png)

Which brings up the visual editor for the release pipeline. Tailwind Traders website will be hosted in Azure App Service, so we can just select the Azure App Service Deployment Template

![](readmeImages/2018-11-09-15-22-21.png)

And now we just need to finish configuring the release. To configure a release, first we create the stage or environment. The first environment I want to deploy to is my staging environment so I'll replace the name with `Staging`

![](readmeImages/2018-11-09-15-24-17.png)

After defining your stage, next, you get to define the steps that will happen to deploy your app to that stage. So clicking on the steps link will take us to the task runner for this stage.

![](readmeImages/2018-11-09-15-25-22.png)

And since we've already selected the App Service Deployment template, there's not a whole lot of configuring left to do. We just need to chose our azure subscription and chose the app service we want to deploy to. In this case, I want to deploy to the Tailwind Front End staging app service.

![](readmeImages/2018-11-09-15-27-16.png)

Now that we have defined a stage, and defined the steps needed to deploy my app, we can choose manual approvers before and after each stage. For the Staging environment, let's just create a post depoyment approver. That way, if a new build kicks off, it will automatically deploy into my staging environment with no manual intervention

![](readmeImages/2018-11-09-15-29-23.png)

![](readmeImages/2018-11-09-15-33-43.png)

I'll just add myself as a manual approver for this demo. You can add a list of people where everyone on the list has to approve before it will pass through the manual gate. or you can create a group of people and if one person in the group approves, it will pass through the gate. Or you can use a combintion of lists and groups. So you can tighten down security as much as you need to.

Now, let's add another stage to deploy to our production environment. Hover over the environment and select clone to clone the environment.

![](readmeImages/2018-11-09-15-35-50.png)

And we will name the new stage Prod

![](readmeImages/2018-11-09-15-46-22.png)

And now we need to tweak the release steps a little bit so it deploys to the production environment.

Click on the steps in the prod environment 

![](readmeImages/2018-11-09-15-48-12.png)

And change the app service to the production app service.

![](readmeImages/2018-11-09-15-48-41.png)

Click save and voila! We just created a release pipeline that releases Tailwind Traders front end into the staging environment, and then after approvers into the production environment.

Let's see the release in action so we'll click release and click Create Release

![](readmeImages/2018-11-09-15-50-51.png)

And then we'll creat a release using the latest build by clicking Create

![](readmeImages/2018-11-09-15-51-44.png)

![](readmeImages/2018-11-09-15-52-21.png)

 Where we can now watch the release happen live. 
 ![](readmeImages/2018-11-09-15-52-52.png)

And what is happening? The release is going to the build's drop location. It's going to pick up the deployment bits from the drop location and it will deploy those bits into the staging environment based off of the steps that we configured for the staging stage.

![](readmeImages/2018-11-09-15-55-57.png)

Just like with the build the release is fully customizable where you can make it do anything. It's just a task runner, so like the build pipeline, you customize the release steps by adding and removing task runner. Out of the box, you get hundreds of tasks with many hundreds more coming from the marketplace. And you can write your own custom tasks that can make this release system do anything.

![](readmeImages/2018-11-09-15-57-01.png)

Ok, looks like the release finished release in the staging environment and it is now waiting for a post deployment approval

![](readmeImages/2018-11-09-15-58-58.png)

![](readmeImages/2018-11-09-15-59-50.png)

Before we approve it, let's check out our staging environment to see if the new code actually go deployed.

- Bring up browser with the front end in the two tabs, bring up tab 1

  ![](readmeImages/2018-11-09-16-00-54.png)

- Click refresh
     
  ![](readmeImages/2018-11-09-16-02-23.png)

And Voila! Code deployed into the staging environment!

We can now go back to Azure Pipelines, and click the post deployment approval

![](readmeImages/2018-11-10-07-07-47.png)

![](readmeImages/2018-11-10-07-08-07.png)

![](readmeImages/2018-11-10-07-08-33.png)

And now the code flows into the Prod environent

![](readmeImages/2018-11-10-07-09-12.png)

And what is it doing? Release management is going to the drop location for this specific build. The very same drop location where it picked up the bits for staging. And it will deploy the EXACT same bits it deployed into staging will now be deployed into production. There is no new build that's kicked off. There's no way stray code can slip in. Its the exact same bits.

Ok, looks like the bits have been deployed and we are now waiting for a post deployment approval.

Let's check out production

![](readmeImages/2018-11-10-07-11-24.png)

And refresh

![](readmeImages/2018-11-10-07-11-35.png)

And Bam!  New code deployed all the way to prod. So now I'll approve the post deployment approval

![](readmeImages/2018-11-10-07-12-21.png)

![](readmeImages/2018-11-10-07-12-27.png)

![](readmeImages/2018-11-10-07-12-33.png)

And now, we have built our first build and release pipeline where any checkin from github will kick off our build and release through staging all the way into production.

Cool huh?

But you know what? we can do even better. Remember Azure Pipelines is fully customizable where we can make the release system do anything. Including Advanced DevOps best practices. Things like Blue Green deployments, where we first deploy into an environment that's an exact replica of what's in production. Do our testing in it, and when we r ready, we swap production with the BlueGreen environment. So now, what was in production is in my BlueGreen spot and what was in my Blue Green spot is now in production. Something like that is easily doable using Azure Pipelines. Even something like AB Testing, where we deploy new code and route just some of the traffic, like 10% to the new code and route the rest of the traffic to the old code. This way, we can slowly and carefully gather telemetry, make sure we are delivering value. And if things look good, we can slowly bump up the traffic to 20, 30 eventually 100 percent.

In fact, using the power of Azure Pipelines and Azure App service, this is really pretty trivial to do. Check this out.

[Go back to main browser,  `Tab 2 - Tailwind Front End App Service in Portal`]

Here is the azure portal page for my app service which is hosting the Tailwind Traders front end.

![](readmeImages/2018-11-10-16-31-18.png)

To implement AB testing, scroll down to **Development Tools** and select **Testing In Production**

![](readmeImages/2018-11-10-16-38-42.png)

Here we get to add a deployment slot. Deployment slots are... think of them like a virtual directory for your web app. 

![](readmeImages/2018-11-10-16-39-37.png)

We'll create a slot and then we can direct what percentage of the traffic we want routed to what slot.

I'll name this new slot **ABTesting**

![](readmeImages/2018-11-10-16-41-09.png)

And this creates me my slot. Now, I just need to add in the percentage of traffic that I want to route to the slot. For this demo, I'll pick 50%.

![](readmeImages/2018-11-10-16-42-35.png)

And that's all I need to do on the infrastructure side. To implement AB testing in my pipeline, all I'll need to do is make some simple changes.

[Bring up browser tab with Azure Pipeline]

![](readmeImages/2018-11-12-08-09-39.png)

First, I'm going to clone my prod environment and we'll call it Prod B

![](readmeImages/2018-11-12-08-11-45.png)

![](readmeImages/2018-11-12-08-12-08.png)

Next, I'll rename my Prod stage to Prod A

![](readmeImages/2018-11-12-08-12-48.png)

And we do need to tweak the deployment step, because instead of deploying the new code to the production slot, we will deploy the new code to the ABTesting slot we just created 

![](readmeImages/2018-11-12-08-16-41.png)

And save and Bam. That's all we have to do. Now, to see this in action let's go make some code changes.

Let's turn the background of our app purple

![](readmeImages/2018-11-12-08-29-50.png)

Save it, and commit back to github

![](readmeImages/2018-11-12-10-45-24.png)

This kicks off our our build

![](readmeImages/2018-11-12-10-45-58.png)

And what is happening in this build?

![](readmeImages/2018-11-12-10-46-16.png)

The build engine is downloading the latest changes from github including the azure-piplines.yml file. Then the build engine starts executing all the steps defined in the yaml file.  

   - NPM Install
   - Setup DB Connection strings and endpoints
   - Build App into static files
   - Zip everything up so the build artificat is the zip file of the web app all ready to be deployed
   - published build artifact back to Azure Pipelines.

And while this is running, I wanted to show you one more thing. Because right now, our database user and password is just stored as plain text in my yml file

![](readmeImages/2018-11-12-11-08-59.png)

We can easily store and use secrets in Azure Pipleines by editing the build

![](readmeImages/2018-11-12-11-09-59.png)

Where we can store secrets for our pipelines which are encrypted so no one can see them. And to use them, in your yml file, we would just reference them like this

![](readmeImages/2018-11-12-11-11-57.png)

Ok, looks like the build has finished and now it's kicked off the release pipeline

![](readmeImages/2018-11-12-11-45-59.png)

So what is it doing? Release Management is downloading the build artificat from the build. In this case, it's the zip file of the compiled application and now it is deploying this new code. The one with the purple background into the staging environment. And here it is, deployed in staging. 

![](readmeImages/2018-11-12-11-15-03.png)

Approving this

![](readmeImages/2018-11-12-11-46-41.png)

And now, the bits start flowing into the Prod A slot

![](readmeImages/2018-11-12-11-47-13.png)

So what is really happeing? Release management is going to the drop location, the very same drop location for this specific build and download the build artifacts. The VERY same build artifcats as what we just deployed into staging? It will now deploy those exact same bits into the ABTesting slot. There was no extra build, no extra compile, no extra bundling. These will guarentee be the exact same bits.

Ok, now that we've deployed into the TestAB slot

![](readmeImages/2018-11-12-11-48-48.png)

Let's refresh our production environment and we see...

![](readmeImages/2018-11-12-11-50-32.png)

Why isn't the background purple?  Remember, we are now routing 50% of the traffic to the old code and 50% of the traffic to the new code. So let's open up another browser

[Go back to the main browser, open new tab, copy and paste front end prod url]

And...

![](readmeImages/2018-11-12-11-54-41.png)

Voila! 50% of our traffic routed through the old code, 50% of the traffic routed through the new code. Now, we can collect telemetry to help us determine if we are delivering value. And if they are, we can approve this and the code 

![](readmeImages/2018-11-12-11-55-39.png)

Will flow 100% to the new code.  

![](readmeImages/2018-11-12-12-17-53.png)

As you can see, we can easily set up our pipeline so we can increment the flow from 10% to 20% and slowly all the way up to 100%. And if we are not giving value, we can also set up the pipeline to stop the deployment and roll back.

![](readmeImages/2018-11-12-12-18-45.png)


Pretty cool huh. I have just shown you 

   - Creating a CI/CD Pipeline
   - Implementing advanced DevOps best practices like AB Testing using Azure Pipelines and Azure App Service

But we can do even better! Using Azure Pipelines, we have the ability to create automated approval gates based off of continuous monitoring. So now, we can automate the approval process from one stage to the next using AI!!!

For instance, right I've set up my staging environment to be monitored using Application Insight. 

[`Tab 3 - Application Insight for TailWind Traders Staging Environment`]
![](readmeImages/2018-11-12-12-41-33.png)

And here, I've set up an alert

![](readmeImages/2018-11-12-12-43-02.png)

Looking for uncaught browser based javascript alert. And if there are too many of these, this will create an alert in Application Insight.

![](readmeImages/2018-11-12-12-43-43.png)

So the idea now is for me to deploy into the staging environment. I can then run my tests, users can start testing in the staging environment. And if Application insight finds too many alerts or browser based errors, it will automatically stop my deployment so I don't deploy into production. And if everything looks good, it will automatically with no user approvals, flow into the production environment.

To set this up, we set up alerting in application insight for the staging environment, and then we need to tweak the release pipeline to use automated gates.

![](readmeImages/2018-11-12-13-12-55.png)
 
 First, I'm going to remove the manual approver from the post deployment step

 ![](readmeImages/2018-11-12-13-38-22.png)

And then, I'll add an automated gate of type Query Azure Monitor alerts

![](readmeImages/2018-11-12-13-40-46.png)

Now, I just need to select the correct azure subscription, resource group and resource name and alert name

![](readmeImages/2018-11-12-13-40-56.png)

Set up my pulling frequency and and gate timeout, we'll save this and that's all we need to do. We have now set up an automated gate based off of continuous monitoring using Appication Insight.

Now when we queue a release,

![](readmeImages/2018-11-12-13-43-01.png)

![](readmeImages/2018-11-12-13-43-21.png)

It will deploy my code into the staging environment. The code that I'm deploying has a bunch of browser errors whenenever the index page is hit

![](readmeImages/2018-11-12-13-44-22.png)

So Now

![](readmeImages/2018-11-12-13-44-33.png)

After the code has been deployed, let's refresh our staging environment a couple of times

[Refresh staging 5 times]

And this should generate a bunch of application insight errors from the browser

[`Tab 3 - Application Insight for TailWind Traders Staging Environment`]

![](readmeImages/2018-11-12-13-46-57.png)

![](readmeImages/2018-11-12-13-47-04.png)

And here, you can see application Insight has caught a bunch of browser errors

Which means now, when my gate hits, it detects the alerts from App Insight, fails the gate so now the broken code automatically does not get pushed to the prod environments!!!

And BAM! Gate detected Application Insight alerts. Failed and release died in staging.

![](readmeImages/2018-11-12-13-49-46.png)

SUPER COOL Stuff!!!

So what have I shown you so far?

   - We can easily create CI/CD Pipelines for any language targeting any platform
   - We can easily implement pretty much anything in our pipelines, including advanced DevOps best practices like AB Testing.
   - We can even enable automated approval gates using Continuous monitoring so now we can deploy faster yet even safer!!!

And all of this can be done easily.  But let me tell you a confession. I may be a DevOps practitioner, but I'm not a huge fan of building out CI/CD Pipelines by hand. I mean, I recognize the importance of good pipelines, but I love to write code! That's what makes me happy. And with the power of Azure, i can get started super easily with just a couple of clicks. And what do I mean by "getting started?" 

Using the power of Azure DevOps Projects, with just a few clicks, I can create everything I need to get started. A Team Project in Azure Pipelines. Sample code in the language that you pick in my repo. A CI/CD pipeline that makes sense for the technolgoies picked, and infrastructure provisioned for you in Azure. And I get ALL of this with just a couple of clicks. Let me show you what I mean.

[`Tab 4 - Azure Portal` ]
![](readmeImages/2018-11-09-07-50-20.png)

From the azure portal, let's go and create an Azure DevOps project. 

![](readmeImages/2018-11-12-14-36-35.png)

Now the very first thing it's going to ask you is what language do you want to use. You can pick .NET of course, node, php, java, python, ruby go with more languages to come!

![](readmeImages/2018-11-12-14-37-25.png)

For this demo, let's pick node and click next

Now it's asking what framework do you want to use. For this demo, let's just build a simple Node.js app.

![](readmeImages/2018-11-12-14-38-06.png)

And now, it's asking what infrastructure do you want to host your app? For this demo, let's host our node.js app in a kubernetes cluster.

![](readmeImages/2018-11-12-14-38-53.png)

And now, it's asking what instance of Azure DevOps do you want to use to orchestrate everything. You can create a brand new one from here, or use one that already exists. For this demo, I'll pick my demo account, I'll name the project IgniteTour, name my Kubernetes Cluster IgniteTourCluster, click done and....

![](readmeImages/2018-11-12-14-42-10.png)

Bam, that is LITERALLY all you need to do. Now, just kick back and let Azure build everything out for you. A team project in Azure Pipelines. Sample code in the langauge that you picked, In our case, a node js sample app, sitting in a git repo. A CI/CD Pipeline that makes sense for the technologies picked, so a node js app running in a docker container, hosted in a kubernetes cluster. And infrastructure provisioned for you in Azure. So a kubernetes cluster deployed for us in Azure. And when it's all done doing this, you get a portal blade that looks like this

[`Tab 5 - Ignite 1 DevOps Project Dashboard` ]
![](readmeImages/2018-11-12-15-07-18.png)

Where on the left hand side you see the CI/CD Pipeline. And on the right hand side, you see all the infrastructure that got provisioned for you in Azure uncluding our kubernetes cluster, instance of application isight and our web app running in our Kubernetes cluster.

And all of these links are deep links into the resource itself. For instance 

![](readmeImages/2018-11-12-15-07-43.png)

Clicking on the link to the code will take us to the git repo holding our node js app.

![](readmeImages/2018-11-12-15-18-12.png)

Notice, this is just a node js app using DevOps best practices so we are using Arm templates for Infrastructure as Code and also using Helm charts to package up our kubernetes app.

For the build pipeline

![](readmeImages/2018-11-12-15-19-19.png)

We create for you a build pipeline that makes sense for the technologies picked. So in this case you get a build pipeline that creates a docker image for the node.js sample app, pushes the image into an instance of Azure Container Registry and then packages the app up as a helm package.

![](readmeImages/2018-11-12-15-20-20.png)

Next, for the release pipeline

![](readmeImages/2018-11-12-15-20-46.png)

![](readmeImages/2018-11-12-15-21-12.png)

We create for you a release pipeline that makes sense for the technologies picked.

![](readmeImages/2018-11-12-15-21-43.png)

We create a pipeline that creates your azure infrastructure using the ARM templates, which includes the kubernetes cluster in Azure Kubernetes Service. And then we deploy our app using Helm.

And after deploying the app, the app is no available by clicking on the app endpoint from the portal blade

![](readmeImages/2018-11-12-15-22-55.png)

Which launches our sample app deployed in Azure Kubernetes Service

![](readmeImages/2018-11-12-15-23-37.png)

And once again. You get all of this with just a couple of clicks!!

So million dollar question. How do you get your real code into this pipeline instead of the sampel app?

Simple enough

Going to the git repo

![](readmeImages/2018-11-12-15-37-15.png)

This is just a plain old git repo. So simple enough to clone this onto our hard drive, remove the application folder, copy our application into the local repo. Commit and push those changes back up to Azure Repos which will kick off the CI/CD pipeline with our real code which then get's pushed all the way into production!

There's another way we can do this too by editing the build pipeline.

![](readmeImages/2018-11-12-15-39-18.png)

And now, when we get source, instead of getting the source from Azure Repos, we'll switch that over to my github repo holding my real code, click Save and Queue

![](readmeImages/2018-11-12-15-40-24.png)

![](readmeImages/2018-11-12-15-40-48.png)

And this should start building my real code from github and sending it through the release pipeline all the way to my kubernetes cluster.

And going back into the portal

 [`Tab 6 - Ignite 2 DevOps Project Dashboard` ]

![](readmeImages/2018-11-12-15-42-59.png)

You can see that the code is being pulled from github, it's been built and deployed and here is my real app, deployed into my kubernetes cluster 

![](readmeImages/2018-11-12-15-43-33.png)

BAM!!!! And ALL Of this, with just a couple of clicks.

So what have we've shown you all?

   - We can easily build out CI/CD pipelines for any language targeting any platform
   - We can easily impliment advanced DevOps techniques using Azure Pipelines and Azure
   - We can even include automated deployment gates that utilize continuous monitoring to help us determine if a gate should pass or not
   - And we can quickly scaffold out our CI/CD pipelines into Azure with just a couple of clicks using Azure DevOps Projects!

Now all of these demos that I have shown are still relatively simple. How would all of this work with a real world application? Like with Tailwind Traders?

The Tailwind Traders application consists of a node.js web front end with two microservices. The inventory service is a .net core micro service running in a docker container hosted in Azure App Service.  The product service is a node js micro service running in a docker container hosted in a kubernetes cluster. The web front end is a Node.js app hosted in Azure App Service. And finally, there is also an iOS mobile app front end as well. Can we use Azure Pipelines to build and release this real world scenario?

ABSOLULTEY! Check this out

[`Tab 7 - Tailwind Build All Up` ]
https://dev.azure.com/azuredevopsdemo-a/AbelTailwindInventoryService/_apps/hub/ms.vss-ciworkflow.build-ci-hub?_a=edit-build-definition&id=27
![](readmeImages/2018-11-09-07-59-05.png) 

Here is one build that builds ALL 4 parts of our application in parallel. We use a 
hosted windows agent to build our .net core inventory service and we create a docker image out of it.

![](readmeImages/2018-11-12-15-50-31.png)

Next we use an ubuntu agent to build our node js product service container and then we create a helm package out of it

![](readmeImages/2018-11-12-15-51-35.png)

Next we use another ubuntu agent to build our node js Tailwind front end web application

![](readmeImages/2018-11-12-15-52-12.png)

And finally, we use one of our hosted mac agents to create our iOS application.

1 build, 4 parallel agents building our app all at once. We are the ONLY cloud vender that will give you agents for all 3 platforms. Windows, Linux and Macs!!!!

We can do the same thing with our release pipelines too.

[`Tab 8 - Tailwind Release All Up` ]
![](readmeImages/2018-11-12-16-11-47.png)

Where we have one release with 4 parallel tracks. One track to deploy the inventory service as a container into App Service

One track taking the Product Service and deploying that as a helm app in a Kubernetes Cluster

One track that deploys the web front end as a static site sitting in App service and  finally, one track that takes the ios app and deploys it all the way out into the App Store.

So real world? You bet. Using azure pipelines, you can deploy any app targeting any platform no matter how complex your app.  And as for release gates, here are some real world cases of using release gates.


[`Tab 9 - Release Gate Docusign Example`]

![](readmeImages/2018-11-09-09-10-39.png)

I was recently at a hospital where they literally had a rule in place where they could not deploy into production without a physical document signed and uploaded to their docusign server. This was turning into a bottleneck as now, a physical person had to verify the document was signed before deployments into production could happen.  However, I also knew that Docusign had a rest api, so it was super simple to create a custom gate that checked to see if the document was signed.

![](readmeImages/2018-11-12-16-17-21.png)

So now, after the code is deployed into QA, tests were done, a human ok'd it, and now, the gate kicked in. When you set up a gate, you get to set up the polling frequency as well as the time out. So in this case, I pulled every 5 minutes checking to see if the document was signed. First time, wasn't signed. Second time, still wasn't signed. 15 minuytes later? Docuemnt was signed and the new deployment automatically deployed into the production environment.

Another example of using these release gates is here, where I used Dynatrace monitoring to see if a release is good or not.

[`Tab 10 - Release Gate Dynatrace Unbreakable Pipeline Pass`]

![](readmeImages/2018-11-09-09-11-41.png)

![](readmeImages/2018-11-12-16-19-51.png)

In this example, code was deployed to staging, load test were run, and then the gate kicked in, where we use dynatrace to help us determine if the deployment was good or bad. In this case, all response times looked good, the gate passed and the code flowed into production.

[`Tab 11 - Release Gate Dynatrace Unbreakable Pipeline Fail`]

![](readmeImages/2018-11-09-09-12-34.png)

![](readmeImages/2018-11-12-16-20-59.png)

And here, after the code was deployed in staging and load tests were run, dynatrace detected enough annomolies that it said the release was bad, failing the gate, and the bad code never made it into production.

So here you can see how using automated approval gates, you can use AI to help with your deployments. So all you devs out there, let's do this!!! Go to dev.azure.com and let's start building our CI/CD pipelines so we can all deploy faster yet safer
