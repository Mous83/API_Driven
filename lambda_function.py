import boto3
import json
import os

def lambda_handler(event, context):
    # FIX : On utilise l'adresse interne fournie par LocalStack
    # Si on est en local, ça utilise "localhost", sinon l'IP du conteneur
    localstack_host = os.environ.get("LOCALSTACK_HOSTNAME", "localhost")
    endpoint = f"http://{localstack_host}:4566"

    ec2 = boto3.client('ec2', endpoint_url=endpoint, region_name='us-east-1')
    
    params = event.get('queryStringParameters', {})
    action = params.get('action')
    instance_id = params.get('id')
    
    msg = "Aucune action."
    try:
        if action == 'start':
            ec2.start_instances(InstanceIds=[instance_id])
            msg = f"Succès : Instance {instance_id} démarrée."
        elif action == 'stop':
            ec2.stop_instances(InstanceIds=[instance_id])
            msg = f"Succès : Instance {instance_id} arrêtée."
    except Exception as e:
        msg = f"Erreur : {str(e)}"
    
    return {'statusCode': 200, 'body': json.dumps(msg)}