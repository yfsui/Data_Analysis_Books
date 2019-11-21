https://docs.djangoproject.com/en/2.2/intro/tutorial03/
$ cd poll/
$ source envpoll/bin/activate
$ cd mysite/

# views.py for public interface
# A view is a “type” of Web page in your Django application 
# that generally serves a specific function and has a specific template.

# In our poll application, we’ll have the following four views:
# Question “index” page – displays the latest few questions.
# Question “detail” page – displays a question text, with no results but with a form to vote.
# Question “results” page – displays results for a particular question.
# Vote action – handles voting for a particular choice in a particular question.


# Each view is represented by a simple Python function (or method, in the case of class-based views). 
# Django will choose a view by examining the URL that’s requested (the part of the URL after the domain name).
# A URLconf maps URL patterns to views.


# ================ Write more views =====================

$ vim polls/views.py

		from django.http import HttpResponse

		def index(request):
		    return HttpResponse("Hello, world. You're at the polls index.")

		def detail(request, question_id):
		    return HttpResponse("You're looking at question %s." % question_id)

		def results(request, question_id):
		    response = "You're looking at the results of question %s."
		    return HttpResponse(response % question_id)

		def vote(request, question_id):
		    return HttpResponse("You're voting on question %s." % question_id)


# ================ Wire these new views into the polls.urls module ================ 

$ vim polls/urls.py

		from django.urls import path
		from . import views

		urlpatterns = [
		    # ex: /polls/
		    path('', views.index, name='index'),
		    # ex: /polls/5/
		    path('<int:question_id>/', views.detail, name='detail'), # to capture a value from the URL, use angle brackets
		    # ex: /polls/5/results/									 # int: a converter that determines what patterns should match this part of URL
		    path('<int:question_id>/results/', views.results, name='results'),
		    # ex: /polls/5/vote/
		    path('<int:question_id>/vote/', views.vote, name='vote'),
		] 

$ sudo ../envpoll/bin/python manage.py runserver 0.0.0.0:80
# Go back to external IP: http://35.245.82.219/polls/34/ 
# It’ll run the detail() method and display the ID you provide in the URL. 
# -> show You're looking at question 34.

# Go back to external IP: http://35.245.82.219/polls/34/vote/
# -> show You're voting on question 34.

# Go back to external IP: http://35.245.82.219/polls/34/results/
# -> show You're looking at the results of question 34.



# === How Django processes a request ===

# When somebody requests a page from your website – say, “/polls/34/”:
# 1. Django will load root URLconf module: mysite/urls.py 
# 2. Find the variable named urlpatterns
# 3. Run through each url pattern in order, stop at the first one that matches the requested URL:
#    After finding the match at 'polls/', it strips off the matching text ("polls/"), 
#    sends the remaining text "34/" to the ‘polls.urls’ URLconf for further processing. 
# 4. Then Django imports and calls the given view
#    There it matches '<int:question_id>/', call the function detail(request=<HttpRequest object>, question_id=34)
#    question_id=34 comes from <int:question_id>. Angle brackets “captures” part of the URL and sends it as a keyword argument to the view function




# ============================= View的两个作用 =========================== 

# Each view is responsible for doing one of two things: 
# - return an HttpResponse object
# - raise an exception such as Http404

# === (1). return an HttpResponse object ===

# change index view: displays the latest 5 poll questions, separated by commas
$ vim polls/views.py

		from django.http import HttpResponse
		from .models import Question

		def index(request):
		    latest_question_list = Question.objects.order_by('-pub_date')[:5]
		    output = ', '.join([q.question_text for q in latest_question_list])
		    return HttpResponse(output)

		def detail(request, question_id):
		    return HttpResponse("You're looking at question %s." % question_id)

		def results(request, question_id):
		    response = "You're looking at the results of question %s."
		    return HttpResponse(response % question_id)

		def vote(request, question_id):
		    return HttpResponse("You're voting on question %s." % question_id)


# Problem here: the page’s design is hard-coded in the view. 
# If you want to change the way the page looks, you’ll have to edit this Python code. 
# Solution: use Django’s template system to separate the design from Python by creating a template that the view can use.



# ================ Use Django’s template system ================

$ mkdir polls/templates         # create a directory called templates in polls directory
$ mkdir polls/templates/polls   # within polls, create another directory called polls


# === Template namespacing ===

# Why not putting our templates directly in polls/templates?
# Django chooses the first template whose name matches. 
# If you had a template with the same name in a different app, Django would be unable to distinguish between them. 
# Solution: namespacing templates - putting templates inside another directory named for the app itself.


# Create a html file as a template
$ vim polls/templates/polls/index.html    

		{% if latest_question_list %}
		    <ul>
		    {% for question in latest_question_list %}
		        <li><a href="/polls/{{ question.id }}/">{{ question.question_text }}</a></li>
		    {% endfor %}
		    </ul>
		{% else %}
		    <p>No polls are available.</p>
		{% endif %}



