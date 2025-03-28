import json
from django.http import JsonResponse
from .models import AuctionItem
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt

#매물의 상세정보 출력 
def auction_item_detail(request):
    item = AuctionItem.objects.first()

    # 스케줄도 함께 가져오기
    schedules = item.schedules.all().values(
        'date', 'schedule_type', 'location', 'min_price', 'result'
    )

    data = {
        'case_number': item.case_number,
        'item_number': item.item_number,
        'type': item.item_type,
        'min_price': item.min_price,
        'address_road': item.address_road,              
        'address_landlot': item.address_landlot,        
        'auction_date': item.auction_date,
        'images': item.images,
        'schedules': list(schedules),
    }
    return JsonResponse(data)


#날짜가 오늘인 경매 매물 json 출력
def today_auctions(request):
    today = timezone.now().date()
    items = AuctionItem.objects.filter(
        auction_date__date=today,
        bid_method="기일입찰"
    )

    data = []

    for item in items:
        bid_count = item.schedules.count()  # 또는 다른 기준으로 집계

        data.append({
            "case_number": item.case_number,
            "min_price": item.min_price,
            "bid_count": bid_count,
            "auction_time": item.auction_date.strftime('%H:%M'),
            "notice_time": "09:00",  # 공시시간 고정값 (또는 item.notice_time)
        })

    return JsonResponse(data, safe=False, json_dumps_params={'ensure_ascii': False})



#모든 매물 json 출력 
def all_auctions(request):
    items = AuctionItem.objects.all().order_by('-auction_date')

    data = []

    for item in items:
        data.append({
            "case_number": item.case_number,
            "item_number": item.item_number,
            "item_type": item.item_type,
            "min_price": item.min_price,
            "auction_date": item.auction_date.strftime('%Y-%m-%d %H:%M'),
            "address_road": item.address_road,
            "address_landlot": item.address_landlot,
            "bid_method": item.bid_method,
        })

    return JsonResponse(data, safe=False, json_dumps_params={'ensure_ascii': False})

    


@csrf_exempt  # 프론트에서 직접 요청할 수 있게 CSRF 우회 (개발용 한정)
def create_auction_item(request):
    if request.method == 'POST':
        try:
            body = json.loads(request.body)

            item = AuctionItem.objects.create(
                case_number=body.get("case_number"),
                item_number=body.get("item_number"),
                item_type=body.get("item_type"),
                appraised_price=body.get("appraised_price"),
                min_price=body.get("min_price"),
                bid_method=body.get("bid_method"),
                auction_date=body.get("auction_date"),
                auction_location=body.get("auction_location"),
                address_road=body.get("address_road"),
                address_landlot=body.get("address_landlot"),
                agency=body.get("agency"),
                officer=body.get("officer"),
                post_date=body.get("post_date"),
                claim_amount=body.get("claim_amount"),
                images=body.get("images", [])
            )

            return JsonResponse({"status": "success", "id": item.id}, status=201)

        except Exception as e:
            return JsonResponse({"status": "error", "message": str(e)}, status=400)

    return JsonResponse({"message": "Only POST allowed"}, status=405)    