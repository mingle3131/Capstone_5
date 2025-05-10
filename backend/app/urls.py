from django.urls import path
from . import views

urlpatterns = [
    path('cases/', views.all_cases, name='all_cases'),
    path('item/<int:item_id>', views.auction_detail, name='auction_detail'),
    path('auctions/', views.auction_list),
    path('api/properties/<int:item_id>/upload-image/', views.upload_property_image, name='upload_property_image'),
]
