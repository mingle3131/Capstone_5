import os
import django
from decimal import Decimal
from datetime import date, datetime

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings') # Assumes your project is 'backend'
django.setup()

from app.models import AuctionCase, AuctionItem, ClaimDistribution, PropertyListing, AuctionParty

def populate_data():
    print("Starting data population...")

    # --- AuctionCase Data ---
    string_case_number = "2024타경110895"

    case_detail, case_created = AuctionCase.objects.get_or_create(
        case_number=string_case_number,
        defaults={
            'case_name': '부동산강제경매',
            'court_name': '서울중앙지방법원',
            'filing_date': date(2024, 9, 25),
            'responsible_dept': '경매10계',
            'claim_amount': '3억 3600만원',
            'appeal_status': False,
            'minimum_bid_price': '162,304,000원'
        }
    )
    if case_created:
        print(f"Created AuctionCase: {case_detail.case_number}")
    else:
        print(f"Found existing AuctionCase: {case_detail.case_number}")

    # --- AuctionItem Data ---
    item_number = 1
    item_detail, item_created = AuctionItem.objects.get_or_create(
        item_number=item_number,
        case_number=case_detail,
        defaults={
            'item_spec_url': 'CL45OT5882UD15VLKSHOLQGT_1736888503.pdf',
            'item_purpose': '다세대주택',
            'valuation_amount': '317,000,000',
            'item_note': '일괄매각',
            'item_status': '매각공고',
            'auction_date': datetime(2025, 5, 7, 10, 0, 0),
            'auction_failures': 3,
            
            # 추가 매각기일 정보
            'auction_date_1': datetime(2025, 1, 22, 10, 0, 0),
            'decision_date_1': datetime(2025, 1, 22, 11, 0, 0),
            'auction_date_2': datetime(2025, 2, 26, 10, 0, 0),
            'decision_date_2': datetime(2025, 2, 26, 11, 0, 0),
            'auction_date_3': datetime(2025, 4, 2, 10, 0, 0),
            'decision_date_3': datetime(2025, 4, 2, 11, 0, 0),
            'auction_date_4': datetime(2025, 5, 7, 10, 0, 0),
            'decision_date_4': datetime(2025, 5, 14, 11, 0, 0),
        }
    )
    if item_created:
        print(f"Created AuctionItem: {item_detail.item_number}")
    else:
        print(f"Found existing AuctionItem: {item_detail.item_number}")

    # --- ClaimDistribution Data ---
    claim_detail, claim_created = ClaimDistribution.objects.get_or_create(
        case_number=case_detail,
        defaults={
            'location': '서울특별시 동작구 상도동 209-9 / 서울특별시 동작구 양녕로25길 2-9 (상도동,더포레스트)',
            'claim_deadline': date(2024, 12, 9),
        }
    )
    if claim_created:
        print(f"Created ClaimDistribution for case: {case_detail.case_number}")
    else:
        print(f"Found existing ClaimDistribution for case: {case_detail.case_number}")

    # --- PropertyListing Data ---
    listing_detail, listing_created = PropertyListing.objects.get_or_create(
        case_number=case_detail,
        location='서울특별시 동작구 상도동 209-9 / 서울특별시 동작구 양녕로25길 2-9 (상도동,더포레스트)',
        listing_type='공동주택',
        defaults={
            'details': """1동부분의 건물의 표시
철근콘크리트구조 경사스라브지붕
5층 다세대주택
1층 193.28㎡ (연면적제외)
1층 16.76㎡
2층 172.56㎡
3층 172.56㎡
4층 148.92㎡
5층 123.74㎡
옥탑1층 17.02㎡ (연면적제외)

전유부분의 건물의 표시
철근콘크리트구조 45.1㎡""",
            'final_result': '미종국',
            'final_date': None,
        }
    )
    if listing_created:
        print(f"Created PropertyListing for case: {case_detail.case_number}")
    else:
        print(f"Found existing PropertyListing for case: {case_detail.case_number}")

    # --- AuctionParty Data ---
    party_detail, party_created = AuctionParty.objects.get_or_create(
        case_number=case_detail,
        party_name='이보라',
        party_type='임차인',
        defaults={
            'remarks': '',
        }
    )
    if party_created:
        print(f"Created AuctionParty for '이보라' in case: {case_detail.case_number}")
    else:
        print(f"Found existing AuctionParty for '이보라' in case: {case_detail.case_number}")

    print("Data population finished.")

if __name__ == '__main__':
    populate_data() 