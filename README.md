# Django Setup Script
This is PowerShell Script written to make for ease in setting up a Django Project and getting it ready for development.

## Features
#### This Script passed the Pester and PowerShell Script Analyzer (PSSAnalyzer) and performs the functionalities listed below: 
* Creates new working directory or uses an already created one
* Creates and activates python virtual environment
* pip installs django, rest framework, dbbackup, debug toolbar, pscorg2 and a host of others
* Starts django project and django app
* Creates backup folder, static folder, media folder and templates folder
* Adds django app, rest_framwork, dbback, debug_toolbar and every other dependency to list of installed apps
* Creates .env file
* Imports os and decouple for environment variables
* Extracts Secret Key to .env file and set environment variable in settings.py
* Adds Database setting for postgres as a comment which can be uncommented for use
* Cofigures settings.py with database backup code
* Adds a TEMPLATES_DIR variable and fills it in the DIRS array
* Adds MEDIA and STATIC DIRS and also adds media and static root
* Adds debug_toolbar middleware to the top of middleware list
* Configures Internal IPS for debug_toolbar
* Configures created app's views.py and write a first HTTP request function to handle index page
* Creates a forms.py file and adds initial neccessary imports
* Creates a serializers.py file and adds initial neccessary imports
* Creates a validatiors.py file and adds initial neccessary imports
* Creates a url.py file for app, adds initial neccessary imports, creates a urlpattern and writes a path for passing views 
* Creates an UTF-8 encoded index.html file in templates folder to allow for debug_toolbar
* Configure project urls.py settings to add 'include' and a path for index views and debug_toolbar view 
* Returns to configure dbackup in virtual environment site package to update a depracated function in latest django releases 
* Applies initial migrations and allows for creating superuser

## Requirement
* You only need Python installed on your machine. If you don't already have it installed, download it [here.](https://www.python.org/downloads/)

## Instruction
* Right after the migrations have been done, open the project folder and create a .env file, then copy the content in the example.env file to it. Then run 
`python manage.py runserver`

## Installation guide
This scripts has been published on powershell gallery. You can install it by running the command below:

`Install-Script -Name setupdjango`

