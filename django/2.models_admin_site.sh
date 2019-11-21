https://docs.djangoproject.com/en/2.2/intro/tutorial02/
$ cd poll/
$ source envpoll/bin/activate
$ cd mysite/


# ================ Database setup ================

$ vim mysite/settings.py


# DATABASES dict:
# 'ENGINE': By default, the configuration uses SQLite. If you’re just interested in trying Django, this is the easiest choice. 
# SQLite is included in Python, so you won’t need to install anything else to support your database. 
# When starting your real project, you may want to use a more scalable database like PostgreSQL.

# 'NAME': the name of your database
# If you’re using SQLite, the database will be a file on your computer: full absolute path, including filename
# Default value: os.path.join(BASE_DIR, 'db.sqlite3') will store the file in your project directory.


# Change time zone
		TIME_ZONE = 'America/New_York'

# INSTALLED_APPS: holds the names of all Django applications that are activated in this Django instance. 
# Apps can be used in multiple projects, and you can package and distribute them for use by others in their projects.
# Common applications are included by default.



# Some of these applications make use of at least one database table, 
# so we need to create the tables in the database before we can use them.

$ python manage.py migrate
# The migrate command looks at apps in the INSTALLED_APPS setting, 
# and creates any necessary database tables according to the database settings in your mysite/settings.py file and the database migrations shipped with the app




# ================ Create models ================

# Model: contains database layout, essential fields and behaviors of the data

# Three steps to make model changes:
# 1. Change your models (in models.py)
# 2. Create migrations for those changes: python manage.py makemigrations
# 3. Apply those changes to the database: python manage.py migrate


# === 1. Change your models (in models.py) ===

$ pwd                        # /home/ys3273/poll/mysite/polls
$ vim models.py 

# We’ll create two models: Question and Choice. 
# - A Question has a question and a publication date. 
# - A Choice has two fields: the text of the choice and a vote tally 记录
# Each Choice is associated with a Question.

		from django.db import models

		class Question(models.Model):
		    question_text = models.CharField(max_length=200)
		    pub_date = models.DateTimeField('date published')

		class Choice(models.Model):
		    question = models.ForeignKey(Question, on_delete=models.CASCADE)
		    choice_text = models.CharField(max_length=200)
		    votes = models.IntegerField(default=0)

# Each model is represented by a class that subclasses django.db.models.Model. 
# Each model has a number of class variables, each of which represents a database field in the model.

# Column names (machine-readable): question_text, pub_date, ...
# You can use an optional first positional argument to a Field to designate a human-readable name (e.g. 'date published')

# Some Field classes have required arguments. 
# e.g. CharField requires that you give it a max_length.

# ForeignKey: define table relationship



# To include the app in our project, we need to add a reference to its configuration class in the INSTALLED_APPS setting.
$ vim settings.py            # pwd: /home/ys3273/poll/mysite/mysite

		INSTALLED_APPS = [
		    'polls.apps.PollsConfig',
		    'django.contrib.admin',
		    'django.contrib.auth',
		    'django.contrib.contenttypes',
		    'django.contrib.sessions',
		    'django.contrib.messages',
		    'django.contrib.staticfiles',
		]


# === 2.Create migrations for those changes ===

# Migrations are how Django stores changes to your models (and thus your database schema) 
$ cd ..                                    # ~/poll/mysite
$ python manage.py makemigrations polls

# Returns:
		# Migrations for 'polls':
		#   polls/migrations/0001_initial.py
		#     - Create model Question
		#     - Create model Choice

$ python manage.py sqlmigrate polls 0001     # takes migration names and returns what SQL that migration would run (vary depending on the database)


# === 3. Apply changes to the database ===

# The migrate command takes all the migrations that haven’t been applied and runs them against your database
# synchronizing the changes you made to your models with the schema in the database.
$ python manage.py migrate 




# ================ Explore the database API ================

$ python manage.py shell    					    # invoke interactive Python shell 

In: from polls.models import Choice, Question       # import the model classes we just wrote

In: Question.objects.all() 							# objects.all() displays all the questions in the database
# Out: <QuerySet []>								# no questions are in the system yet

# Create a new Question.
# Support for time zones is enabled in the default settings file, so
# Django expects a datetime with tzinfo for pub_date. 
# Use timezone.now() instead of datetime.datetime.now() and it will do the right thing.
In: from django.utils import timezone
In: q = Question(question_text="What's new?", pub_date=timezone.now())
In: q.save()     # Save the object into the database

In: q.id   		 
# Out: 1

