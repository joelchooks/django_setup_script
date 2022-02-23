<#
.DESCRIPTION
This script is written to make for ease in setting up a django project and getting it ready for development.
#>


# Collect Mandatory Folder Name Input
Do {
    $folder_name = Read-Host -Prompt 'Enter Name of New Folder'
} Until ($folder_name)

$folder_root = Join-Path $PSScriptRoot $folder_name

# Function to change working directory
function change_wkdir {
    Write-Output "Changing Working Directory to Created Folder"
    Set-Location .\$folder_name
}

# Function to run script
function run_script {
    # Collect Mandatory Django Project Name

    Do {
        $project_Name = Read-Host -Prompt 'Enter Project Name'
    } Until ($project_name)

    $new_wkdir_folder = Read-Host -Prompt "Do you want to create project in a new folder? [y] Yes  [ANY OTHER KEY] No (default is 'No')"

    # Collect Mandatory App Name
    $app_name = Read-Host -Prompt "Enter App Name or Leave Empty to use 'core_app'"

    # Check if App Name is empty
    if ($app_name -eq ''){
        $app_name = 'core_app'
    } else {
        $app_name += '_app'
    }

    Write-Output "Creatng Virtual Environment in Working Directory (venv)"
    python -m  venv venv

    Write-Output "Activating Virtual Environment"
    .\venv\Scripts\activate

    Write-Output "Installing django and other dependencies"
    pip install django
    pip install djangorestframework
    pip install psycopg2
    pip install psycopg2-binary
    pip install django-debug-toolbar
    pip install markdown
    pip install django-filter
    pip install python-decouple
    pip install django-dbbackup
    pip freeze > requirements.txt

    Write-Output "Creating Django Project"
    if ($new_wkdir_folder -eq 'y'){
        django-admin startproject $project_name .
    } else{
        django-admin startproject $project_name
        Set-Location .\$project_name
    }

    Write-Output "Creating App"
    django-admin startapp $app_name

    Write-Output "Creating Static Dir"
    mkdir 'static'

    Write-Output "Creating Media"
    mkdir 'media'

    Write-Output "Creating Backup Dir"
    mkdir 'backup'

    Write-Output "Creating Template Dir"
    mkdir 'templates'

    Write-Output "Creating index.html template"
    Set-Location .\'templates'
    New-Item  'index.html' -ItemType File

    Write-Output "Writing to index.html"
    $htmlines = @(
        "<!DOCTYPE html>",
        "<html lang='en'>",
        "<head>",
        "    <meta charset='UTF-8'>",
        "    <meta http-equiv='X-UA-Compatible' content='IE=edge'>",
        "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>",
        "    <title>Document</title>",
        "</head>",
        "<body>",
        "    <h1>Welcome</h1>",
        "</body>",
        "</html>"
    )

    foreach ($_ in $htmlines) {
        $_ | out-file -encoding utf8 index.html -Append
    }


    Set-Location ..
    Write-Output "Creating urls.py, serializers.py, forms.py and validators.py files"
    Set-Location .\$app_name
    New-Item  'urls.py' -ItemType File
    New-Item  'serializers.py' -ItemType File
    New-Item  'forms.py' -ItemType File
    New-Item  'validators.py' -ItemType File

    Write-Output "Writing to views"
    $viewscontent = Get-Content views.py

    if ($new_wkdir_folder -eq 'y'){
        $viewsPath = Join-Path $PSScriptRoot $folder_name\$app_name\views.py
    } else{
        $viewsPath = Join-Path $PSScriptRoot $folder_name\$project_name\$app_name\views.py
    }

    $ViewsModified = @()
    Foreach ($Line in $viewscontent){
        $ViewsModified += "from django.shortcuts import get_object_or_404, render"
        $ViewsModified += "from rest_framework.decorators import api_view"
        $ViewsModified += "from rest_framework import status, request"
        $ViewsModified += "from rest_framework.response import Response"

        if ($Line -notmatch "shortcuts import render")
        {
            # send the current line to output
            $ViewsModified += $Line
            if ($Line -match "# Create your views here.")
            {
                #Add Lines after the selected pattern
                $ViewsModified += "def index(request):"
                $ViewsModified += "    return render(request, 'index.html')"
            }

            elseif ($Line -match "# Create your views here.")
            {
                #Add Lines after the selected pattern
                $ViewsModified += "def index(request):"
                $ViewsModified += "    return render(request, 'index.html')"
            }
        }
    } Set-Content -encoding utf8 $ViewsPath $ViewsModified


    Write-Output "Carrying out Urls configuration"
    $urlines = @(
        "from django.urls import path",
        "from . import views",
        " ",
        "app_name = '$app_name'",
        " ",
        "urlpatterns = [",
        "    path('', views.index, name='index'),",
        "]"
    )

    foreach ($_ in $urlines) {
        $_ | out-file -encoding utf8 urls.py -Append
    }

    Write-Output "Setting up serializers.py"
    $serializerlines = @(
        "from rest_framework import serializers",
        "from rest_framework.authtoken.views import Token",
        "from django.contrib.auth.models import User",
        "from . import views"
    )

    foreach ($_ in $serializerlines) {
        $_ | out-file -encoding utf8 serializers.py -Append
    }

    Write-Output "Setting up forms.py"
    $formlines = @(
        "from django import forms",
        "from django.db import models",
        "from django.forms import widgets"
    )

    foreach ($_ in $formlines) {
        $_ | out-file -encoding utf8 forms.py -Append
    }

    Write-Output "Setting up validators.py"
    $validatorlines = @(
        "from django.core.exceptions import ValidationError",
        "from django.core.validators import URLValidator, RegexValidator, EmailValidator, MaxValueValidator, MinValueValidator, DecimalValidator"
        "from django.utils.translation import gettext_lazy as _",
        " ",
        "def validate_name(value):",
        "    if value is None:",
        "        raise ValidationError('Please Enter A Name')",
        "    return value"
    )

    foreach ($_ in $validatorlines) {
        $_ | out-file -encoding utf8 validators.py -Append
    }

    Set-Location ..
    Set-Location .\$project_name

    $urlcontent = Get-Content urls.py

    if ($new_wkdir_folder -eq 'y'){
        $urlPath = Join-Path $PSScriptRoot $folder_name\$project_name\urls.py
    } else{
        $urlPath = Join-Path $PSScriptRoot $folder_name\$project_name\$project_name\urls.py
    }

    $UrlsModified = @()
    Foreach ($Line in $urlcontent){
        # send the current line to output
        if ($Line -notmatch "from django.urls import"){
            $UrlsModified += $Line
            if ($Line -match "from django.contrib import admin")
            {
                #Add Lines after the selected pattern
                $UrlsModified += "from django.urls import path, include"
            }

            elseif ($Line -match "admin.site.urls")
            {
                #Add Lines after the selected pattern
                $UrlsModified += "    path('', include('$app_name.urls')),"
                $UrlsModified += "    path('__debug__/', include('debug_toolbar.urls')),"
            }
        }
    } Set-Content -encoding utf8 $urlPath $UrlsModified

    # Create example.env and extract secret key
    Write-Output "Creating example.env file"

    if ($new_wkdir_folder -eq 'y'){
        Set-Location ..
    } else{
        Set-Location ..
        Set-Location ..
    }

    New-Item  'example.env' -ItemType File
    Write-Output "Extracting secret key"

    if ($new_wkdir_folder -eq 'y'){
        Set-Location .\$project_name
    } else{
        Set-Location .\$project_name
        Set-Location .\$project_name
    }

    $secretLine = findstr "SECRET_KEY" settings.py
    $secretLine = $secretLine.split(" ")
    $secretLine[-1] = $secretLine[-1].trim("'")
    $secretLine = -Join $secretLine
    # Add-Content $ParDir $secretLine

    Write-Output "Setting other environment variables"

    if ($new_wkdir_folder -eq 'y'){
        Set-Location ..
    } else{
        Set-Location ..
        Set-Location ..
    }

    # ENVIRONMENT VARIABLES
    $envlines = @(
        "$secretLine",
        "DEBUG=True",
        "ALLOWED_HOSTS=127.0.0.1",
        "DB_HOST=localhost",
        "DB_PORT=5432",
        "DB_NAME=",
        "DB_USER=postgres",
        "DB_PASS=postgres"
    )

    foreach ($_ in $envlines) {
        $_ | out-file -encoding utf8 example.env -Append
    }

    # Configure Settings.py
    Write-Output "Configuring settings file"

    if ($new_wkdir_folder -eq 'y'){
        Set-Location .\$project_name
    } else{
        Set-Location .\$project_name
        Set-Location .\$project_name
    }

    $settingscontent = Get-Content settings.py

    if ($new_wkdir_folder -eq 'y'){
        $settingsPath = Join-Path $PSScriptRoot $folder_name\$project_name\settings.py
    } else{
        $settingsPath = Join-Path $PSScriptRoot $folder_name\$project_name\$project_name\settings.py
    }

    $SettingsModified = @()
    Foreach ($Line in $settingscontent){
            # send the current line to output
            if ($Line -notmatch "SECRET_KEY" -AND $Line -notmatch "DEBUG = True" -AND $Line -notmatch "'DIRS':"){
                $SettingsModified += $Line

                if ($Line -match "from pathlib import Path")
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += 'import os'
                    $SettingsModified += 'from decouple import config'

                }

                elseif($Line -match "BASE_DIR = Path")
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += "TEMPLATES_DIR = os.path.join(BASE_DIR, 'templates')"
                    $SettingsModified += "STATIC_DIR = os.path.join(BASE_DIR, 'static')"
                    $SettingsModified += "MEDIA_DIR = os.path.join(BASE_DIR, 'media')"
                }

                elseif ($Line.Contains("secret key used"))
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += "SECRET_KEY = config('SECRET_KEY')"

                }

                elseif($Line -match "don't run with debug turned on in production!")
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += "DEBUG = config('DEBUG', default=True, cast=bool)"
                }

                elseif($Line -match "django.contrib.staticfiles")
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += "    'rest_framework',"
                    $SettingsModified += "    '$app_name',"
                    $SettingsModified += "    'debug_toolbar',"
                    $SettingsModified += "    'dbbackup',"
                    $SettingsModified += "    'django_filters',"
                }

                elseif($Line -match "MIDDLEWARE = ")
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += "    'debug_toolbar.middleware.DebugToolbarMiddleware',"
                }

                elseif($Line -match "'BACKEND': 'django.template.backends.django.DjangoTemplates'")
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += "        'DIRS': [TEMPLATES_DIR, ],"
                }

                elseif($Line -match "WSGI_APPLICATION = '$project_name.wsgi.application'")
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += " "
                    $SettingsModified += " "
                    $SettingsModified += "# DATABASES = {"
                    $SettingsModified += "#     'default': {"
                    $SettingsModified += "#         'ENGINE': 'django.db.backends.postgresql_psycopg2',"
                    $SettingsModified += "#         'NAME': config('DB_NAME'),"
                    $SettingsModified += "#         'USER': config('DB_USER'),"
                    $SettingsModified += "#         'PASSWORD': config('DB_PASS'),"
                    $SettingsModified += "#         'HOST': config('DB_HOST'),"
                    $SettingsModified += "#         'PORT': config('DB_PORT'),"
                    $SettingsModified += "#     }"
                    $SettingsModified += "# }"
                }

                elseif($Line -match "STATIC_URL = 'static/'")
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += "STATIC_ROOT = STATIC_DIR"
                    $SettingsModified += " "
                    $SettingsModified += "# MEDIA files"
                    $SettingsModified += "MEDIA_URL = 'media/'"
                    $SettingsModified += "MEDIA_ROOT = MEDIA_DIR"
                }

                elseif ($Line.Contains("DEFAULT_AUTO_FIELD"))
                {
                    #Add Lines after the selected pattern
                    $SettingsModified += " "
                    $SettingsModified += "DBBACKUP_STORAGE = 'django.core.files.storage.FileSystemStorage'"
                    $SettingsModified += "DBBACKUP_STORAGE_OPTIONS = {'location': os.path.join(BASE_DIR, 'backup/')}"
                    $SettingsModified += " "
                    $SettingsModified += "INTERNAL_IPS = ["
                    $SettingsModified += "    # ..."
                    $SettingsModified += "    '127.0.0.1',"
                    $SettingsModified += "    # ..."
                    $SettingsModified += "]"
                }

            }
        } Set-Content -encoding utf8 $settingsPath $SettingsModified

    # Finishing Off
    if ($new_wkdir_folder -eq 'y'){
        Set-Location ..
    } else{
        Set-Location ..
        Set-Location ..
    }

    Write-Output "Finishing off"
    Set-Location .\'venv'
    Set-Location .\'Lib'
    Set-Location .\'site-packages'
    Set-Location .\'dbbackup'

    $backupcontent = Get-Content apps.py

    $backupPath = Join-Path $PSScriptRoot $folder_name\venv\Lib\site-packages\dbbackup\apps.py

    $backupModified = @()
    Foreach ($Line in $backupcontent){
        # send the current line to output
        if ($Line -notmatch "from django.utils.translation import ugettext_lazy as _"){
            $backupModified += $Line

            if ($Line -match "from django.apps import AppConfig")
            {
                #Add Lines after the selected pattern
                $backupModified += "from django.utils.translation import gettext_lazy as _"
            }
        }
    } Set-Content $backupPath $backupModified

    Write-Output "Making Migrations"
    if ($new_wkdir_folder -eq 'y'){
        $ParDir = Join-Path $PSScriptRoot $folder_name
    } else{
        $ParDir = Join-Path $PSScriptRoot $folder_name\$project_name
    }

    Set-Location $ParDir

    Try{
        python manage.py makemigrations
        Write-Output "Finishing Off and Starting Server"
    }
    Catch{
        Write-Output "An Error Occured"
    }
    Finally{
        python manage.py migrate
        Write-Output " "
        Write-Output "Thank you for running this script to start your Django App. Goodluck"
        Write-Output "DO NOT FORGET TO CREATE A .env FILE AND COPY THE EVERYTHING FROM example.env TO IT, THEN RUN 'python manage.py runsever' TO START SERVER"
        Write-Output " "
        Write-Output "Copyright --CHUKWUEMEKA NWAOMA (https://www.linkedin.com/in/joelchukks/)"
    }

}


# Check if folder already exists in path
if (Test-Path -Path $folder_root) {
    "Folder exists!"

    # Continue for existing folder
    $folder_exists = Read-Host -Prompt "If you want to continue with existing path. [Y] Yes  [N] No (default is 'No')"
    if ($folder_exists -eq 'y'){
        change_wkdir
        run_script

        Check if directory is empty
        if (Test-Path -Path $folder_root*){
            Write-Output "This directory is not empty and so cannot be used. Please delete ALL files in this directory and try again, or enter a new folder name instead. Thank You!"
            Write-Output " "
            Write-Output "Copyright --CHUKWUEMEKA NWAOMA (https://www.linkedin.com/in/joelchukks/)"
            break
        } else{
            run_script
        }

    } elseif ($folder_exists -ne 'y'){
        Write-Output " "
        Write-Output "You have chosen not to continue with the existing path."
        Write-Output  "You may try running this script again by entering a new folder name. Thank you!"
        Write-Output " "
        Write-Output "Copyright --CHUKWUEMEKA NWAOMA (https://www.linkedin.com/in/joelchukks/)"
        break
    }

} else{
    Write-Output "Creating Work Directory $folder_name"
    mkdir $folder_name
    change_wkdir
    run_script
}
# END