pip install -r requirements.txt

이 명령어로 필요 패키지 한번에 설치 가능

mysql 설치 시 root 비밀번호 1q2w3e4r 권장 ( setting.py 설정 )

1) mysql에서 auctiondb 스키마 생성,

2) 이후 venv 터미널에서 python manage.py migrate 실행하면 auctiondb 에 필요 테이블들 자동으로 생성됩니다.

