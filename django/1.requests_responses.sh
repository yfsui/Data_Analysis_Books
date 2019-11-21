
Django documentation
https://docs.djangoproject.com/en/2.2/

# ============= Create a poll application ============= 

# It’ll consist of two parts:
# - A public site that lets people view polls and vote in them.
# - An admin site that lets you add, change, and delete polls.


$ mkdir poll                        # create a new directory called "poll"
$ cd poll/

# ============= Create & Activate virtual environment =====================

# Dependency problem: software packages which have dependencies on specific versions of other software packages
# e.g. need version 2 for this project but version 3 for another

# Solve dependency problems by creating different virtual environments
# Create a new virtual environment for a new project
# We'll have a copy of python executables in each environment

$ python3 -m venv envpoll        	 # create a new virtual environment called "envpoll" for our project
$ ls                            	 # show "envpoll"

$ source envpoll/bin/activate   	 # activate virtual environment
$ pip freeze 	                     # now show nothing

$ pip install -U pip                 # upgrade pip, "U" for update
$ pip install django                 # install django
$ pip freeze                         # show django and other two dependencies 
$ python -m django --version         # show the version of django installed



# ============= Create a project: initial setup =====================

# If this is your first time using Django, you’ll need to auto-generate some code that establishes a Django project.
# Project is a directory of code that contains all the settings for an instance of Django, 
# including database configuration, Django-specific options and application-specific settings.

# "startproject" creates a Django project directory structure for the given project name in the current directory or the given destination.
# By default, the new directory contains manage.py and a project package (containing a settings.py and other files).

$ django-admin startproject mysite          # create a "mysite" directory in your current directory
$ ls                                        # show envpoll and mysite

$ cd mysite/
$ ls                                        # show manage.py, mysite, db.sqlite3

# inner "mysite/" directory is the actual Python package for your project
$ less mysite/ + press "tab" twice          # show -> __init__.py   settings.py   urls.py   wsgi.py
# __init__.py: an empty file that tells Python that this directory should be considered a Python package
# settings.py: settings/configuration for this Django project
# urls.py:     URL declarations for this Django project; a “table of contents” of your Django-powered site
# wsgi.py:     an entry-point for WSGI-compatible web servers to serve your project



# ============= Start the Django development server =====================

# A lightweight Web server written purely in Python

# change into the outer mysite directory
$ cd ..              
$ cd mysite/       
$ ls                                        # show manage.py and mysite
$ sudo /home/ys3273/poll/envpoll/bin/python manage.py runserver 0.0.0.0:80
# Go back to external IP -> show "DisallowedHost"

$ pwd                                       # return /home/ys3273/poll/mysite/mysite
$ vim settings.py                           # change allowed host to ['*']
# Go back to external IP -> show "Congratulations!" with a little rocket :)
# Now that your environment – a “project” – is set up


# ============= Create the Polls app  =====================

# Each application you write in Django consists of a Python package that follows a certain convention. 
# Django comes with a utility that automatically generates the basic directory structure of an app, 
# so you can focus on writing code rather than creating directories.

# Difference between a project and an app? 
# An app is a Web application that does something (e.g., a Weblog system, a database of public records or a simple poll app)
# A project is a collection of configuration and apps for a particular website. 
# A project can contain multiple apps. 
# An app can be in multiple projects.

# To create your app, make sure you’re in the same directory as manage.py
# so that it can be imported as its own top-level module, rather than a submodule of mysite.
# The directory with  manage.py This is the root directoy of project

$ python manage.py startapp polls 
$ ls    									 # show -> db.sqlite3  manage.py  mysite  polls

# "polls" directory structure will house the poll application.
$ cd polls/
$ ls  


# ============= Write your first view =====================

$ vim views.py               # import and def "index" view

		from django.http import HttpResponse

		def index(request):
		    return HttpResponse("Hello, world. You're at the polls index.")


# ============= Map view to a URL =====================

# To call the view, we need to map it to a URL - and for this we need a URLconf.
# Create a URLconf in the polls directory: polls/urls.py
$ vim urls.py

		from django.urls import path
		from . import views

		urlpatterns = [
		    path('', views.index, name='index'),
		]

# path() function is passed four arguments
# - two required: route, view
# - two optional: kwargs, name

# route: a string that contains a URL pattern. 
# When processing a request, Django starts at the first pattern in urlpatterns and makes its way down the list, 
# comparing the requested URL against each pattern until it finds one that matches.

# view: When Django finds a matching pattern,
# it calls the specified view function with an HttpRequest object as the first argument and any “captured” values from the route as keyword arguments.
# "views.index" sends back this http response


# Point the root URLconf at the polls.urls module.
$ cd ..          			# back to ~/poll/mysite: root directory (where manage.py is in)
$ vim mysite/urls.py     	# root URLconf

		from django.contrib import admin
		from django.urls import include, path

		urlpatterns = [
		    path('polls/', include('polls.urls')),  # point the root URLconf at the polls.urls
		    path('admin/', admin.site.urls),
		]

# include() function allows referencing other URLconfs
# Whenever Django encounters include(), it chops off whatever part of the URL matched up to that point 
# and sends the remaining string to the included URLconf for further processing.

# include() makes it easy to plug-and-play URLs. 
# Since polls are in their own URLconf (polls/urls.py), they can be placed under “/polls/” or “/content/polls/”, 
# or any other path root, and the app will still work.
# Always use include() when you include other URL patterns


$ cd ..          			# back to ~/poll/mysite
$ sudo /home/ys3273/project/envpoll/bin/python manage.py runserver 0.0.0.0:80
# Go back to external IP: http://35.245.82.219/polls/ 
# -> show the text defined in the "index" view: "Hello, world. You're at the polls index."

