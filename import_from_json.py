import os
import json
import django
from datetime import datetime, date
import re

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from app.models import AuctionCase, AuctionItem, ClaimDistribution, PropertyListing, AuctionParty

def format_date(date_str):
    """Convert YYYYMMDD string to date object"""
    if date_str and len(date_str) == 8:
        return date(int(date_str[:4]), int(date_str[4:6]), int(date_str[6:8]))
    return None

def format_datetime(date_str, time_str):
    """Convert YYYYMMDD string and HHMM string to datetime object"""
    if not date_str or not time_str:
        return None
    
    try:
        if len(date_str) == 8 and len(time_str) == 4:
            return datetime(
                int(date_str[:4]), 
                int(date_str[4:6]), 
                int(date_str[6:8]),
                int(time_str[:2]),
                int(time_str[2:])
            )
    except ValueError:
        pass
    return None

def format_price(amount):
    """Format an integer price to a Korean style string with commas"""
    if amount is None:
        return None
    return f"{amount:,}"

def import_from_json():
    # Load JSON data
    with open('detail.json', 'r', encoding='utf-8') as file:
        data = json.load(file)
    
    if data['status'] != 200:
        print(f"Error in JSON data: {data['message']}")
        return
    
    auction_data = data['data']['dma_result']
    base_info = auction_data['csBaseInfo']
    
    # Extract case information
    case_number = base_info.get('userCsNo')
    case_name = base_info.get('csNm')
    court_name = base_info.get('cortOfcNm')
    filing_date = format_date(base_info.get('csRcptYmd'))
    responsible_dept = base_info.get('cortAuctnJdbnNm')
    claim_amount = format_price(base_info.get('clmAmt'))
    appeal_status = base_info.get('rletApalYn') == 'Y'
    
    # Get minimum bid price from the last auction date
    dspsl_info = auction_data.get('dspslGdsDxdyInfo', {})
    min_bid_price = format_price(dspsl_info.get('fstPbancLwsDspslPrc'))
    
    # Create AuctionCase
    auction_case, created = AuctionCase.objects.get_or_create(
        case_number=case_number,
        defaults={
            'case_name': case_name,
            'court_name': court_name,
            'filing_date': filing_date,
            'responsible_dept': responsible_dept,
            'claim_amount': claim_amount,
            'appeal_status': appeal_status,
            'minimum_bid_price': min_bid_price
        }
    )
    
    if created:
        print(f"Created AuctionCase: {case_number}")
    else:
        print(f"Found existing AuctionCase: {case_number}")
    
    # Extract item information
    dspsl_info = auction_data.get('dspslGdsDxdyInfo', {})
    item_number = dspsl_info.get('dspslGdsSeq')
    
    # Try to get object info
    obj_info = None
    if auction_data.get('gdsDspslObjctLst'):
        for obj in auction_data['gdsDspslObjctLst']:
            if obj.get('dspslGdsSeq') == item_number:
                obj_info = obj
                break
    
    # Get item purpose
    item_purpose = None
    if obj_info:
        # Try to get from mcl usage code (mid-level category)
        mcl_code = obj_info.get('mclDspslGdsLstUsgCd')
        if mcl_code == '21100':
            item_purpose = '다세대주택'
        elif mcl_code == '21200':
            item_purpose = '아파트'
        elif mcl_code == '21300':
            item_purpose = '연립주택'
        else:
            # Fallback to building type from detail
            bldg_detail = None
            if auction_data.get('bldSdtrDtlLstAll') and auction_data['bldSdtrDtlLstAll'][0]:
                for bldg in auction_data['bldSdtrDtlLstAll'][0]:
                    if bldg.get('rletDvsDts') == '전유':
                        bldg_detail = bldg.get('bldSdtrDtlDts', '')
                        if '주택' in bldg_detail:
                            item_purpose = '주택'
                        elif '아파트' in bldg_detail:
                            item_purpose = '아파트'
                        elif '사무소' in bldg_detail:
                            item_purpose = '사무소'
                        break
    
    if not item_purpose:
        item_purpose = dspsl_info.get('auctnGdsUsgCd', '기타')
    
    # Get valuation amount
    valuation_amount = format_price(dspsl_info.get('aeeEvlAmt'))
    
    # Get item status
    status_code = dspsl_info.get('auctnGdsStatCd')
    status_map = {
        '01': '매각공고',
        '02': '매각',
        '03': '낙찰',
        '04': '배당',
        '05': '종결'
    }
    item_status = status_map.get(status_code, '매각공고')
    
    # Get item note
    item_note = dspsl_info.get('dspslGdsRmk', '')
    
    # Get auction dates and results
    auction_dates = auction_data.get('gdsDspslDxdyLst', [])
    auction_failures = 0
    for auction in auction_dates:
        if auction.get('auctnDxdyRsltCd') == '002':  # 002 is failed auction
            auction_failures += 1
    
    # Get the next auction date
    auction_date = None
    for auction in auction_dates:
        if auction.get('auctnDxdyRsltCd') is None:
            auction_date = format_datetime(auction.get('dxdyYmd'), auction.get('dxdyHm'))
            break
    
    # Get document URLs
    item_spec_url = dspsl_info.get('dspslGdsSpcfcEcdocId', '')
    
    # Create AuctionItem
    auction_item, created = AuctionItem.objects.get_or_create(
        item_number=item_number,
        case_number=auction_case,
        defaults={
            'item_spec_url': item_spec_url,
            'item_purpose': item_purpose,
            'valuation_amount': valuation_amount,
            'item_note': item_note,
            'item_status': item_status,
            'auction_date': auction_date,
            'auction_failures': auction_failures
        }
    )
    
    if created:
        print(f"Created AuctionItem: {item_number}")
    else:
        print(f"Found existing AuctionItem: {item_number}")
    
    # Get auction dates for the item
    if len(auction_dates) >= 4:
        if len(auction_dates) >= 1 and auction_dates[0].get('auctnDxdyKndCd') == '01':
            auction_item.auction_date_1 = format_datetime(auction_dates[0].get('dxdyYmd'), auction_dates[0].get('dxdyHm'))
        if len(auction_dates) >= 2 and auction_dates[1].get('auctnDxdyKndCd') == '01':
            auction_item.auction_date_2 = format_datetime(auction_dates[1].get('dxdyYmd'), auction_dates[1].get('dxdyHm'))
        if len(auction_dates) >= 3 and auction_dates[2].get('auctnDxdyKndCd') == '01':
            auction_item.auction_date_3 = format_datetime(auction_dates[2].get('dxdyYmd'), auction_dates[2].get('dxdyHm'))
        if len(auction_dates) >= 4 and auction_dates[3].get('auctnDxdyKndCd') == '01':
            auction_item.auction_date_4 = format_datetime(auction_dates[3].get('dxdyYmd'), auction_dates[3].get('dxdyHm'))
        
        # Get decision dates
        for idx, auction in enumerate(auction_dates):
            if auction.get('auctnDxdyKndCd') == '02':  # Decision date
                related_idx = idx - 1 if idx > 0 else 0
                if related_idx == 0:
                    auction_item.decision_date_1 = format_datetime(auction.get('dxdyYmd'), auction.get('dxdyHm'))
                elif related_idx == 1:
                    auction_item.decision_date_2 = format_datetime(auction.get('dxdyYmd'), auction.get('dxdyHm'))
                elif related_idx == 2:
                    auction_item.decision_date_3 = format_datetime(auction.get('dxdyYmd'), auction.get('dxdyHm'))
                elif related_idx == 3:
                    auction_item.decision_date_4 = format_datetime(auction.get('dxdyYmd'), auction.get('dxdyHm'))
    
    auction_item.save()
    
    # Get location information
    location = None
    if obj_info:
        addr_parts = []
        if obj_info.get('adongSdNm'):
            addr_parts.append(obj_info['adongSdNm'])
        if obj_info.get('adongSggNm'):
            addr_parts.append(obj_info['adongSggNm'])
        if obj_info.get('adongEmdNm'):
            addr_parts.append(obj_info['adongEmdNm'])
        if obj_info.get('rprsLtnoAddr'):
            addr_parts.append(obj_info['rprsLtnoAddr'])
            
        # Add building name and details if available
        bldg_info = ""
        if obj_info.get('bldNm'):
            bldg_info += f" ({obj_info['adongEmdNm']},{obj_info['bldNm']})"
        
        if len(addr_parts) > 0:
            location = " ".join(addr_parts) + bldg_info
    
    if not location and obj_info and obj_info.get('userPrintSt'):
        location = obj_info['userPrintSt']
    
    # Get claim distribution deadline
    claim_deadline = None
    if auction_data.get('dstrtDemnInfo') and len(auction_data['dstrtDemnInfo']) > 0:
        claim_deadline = format_date(auction_data['dstrtDemnInfo'][0].get('dstrtDemnLstprdYmd'))
    
    # Create ClaimDistribution
    if location and claim_deadline:
        claim_distribution, created = ClaimDistribution.objects.get_or_create(
            case_number=auction_case,
            defaults={
                'location': location,
                'claim_deadline': claim_deadline
            }
        )
        
        if created:
            print(f"Created ClaimDistribution for case: {case_number}")
        else:
            print(f"Found existing ClaimDistribution for case: {case_number}")
    
    # Create PropertyListing
    listing_type = item_purpose
    
    # Get detailed building information
    details = ""
    if auction_data.get('bldSdtrDtlLstAll') and auction_data['bldSdtrDtlLstAll'][0]:
        for bldg in auction_data['bldSdtrDtlLstAll'][0]:
            details += f"{bldg.get('rletDvsDts', '건물')}의 표시\n"
            details += f"{bldg.get('bldSdtrDtlDts', '')}\n\n"
    
    # Create PropertyListing
    if location:
        property_listing, created = PropertyListing.objects.get_or_create(
            case_number=auction_case,
            location=location,
            defaults={
                'listing_type': listing_type,
                'details': details.strip(),
                'final_result': '미종국' if dspsl_info.get('auctnDxdyGdsStatCd') == '00' else '종국'
            }
        )
        
        if created:
            print(f"Created PropertyListing for case: {case_number}")
        else:
            print(f"Found existing PropertyListing for case: {case_number}")

if __name__ == '__main__':
    import_from_json() 