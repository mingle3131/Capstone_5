from rest_framework import serializers
from .models import Casedetails, Itemdetails, Claimdetails, Partydetails, Listingdetails


class ClaimdetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Claimdetails
        fields = '__all__'

class PartydetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Partydetails
        fields = '__all__'

class ListingdetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Listingdetails
        fields = '__all__'

class ItemdetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Itemdetails
        fields = '__all__'

class CasedetailsSerializer(serializers.ModelSerializer):
    itemdetails_set = ItemdetailsSerializer(many=True, read_only=True)
    claimdetails_set = ClaimdetailsSerializer(many=True, read_only=True)
    partydetails_set = PartydetailsSerializer(many=True, read_only=True)
    listingdetails_set = ListingdetailsSerializer(many=True, read_only=True)

    class Meta:
        model = Casedetails
        fields = '__all__'
