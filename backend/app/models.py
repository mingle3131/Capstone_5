from django.db import models

class AuctionItem(models.Model):
    case_number = models.CharField(max_length=50)  # 사건번호
    item_number = models.IntegerField()            # 물건번호
    item_type = models.CharField(max_length=50)    # 물건종류 (ex: 단독주택)

    appraised_price = models.BigIntegerField()     # 감정평가액
    min_price = models.BigIntegerField()           # 최저매각가격
    bid_method = models.CharField(max_length=50)   # 입찰방법 (ex: 기일입찰)

    auction_date = models.DateTimeField()          # 매각기일
    auction_location = models.CharField(max_length=200)

    address_road = models.CharField(max_length=200)     # 목록 1 소재지
    address_landlot = models.CharField(max_length=200)  # 목록 2 소재지

    agency = models.CharField(max_length=100)            # 담당 기관
    officer = models.CharField(max_length=50)            # 담당자

    post_date = models.DateField()                       # 경매게시일
    claim_amount = models.BigIntegerField()              # 청구금액

    # 이미지 경로 (멀티 이미지 → 별도 테이블로 분리 가능)
    # 기본적으로 S3 등 연동 시 FileField/ImageField 사용
    images = models.JSONField(blank=True, null=True)     # 리스트 형태로 저장

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.case_number}-{self.item_number}"


class AuctionSchedule(models.Model):
    item = models.ForeignKey(AuctionItem, on_delete=models.CASCADE, related_name="schedules")
    date = models.DateTimeField()                        # 기일
    schedule_type = models.CharField(max_length=50)      # 기일종류
    location = models.CharField(max_length=200)          # 기일장소
    min_price = models.BigIntegerField()                 # 최저매각가격
    result = models.CharField(max_length=50)             # 기일결과 (유찰, 매각 등)

    def __str__(self):
        return f"{self.item.case_number} - {self.date.strftime('%Y-%m-%d')}"