In: q.question_text 	
# Out: "What's new?"

In: q.pub_date          
# Out: datetime.datetime(2019, 11, 17, 20, 1, 17, 692704, tzinfo=<UTC>)

In: q.question_text = "What's up?"     # change values and save                                                  
In: q.save()

In: Question.objects.all() 			   
# Out: <QuerySet [<Question: Question object (1)>]>        # not useful, def __str__ to fix it

In: exit()



# === Define representation of Question object ===

$ cd polls/
$ vim models.py

		import datetime
		from django.db import models
		from django.utils import timezone

		class Question(models.Model):
		    # ...
		    def __str__(self):
		        return self.question_text

		    def was_published_recently(self):
        		return self.pub_date >= timezone.now() - datetime.timedelta(days=1)

		class Choice(models.Model):
		    # ...
		    def __str__(self):
		        return self.choice_text


# Go back to shell to test
$ cd ..
$ python manage.py shell 


>>> from polls.models import Choice, Question       

>>> Question.objects.all() 	
# <QuerySet [<Question: What's up?>]> 



# === Get data, filter ===

>>> Question.objects.filter(id=1)                                                         
# <QuerySet [<Question: What's up?>]>

>>> Question.objects.filter(question_text__startswith='What')                             
# <QuerySet [<Question: What's up?>]>

>>> from django.utils import timezone
>>> current_year = timezone.now().year
>>> Question.objects.get(pub_date__year=current_year)   # Get the question that was published this year.
# <Question: What's up?>

>>> Question.objects.get(pk=1)  # primary-key exact lookups, equivalent to Question.objects.get(id=1)
# <Question: What's up?>

>>> q = Question.objects.get(pk=1)
>>> q.was_published_recently()
# True




# === Give the Question a couple of Choices ===

>>> q.choice_set.all()
# <QuerySet []>

# Create three choices.
>>> q.choice_set.create(choice_text='Not much', votes=0)
# <Choice: Not much>
>>> q.choice_set.create(choice_text='The sky', votes=0)
# <Choice: The sky>
>>> c = q.choice_set.create(choice_text='Just hacking again', votes=0)

# Question objects get access to Choice objects.
>>> q.choice_set.all()                                                                   
# <QuerySet [<Choice: Not much>, <Choice: The sky>, <Choice: Just hacking again>]>

>>> q.choice_set.count()                                                                 
# 3

# Choice objects also have API access to their related Question objects.
>>> c.question                                                                            
# <Question: What's up?>


# Use double underscores to separate relationships. This works as many levels deep as you want; there's no limit.
# Find all Choices for any question whose pub_date is in this year
>>> Choice.objects.filter(question__pub_date__year=current_year)
# <QuerySet [<Choice: Not much>, <Choice: The sky>, <Choice: Just hacking again>]>

# Delete one of the choices
>>> c = q.choice_set.filter(choice_text__startswith='Just hacking')
>>> c.delete()


# ==================== Django Admin =====================

# Generating admin sites for your staff or clients to add, change, and delete content is tedious work that doesn’t require much creativity. 
# For that reason, Django entirely automates creation of admin interfaces for models.

# Create an admin user who can login to the admin site
$ python manage.py createsuperuser
Username (leave blank to use 'ys3273'): admin
Email address: anniesui9627@gmail.com
Password: polls9627


# Start the development server 
$ sudo /home/ys3273/project/envpoll/bin/python manage.py runserver 0.0.0.0:80
# Go back to external IP: http://35.245.82.219/admin/
# Login using admin and polls9627
# See Django admin index page. "groups" and "users" are provided by django.contrib.auth, the authentication framework shipped by Django.



# ==================== Make the polls app modifiable in the admin =====================

# Tell the admin that Question objects have an admin interface: register "Question" model in admin

$ vim polls/admin.py

		from django.contrib import admin
		from .models import Question

		admin.site.register(Question)

# Go back to external IP: polls app displayed
# Click “Questions”
# Now you’re at the “change list” page for questions. This page displays all the questions in the database and lets you choose one to change it. 

# Click the “What’s up?” question to edit it:
# * Save – Saves changes and returns to the change-list page for this type of object.
# * Save and continue editing – Saves changes and reloads the admin page for this object.
# * Save and add another – Saves changes and loads a new, blank form for this type of object.
# * Delete – Displays a delete confirmation page.

# Change the “Date published” by clicking the “Today” and “Now” shortcuts. 
# Click “Save and continue editing.”
# Click “History”: see all changes made to this object via the Django admin




