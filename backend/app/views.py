from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Itemdetails
from .serializers import ItemdetailsSerializer
from django.http import JsonResponse
from .models import Casedetails
from .serializers import CasedetailsSerializer
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import os

@api_view(['GET'])
def all_cases(request):
    cases = Casedetails.objects.all()
    serializer = CasedetailsSerializer(cases, many=True)
    return Response(serializer.data)


def auction_detail(request, item_id):
    item = Itemdetails.objects.get(item_id=item_id)
    case = item.case

    data = {
        'item': {
            'item_id': item.item_id,
            'auction_notice_url': item.auction_notice_url,
            'item_purpose': item.item_purpose,
            'valuation_amount': float(item.valuation_amount),
            'item_status': item.item_status,
            'court_date': item.court_date,
        },
        'case': {
            'case_id': case.case_id,
            'case_name': case.case_name,
            'court_name': case.court_name,
            'filing_date': case.filing_date,
            'start_date': case.start_date,
            'claim_amount': float(case.claim_amount),
        },
        'claims': list(case.claimdetails_set.values('list_id', 'address', 'claim_end_date')),
        'parties': list(case.partydetails_set.values('party_id', 'party_type', 'party_name')),
        'listings': list(case.listingdetails_set.values('list_id', 'address', 'list_type', 'remarks')),
    }

    return JsonResponse(data)

def auction_list(request):
    court_name = request.GET.get('court_name')
    
    items = Itemdetails.objects.select_related('case').all()

    if court_name:
        items.filter(case__court_name=court_name)

    data = []
    for item in items:
        data.append({
            'case_id': item.case.case_id if item.case else None,
            'min_bid': float(item.valuation_amount) if item.valuation_amount is not None else None,
            'auction_failures': item.auction_failures,
            'deadline': item.court_date.strftime('%Y-%m-%d %H:%M') if item.court_date else None,
        })

    return JsonResponse(data, safe=False)

@api_view(['POST'])
def upload_property_image(request, item_id):
    try:
        item = Itemdetails.objects.get(item_id=item_id)
        image_file = request.FILES.get('image')
        
        if image_file:
            # 이미지 파일 저장
            path = default_storage.save(f'property_images/{item_id}_{image_file.name}', ContentFile(image_file.read()))
            # 이미지 필드 업데이트
            item.item_image = path
            item.save()
            
            return Response({
                'success': True,
                'message': '이미지가 성공적으로 업로드되었습니다.',
                'image_url': default_storage.url(path)
            })
        else:
            return Response({
                'success': False,
                'message': '이미지 파일이 제공되지 않았습니다.'
            }, status=400)
            
    except Itemdetails.DoesNotExist:
        return Response({
            'success': False,
            'message': '해당 매물을 찾을 수 없습니다.'
        }, status=404)
    except Exception as e:
        return Response({
            'success': False,
            'message': str(e)
        }, status=500)

@api_view(['POST'])
def bulk_upload_images(request, item_id):
    try:
        item = Itemdetails.objects.get(item_id=item_id)
        images = request.FILES.getlist('images')
        
        if not images:
            return Response({
                'success': False,
                'message': '이미지 파일이 제공되지 않았습니다.'
            }, status=400)
            
        uploaded_images = []
        for image in images:
            # 이미지 파일 저장
            path = default_storage.save(f'property_images/{item_id}_{image.name}', ContentFile(image.read()))
            # URL 저장
            image_url = default_storage.url(path)
            uploaded_images.append({
                'filename': image.name,
                'url': image_url
            })
            
        # 여러 이미지 URL을 저장할 수 있도록 item_image_url 필드 업데이트
        if item.item_image_url:
            existing_urls = item.item_image_url.split(',')
            new_urls = [img['url'] for img in uploaded_images]
            item.item_image_url = ','.join(existing_urls + new_urls)
        else:
            item.item_image_url = ','.join([img['url'] for img in uploaded_images])
        
        item.save()
        
        return Response({
            'success': True,
            'message': f'{len(uploaded_images)}개의 이미지가 성공적으로 업로드되었습니다.',
            'uploaded_images': uploaded_images
        })
            
    except Itemdetails.DoesNotExist:
        return Response({
            'success': False,
            'message': '해당 매물을 찾을 수 없습니다.'
        }, status=404)
    except Exception as e:
        return Response({
            'success': False,
            'message': str(e)
        }, status=500)