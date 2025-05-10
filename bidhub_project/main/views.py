

# Create your views here.
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .models import Profile

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


def mypage(request):
    return render(request, 'mypage.html')

def bidform(request):
    return render(request, 'bidform.html')

def bid_submit(request):
    if request.method == 'POST':
        # 폼 처리 로직
        print(request.POST)  # 임시: 콘솔에 데이터 출력
        return redirect('bidform')  # 제출 후 다시 폼 페이지로 이동
    return redirect('bidform')  # GET으로 접근하면 다시 폼 페이지로

@login_required
def charge(request):
    if request.method == 'POST':
        amount = int(request.POST.get('amount'))
        profile = request.user.profile
        profile.balance += amount
        profile.save()
        return redirect('charge')

    return render(request, 'charge.html')