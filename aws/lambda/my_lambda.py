import json

# Sample lambda function for processing "hello world" example
# Turns out that the content of the "event" received it different when a curl to the URL-endpoint is given
# compared to the event received while testing from the console. We handle both.
# Sample jsons are below that can be used for testing and developing real functional lambdas
# Invoking:
# echo -n '{"key1": "John Doe", "key2": 30}' | base64 # create PYL as base64 string returned
# 1: aws lambda invoke --function-name SriniHelloWorld --payload  $PYL tmp.json
# 2: curl -vvv -X POST -H "Content-Type: application/json" -d '{"key1": "John Doe", "key2": 30}' <URL endpoint>
# 3: From console, select SriniHelloWorld, click "code", "Test", "Create new test event", Tempate = Hello World

def lambda_handler(event, context):
    my_message="Did not handle anything"
    no_error = True # Set to false is an exception/error happens
    my_obj = dict()
    try:
        bodyPresent = event.get("body", None)
        if bodyPresent is None: # assume that event is processed body
            my_obj = event # Even object IS the body, when testing from console
        else: # assume that event is raw body from curl to URL
            if type(bodyPresent) is dict: # From this test function
                my_obj = bodyPresent
            elif type(bodyPresent) is str: # URL- something AWS is doing that causes this to show up a string
                my_obj = json.loads(bodyPresent)
            else: # Don't know what to do
                err_str = "body type is not str-json or dict" + str(type(bodyPresent))
                raise TypeError(err_str)
    except Exception as e:
        no_error = False
        my_message = "Error: " + str(e)
    else:
        my_message = my_obj.get("key1", "NoName") + " is " + str(my_obj.get("key2","Unknown")) + " years old."
    finally:
        retCode = 200
        if not no_error:
            retCode=500
        resp= {
            "statusCode": retCode,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            "body": my_message  # Return my_message
        }
        return resp

eventStr = '''
{
  "version": "2.0",
  "routeKey": "$default",
  "rawPath": "/my/path",
  "rawQueryString": "parameter1=value1&parameter1=value2&parameter2=value",
  "cookies": [
    "cookie1",
    "cookie2"
  ],
  "headers": {
    "header1": "value1",
    "header2": "value1,value2"
  },
  "queryStringParameters": {
    "parameter1": "value1,value2",
    "parameter2": "value"
  },
  "requestContext": {
    "accountId": "123456789012",
    "apiId": "<urlid>",
    "authentication": null,
    "authorizer": {
        "iam": {
                "accessKey": "AKIA...",
                "accountId": "111122223333",
                "callerId": "AIDA...",
                "cognitoIdentity": null,
                "principalOrgId": null,
                "userArn": "arn:aws:iam::111122223333:user/example-user",
                "userId": "AIDA..."
        }
    },
    "domainName": "<url-id>.lambda-url.us-west-2.on.aws",
    "domainPrefix": "<url-id>",
    "http": {
      "method": "POST",
      "path": "/my/path",
      "protocol": "HTTP/1.1",
      "sourceIp": "123.123.123.123",
      "userAgent": "agent"
    },
    "requestId": "id",
    "routeKey": "$default",
    "stage": "$default",
    "time": "12/Mar/2020:19:03:58 +0000",
    "timeEpoch": 1583348638390
  },
  "body": {"key1": "John Doe", "key2": 30},
  "pathParameters": null,
  "isBase64Encoded": false,
  "stageVariables": null
} '''

onlyBodyStr = '''
{
    "key1": "John Doe", 
    "key2": 30
} '''

badBodyStr = '''
{
    "body" : 30 
} '''


if __name__ == "__main__":
    test_str = eventStr
    myDict = json.loads(test_str)
    print(lambda_handler(myDict, None))
