from django.urls import path
from .views import auction_item_detail
from .views import today_auctions
from .views import all_auctions
from .views import create_auction_item


urlpatterns = [
    path('api/auctionitemdetail/', auction_item_detail),
    path('api/auctions/today/', today_auctions),
    path('api/auctions/', all_auctions),
    path('api/auctionpost/', create_auction_item),  # POST 요청 처리
]
