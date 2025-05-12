from django.contrib import admin
from .models import Itemdetails

@admin.register(Itemdetails)
class ItemdetailsAdmin(admin.ModelAdmin):
    list_display = ('item_id', 'item_purpose', 'item_status')
    search_fields = ('item_id', 'item_purpose')
    list_filter = ('item_status',)
