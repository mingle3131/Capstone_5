from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Itemdetails
from .serializers import ItemdetailsSerializer
from django.http import JsonResponse
from .models import Casedetails
from .serializers import CasedetailsSerializer

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

