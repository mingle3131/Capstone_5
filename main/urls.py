from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('login/', views.login, name='login'),
    path('join/', views.join, name='join'),
    path('tender/', views.tender, name='tender'),
    path('charge/', views.charge, name='charge'),
    path('auto_bid/', views.auto_bid, name='auto_bid'),
]

