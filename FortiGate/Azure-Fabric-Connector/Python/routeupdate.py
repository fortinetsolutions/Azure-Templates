import logging

import azure.functions as func

import sys

import os

import json

import requests

import time

AppID=os.environ['AppID']
AppPassword=os.environ['AppPassword']
TenantID=os.environ['TenantID']
SubscriptionID=os.environ['SubscriptionID']
RGName=os.environ['RGName']
VNet=os.environ['VNet']
Subnet1=os.environ['Subnet1']
Subnet2=os.environ['Subnet2']
Subnet1addressPrefix=os.environ['Subnet1addressPrefix']
Subnet2addressPrefix=os.environ['Subnet2addressPrefix']
RouteName=os.environ['RouteName']


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
def SubnetAssociation():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2018-11-01'),
    )
    data1 = {'properties':{'addressPrefix':Subnet1addressPrefix,'routeTable':{'id':'/subscriptions/'+SubscriptionID+'/resourceGroups/'+RGName+'/providers/Microsoft.Network/routeTables/'+RouteName}}}
    data2 = {'properties':{'addressPrefix':Subnet2addressPrefix,'routeTable':{'id':'/subscriptions/'+SubscriptionID+'/resourceGroups/'+RGName+'/providers/Microsoft.Network/routeTables/'+RouteName}}}
    response1 = requests.put('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/virtualNetworks/' + VNet + '/subnets/' + Subnet1 + '?api-version=2018-11-01', headers=headers, data=json.dumps(data1))
    time.sleep(5)
    response2 = requests.put('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/virtualNetworks/' + VNet + '/subnets/' + Subnet2 + '?api-version=2018-11-01', headers=headers, data=json.dumps(data2))
    print (response1.content)
    print (response2.content)
    return

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name == 'update':
        SubnetAssociation()
        return func.HttpResponse(f"Subnet association updated")
    else:
        return func.HttpResponse(
             "Please pass a name on the query string as <name=update> or in the request body",
             status_code=400
        )