# Update index view in polls/views.py to use the template
$ vim polls/views.py

		from django.http import HttpResponse
		from django.template import loader
		from .models import Question

		def index(request):
		    latest_question_list = Question.objects.order_by('-pub_date')[:5]
		    template = loader.get_template('polls/index.html')  # load the template called polls/index.html and passes it a context
		    context = {
		        'latest_question_list': latest_question_list,   # context is a dict mapping template variable names to Python objects.
		    }
		    return HttpResponse(template.render(context, request))


# Go back to external IP: http://35.245.82.219/polls/
# -> show a bulleted-list containing the “What’s up” question. The link points to the question’s detail page.


# === A shortcut to load template, fill a context, return an HttpResponse object with the result of the rendered template ===

# render() function 
# 1st argument: request object 
# 2nd argument: template name 
# 3rd argument (optional): a dict

# Update views.py to use render() function
$ vim polls/views.py

		from django.shortcuts import render
		from .models import Question

		def index(request):
		    latest_question_list = Question.objects.order_by('-pub_date')[:5]
		    context = {'latest_question_list': latest_question_list}
		    return render(request, 'polls/index.html', context)



# === (2). raise an exception such as Http404 ===

# Update detail view - the page that displays the question text for a given poll
$ vim polls/views.py

		from django.http import Http404
		from django.shortcuts import render
		from .models import Question
		# ...
		def detail(request, question_id):
		    try:
		        question = Question.objects.get(pk=question_id)
		    except Question.DoesNotExist:
		        raise Http404("Question does not exist")
		    return render(request, 'polls/detail.html', {'question': question})



# === A shortcut to get() and raise Http404 === 

# Update views.py to use get_object_or_404()
# get_object_or_404 (django model, an arbitrary number of keyword arguments)

$ vim polls/views.py

		from django.shortcuts import get_object_or_404, render
		# ...
		def detail(request, question_id):
		    question = get_object_or_404(Question, pk=question_id)
		    return render(request, 'polls/detail.html', {'question': question})



# Create a template called polls/detail.html
$ vim polls/templates/polls/detail.html

		<h1>{{ question.question_text }}</h1>
		<ul>
		{% for choice in question.choice_set.all %}
		    <li>{{ choice.choice_text }}</li>
		{% endfor %}
		</ul>

# The template system uses dot-lookup syntax to access variable attributes
# e.g. {{ question.question_text }} 
# -> First Django does a dictionary lookup on the object question. 
# -> Failing that, it tries an attribute lookup – which works, in this case. 
# -> If attribute lookup had failed, it would’ve tried a list-index lookup.

# Method-calling happens in the {% for %} loop
# question.choice_set.all is interpreted as the Python code question.choice_set.all(), which returns an iterable of Choice objects




# ================== Removing hardcoded URLs in templates ======================

$ vim polls/templates/polls/index.html
		# When we wrote the link to a question in the polls/index.html template, the link was partially hardcoded like this:
		<li><a href="/polls/{{ question.id }}/">{{ question.question_text }}</a></li>				

# Hardcoding makes it challenging to change URLs on projects with a lot of templates
# Since you defined the name argument in the path() functions in the polls.urls module, you can remove a reliance on specific URL paths:

		<li><a href="{% url 'detail' question.id %}">{{ question.question_text }}</a></li>  # look up the URL definition as specified in polls.urls

$ vim polls/urls.py
		# {% url %} template tag calls the 'name' value in polls.urls: 
		...
		path('<int:question_id>/', views.detail, name='detail'),
		...


# If you want to change the URL of the polls detail view, you would change it in polls/urls.py instead of doing it in the template.
$ vim polls/urls.py
		...
		# added the word 'specifics'
		path('specifics/<int:question_id>/', views.detail, name='detail'),
		...


# ================== Namespacing URL names ================== 

# A djagno project may have many apps and they all have a detail view.
# How to let Django know which app view to create for a url when using the {% url %} template tag?
# Solution: add namespaces to URLconf


# Add an app_name in polls.urls to set the application namespace

$ vim polls/urls.py

		from django.urls import path
		from . import views

		app_name = 'polls'
		urlpatterns = [
		    path('', views.index, name='index'),
		    path('<int:question_id>/', views.detail, name='detail'),
		    path('<int:question_id>/results/', views.results, name='results'),
		    path('<int:question_id>/vote/', views.vote, name='vote'),
		]


# Change polls/index.html template: point at the namespaced detail view

$ vim polls/templates/polls/index.html

		<li><a href="{% url 'polls:detail' question.id %}">{{ question.question_text }}</a></li>


