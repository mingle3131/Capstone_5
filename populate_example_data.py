import os
import django
from decimal import Decimal
from datetime import date, datetime

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings') # Assumes your project is 'backend'
django.setup()

from app.models import Casedetails, Itemdetails, Claimdetails, Listingdetails, Partydetails

def populate_data():
    print("Starting data population...")

    # --- Casedetails Data ---
    # 사건번호 "2024타경110895" is a string. Casedetails.case_id is an Integer PK.
    # Using an arbitrary integer for Casedetails.case_id here.
    # The full string case number is prepended to case_name.
    # Consider adding a dedicated CharField for the string case number in your Casedetails model.
    db_case_id = 101 # Arbitrary integer PK for Casedetails
    string_case_number = "2024타경110895"

    case_detail, case_created = Casedetails.objects.get_or_create(
        case_id=db_case_id,
        defaults={
            'case_name': f'{string_case_number} - 부동산강제경매',
            'court_name': '서울중앙지방법원',
            'filing_date': date(2024, 9, 25),
            'start_date': date(2024, 9, 25), # Assuming start_date is same as filing_date
            'responsible_dept': '경매10계',
            'claim_amount': Decimal('336000000'), # 3억 3600만원
            'appeal_status': 0, # Assuming 0 means no appeal (matching '-')
        }
    )
    if case_created:
        print(f"Created Casedetails: {case_detail.case_id}")
    else:
        print(f"Found existing Casedetails: {case_detail.case_id}")

    # --- Itemdetails Data ---
    db_item_id = 1 # From URL /detail/1/
    item_detail, item_created = Itemdetails.objects.get_or_create(
        item_id=db_item_id,
        defaults={
            'case': case_detail,
            'auction_notice_url': None, # Not in example data
            'item_spec_url': f'https://example.com/property_specs/{db_item_id}', # Example URL
            'item_purpose': '공동주택', # From "목록구분"
            'valuation_amount': Decimal('317000000'), # 감정가 from bidding history example
            'item_note': '의 표시\n철근콘크리트구조 경사스라브지붕\n5층 다세대주택\n1층 193.28㎡ (연면적제외)\n1층 16.76㎡\n2층 172.56㎡\n3층 172.56㎡',
            'item_status': '유찰', # From bidding history example
            'court_date': datetime(2024, 7, 23, 10, 0, 0), # From bidding history
            'auction_failures': 1, # Assuming "유찰" means 1 failure
            'item_image': 'img/ex/01.png', # Example image path
        }
    )
    if item_created:
        print(f"Created Itemdetails: {item_detail.item_id}")
    else:
        print(f"Found existing Itemdetails: {item_detail.item_id}")

    # --- Claimdetails Data ---
    # Assuming one Claimdetails per Casedetails for this example
    claim_detail, claim_created = Claimdetails.objects.get_or_create(
        case=case_detail, # Link to the Casedetails instance
        defaults={
            # list_id is AutoField, no need to set
            'address': '서울특별시 동작구 상도동 209-9 / 서울특별시 동작구 양녕로25길 2-9 (상도동,더포레스트)',
            'claim_end_date': date(2024, 12, 9), # 배당요구종기일
        }
    )
    if claim_created:
        print(f"Created Claimdetails for case: {case_detail.case_id}")
    else:
        print(f"Found existing Claimdetails for case: {case_detail.case_id}")
        # Optionally update if needed:
        # claim_detail.address = '...'
        # claim_detail.claim_end_date = date(...)
        # claim_detail.save()


    # --- Listingdetails Data ---
    # Assuming one Listingdetails per Casedetails for this example
    listing_detail, listing_created = Listingdetails.objects.get_or_create(
        case=case_detail, # Link to the Casedetails instance
        defaults={
            # list_id is AutoField
            'address': '서울특별시 동작구 상도동 209-9 / 서울특별시 동작구 양녕로25길 2-9 (상도동,더포레스트)',
            'list_type': '공동주택', # From "목록구분"
            'remarks': '미종국', # From "비고"
        }
    )
    if listing_created:
        print(f"Created Listingdetails for case: {case_detail.case_id}")
    else:
        print(f"Found existing Listingdetails for case: {case_detail.case_id}")

    # --- Partydetails Data ---
    # Example: One interested party
    party_detail, party_created = Partydetails.objects.get_or_create(
        case=case_detail, # Link to Casedetails
        party_name='이보라', # To ensure uniqueness if multiple runs, combined with case and type
        party_type='임차인',
        defaults={
            # party_id is AutoField
        }
    )
    if party_created:
        print(f"Created Partydetails for '이보라' in case: {case_detail.case_id}")
    else:
        print(f"Found existing Partydetails for '이보라' in case: {case_detail.case_id}")

    print("Data population finished.")

if __name__ == '__main__':
    populate_data() 