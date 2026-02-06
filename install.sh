#!/bin/bash

ENDPOINT="http://localhost:4566"
REGION="us-east-1"
RoleName="lambda-role"

echo "--- 1. Lancement de l'instance EC2 ---"
INSTANCE_ID=$(aws --endpoint-url=$ENDPOINT ec2 run-instances --image-id ami-test --count 1 --instance-type t2.micro --query 'Instances[0].InstanceId' --output text)
echo "ID Instance : $INSTANCE_ID"

echo "--- 2. Déploiement de la Lambda ---"
rm -f function.zip
zip function.zip lambda_function.py

# Création du rôle IAM (nécessaire pour la forme)
aws --endpoint-url=$ENDPOINT iam create-role --role-name $RoleName --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}' > /dev/null 2>&1

aws --endpoint-url=$ENDPOINT lambda create-function \
    --function-name GestionEC2 \
    --zip-file fileb://function.zip \
    --handler lambda_function.lambda_handler \
    --runtime python3.8 \
    --role arn:aws:iam::000000000000:role/$RoleName

echo "--- 3. Configuration de l'API Gateway ---"
API_ID=$(aws --endpoint-url=$ENDPOINT apigateway create-rest-api --name "MonAPI" --query 'id' --output text)
PARENT_ID=$(aws --endpoint-url=$ENDPOINT apigateway get-resources --rest-api-id $API_ID --query 'items[0].id' --output text)

aws --endpoint-url=$ENDPOINT apigateway put-method \
    --rest-api-id $API_ID --resource-id $PARENT_ID \
    --http-method GET --authorization-type "NONE"

aws --endpoint-url=$ENDPOINT apigateway put-integration \
    --rest-api-id $API_ID --resource-id $PARENT_ID \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:GestionEC2/invocations

aws --endpoint-url=$ENDPOINT apigateway create-deployment --rest-api-id $API_ID --stage-name prod

echo "----------------------------------------------------"
echo "TERMINÉ ! Voici le lien à tester (copie la partie en gras) :"
echo "/restapis/$API_ID/prod/_user_request_?action=stop&id=$INSTANCE_ID"