import sys

import json

import requests

AppID="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
AppPassword="XXXXXXXXXXXXXXXXXXXXXXXXX"
TenantID="XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
SubscriptionID="XXXXXXXXXXXXXXXXXXXXXX"
RGName="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

#------------------------------------------------------------
#Get Azure Token ID
#------------------------------------------------------------
def AccessTokenID():
    data = {
        'grant_type': 'client_credentials',
        'client_id': AppID,
        'client_secret': AppPassword,
        'resource': 'https://management.azure.com/'
    }
    response = requests.post('https://login.microsoftonline.com/' + TenantID + '/oauth2/token', data=data)
    #-------------------------------------------------------------
    Token=json.loads(response.content)
    return Token["access_token"]
#-------------------------------------------------------------
#Get Resource Group Name exists
#-------------------------------------------------------------
def RGDelete():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    #print (headers)
    params = (
        ('api-version', '2018-05-01'),
    )

    response = requests.get('https://management.azure.com/subscriptions/' + SubscriptionID + '/resourcegroups/' + RGName +'', headers=headers, params=params)
    if response.status_code == 200:
        print ('Its true')
        headers = {
            'Authorization': 'Bearer {0}'.format(AccessToken),
            'Content-Type': 'application/json',
        }
        params = (
            ('api-version', '2018-05-01'),
        )
        response = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID + '/resourcegroups/' + RGName +'', headers=headers, params=params)
    else:
        print ('Its false')
    return
RGDelete()    
