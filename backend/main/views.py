from django.shortcuts import render, get_object_or_404, redirect
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from decimal import Decimal # Import Decimal
from django.templatetags.static import static # Import static function
from django.conf import settings # Import settings
# Removed main.models imports as we are using app.models for detail view

# Imports from app.models based on your app/models.py structure
from app.models import Itemdetails, Casedetails

# HTML 템플릿 렌더링 함수들
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

def property_detail(request, property_id):
    try:
        item_details = Itemdetails.objects.get(item_id=property_id)
        case = item_details.case
        
        property_info = {
            'case_number': case.case_id if case else None,
            'case_name': case.case_name if case else None,
            'court': case.court_name if case else None,
            'receipt_date': case.filing_date if case else None,
            'responsible_dept': case.responsible_dept if case else None,
            'claim_amount': case.claim_amount if case else None,
            'appeal_status_display': '항고' if case and case.appeal_status == 1 else '미항고',
            'min_bid_price': item_details.valuation_amount,
            'specification_url': item_details.item_spec_url,
            'status_report_url': item_details.status_report_url,
            'appraisal_url': item_details.appraisal_url
        }
        
        # 문서 URL들을 컨텍스트에 추가
        document_urls = {
            'specification_url': item_details.item_spec_url,
            'status_report_url': item_details.status_report_url,
            'appraisal_url': item_details.appraisal_url
        }
        
        context = {
            'property_id': property_id,
            'property_info': property_info,
            'item_details': item_details,
            'case': case,
            'naver_maps_client_id': settings.NAVER_MAPS_CLIENT_ID,
            'document_urls': document_urls
        }
        
        return render(request, 'main/property_detail.html', context)
        
    except Itemdetails.DoesNotExist:
        return redirect('index')


# 백엔드 코드 추가
# 자동입찰 예약 API (fetch로 호출하는 POST용)
@csrf_exempt
def auto_bid_reservation(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            case_number = data.get('case_number') 
            bid_amount = data.get('bid_amount')
            reserve_time = data.get('reserve_time')
            print("✅ 예약 저장됨:")
            print(f"사건번호: {case_number}")
            return JsonResponse({'success': True, 'message': '예약이 저장되었습니다.'})
        except json.JSONDecodeError:
            return JsonResponse({'success': False, 'message': 'JSON 형식 오류'})
    return JsonResponse({'success': False, 'message': 'POST 요청만 허용됩니다.'})



def search_property(request):
    case_number_query = request.GET.get('case_number')
    try:
        prop = Casedetails.objects.get(pk=case_number_query) 
        return JsonResponse({
            'success': True,
            'case_number': prop.case_id,
            'usage': prop.case_name, 
            'court_name': prop.court_name
        })
    except Casedetails.DoesNotExist:
        return JsonResponse({'success': False, 'message': '매물을 찾을 수 없습니다.'})
    except ValueError: 
        return JsonResponse({'success': False, 'message': '유효하지 않은 사건번호 형식입니다.'})
    

@csrf_exempt
def auto_bid_reservation(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)

            case_number = data.get('case_number')
            bid_amount = data.get('bid_amount')
            reserve_time = data.get('reserve_time')
            is_active = data.get('is_active', False)

            # 입력값 검증
            if not case_number or not bid_amount or not reserve_time:
                return JsonResponse({'success': False, 'message': '모든 값을 입력해주세요.'})

            # 예약 정보 저장
            AutoBidReservation.objects.create(
                case_number=case_number,
                bid_amount=bid_amount,
                reserve_time=reserve_time,
                is_active=is_active
            )

            return JsonResponse({'success': True, 'message': '예약이 저장되었습니다.'})

        except json.JSONDecodeError:
            return JsonResponse({'success': False, 'message': 'JSON 형식 오류'})

    return JsonResponse({'success': False, 'message': 'POST 요청만 허용됩니다.'})


def get_favorite_properties(request):
    from main.models import FavoriteProperty 
    favorites = FavoriteProperty.objects.all()
    data = [
        {'case_number': fav.case_number, 'usage': fav.usage}
        for fav in favorites
    ]
    return JsonResponse({'success': True, 'favorites': data})