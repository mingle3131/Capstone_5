from django.shortcuts import render

# Create your views here.
from django.shortcuts import render

def index(request):
    return render(request, 'index.html')

def join(request):
    return render(request, 'join.html')

def tender(request):
    return render(request, 'tender.html')

def charge(request):
    return render(request, 'charge.html')

def auto_bid(request):
    return render(request, 'auto_bid.html')

def login(request):
    return render(request, 'login.html')

def auto_bid(request):
    return render(request, 'auto_bid.html')
