# Create your views here.
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .models import Profile
from django.shortcuts import render, get_object_or_404, redirect
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from decimal import Decimal # Import Decimal
from django.templatetags.static import static # Import static function
from django.conf import settings # Import settings
from app.models import Itemdetails, Casedetails
from django.utils import timezone # Add timezone import

def index(request):
    # Fetch auction items (Itemdetails)
    # You might want to add filtering here, e.g., by date or status
    # For example: auction_items = Itemdetails.objects.filter(auction_date__gte=timezone.now()).order_by('auction_date')
    auction_items = Itemdetails.objects.all() # Fetch all items for now
    context = {
        'auction_items': auction_items
    }
    return render(request, 'index.html', context) # Pass context to the template

def tender(request):
    return render(request, 'tender.html')

def auto_bid(request):
    return render(request, 'auto_bid.html')

@login_required
def mypage(request):
    profile = None
    try:
        # Get the profile associated with the logged-in user
        profile = request.user.profile 
    except Profile.DoesNotExist:
        # Handle cases where profile might not exist (e.g., for superuser or older accounts)
        # Optionally create one here, or pass None to the template
        pass 
        
    context = {
        'profile': profile
        # 'user' is automatically available in templates if using RequestContext
    }
    return render(request, 'mypage.html', context)

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
    profile = None
    if hasattr(request.user, 'profile'):
        profile = request.user.profile
    else:
        # Handle case where profile doesn't exist, maybe create it?
        # For now, redirect or show an error
        pass # Or redirect('some_error_page')

    if request.method == 'POST':
        amount = int(request.POST.get('amount'))
        if profile:
             profile.balance += amount
             profile.save()
        return redirect('charge')

    return render(request, 'charge.html', {'balance': profile.balance if profile else 0})
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

def get_favorite_properties(request):
    from main.models import FavoriteProperty 
    favorites = FavoriteProperty.objects.all()
    data = [
        {'case_number': fav.case_number, 'usage': fav.usage}
        for fav in favorites
    ]
    return JsonResponse({'success': True, 'favorites': data})