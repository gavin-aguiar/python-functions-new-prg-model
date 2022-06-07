# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/python:4.5.1-python3.9
FROM mcr.microsoft.com/azure-functions/python:4.5.1-python3.9

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \ 
    AzureWebJobsFeatureFlags=EnableWorkerIndexing 

COPY requirements.txt /
RUN pip install -r /requirements.txt 

COPY . /home/site/wwwroot
