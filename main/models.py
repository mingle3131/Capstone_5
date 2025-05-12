from django.db import models
from django.conf import settings

# Create your models here.
# from django.contrib.auth.models import User # Remove direct import

class Profile(models.Model):
    # Point to the AUTH_USER_MODEL setting instead of the concrete User model
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    wallet_address = models.CharField(max_length=100, blank=True)
    name = models.CharField(max_length=100, blank=True)
    id_number = models.CharField(max_length=20, blank=True)
    phone = models.CharField(max_length=20, blank=True)
    address = models.CharField(max_length=200, blank=True)
    balance = models.PositiveIntegerField(default=0)  # 예치금 (원 단위)

    def __str__(self):
        # Access username through the related user object
        # Make sure your custom user model ('accounts.User') has a 'username' field or similar identifier
        return f"{self.user.username}의 프로필"
