from django.urls import path
from . import views

urlpatterns = [
    path('cases/', views.all_cases, name='all_cases'),
    path('item/<int:item_id>', views.auction_detail, name='auction_detail'),
    path('api/auctions/', views.auction_list),
]
