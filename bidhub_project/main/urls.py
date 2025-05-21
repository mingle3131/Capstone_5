from django.urls import path
from . import views
import django.contrib.auth.views

urlpatterns = [
    path('', views.index, name='index'),
    path('login/', views.login, name='login'),
    path('join/', views.join, name='join'),
    path('tender/', views.tender, name='tender'),
    path('charge/', views.charge, name='charge'),
    path('auto_bid/', views.auto_bid, name='auto_bid'),
    path('mypage/', views.mypage, name='mypage'),
    path('bidform/', views.bidform, name='bidform'),
    path('bidform/submit/', views.bid_submit, name='bid_submit'),
    path('logout/', django.contrib.auth.views.LogoutView.as_view(), name='logout'),
    path('mypage/', views.mypage, name='mypage'),
    path('bid_history/', views.bid_history, name='bid_history'),
    path('refund/', views.refund, name='refund'),
]

