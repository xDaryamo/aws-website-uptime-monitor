import os
import time
import json
import urllib.request
from datetime import datetime
import zoneinfo
import boto3

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

def lambda_handler(event, context):
    url = os.environ['WEBSITE_URL']
    table_name = os.environ['DYNAMODB_TABLE']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    
    table = dynamodb.Table(table_name)
    
    keyword = "Dario Mazza" 
    timeout_seconds = 10
    
    tz_name = os.environ.get('TIMEZONE', 'UTC')
    tz = zoneinfo.ZoneInfo(tz_name)
    now = datetime.now(tz)
    current_hour = now.hour
    # Suppression window for maintenance: 00:00 - 08:00
    is_maintenance = 0 <= current_hour < 8
    
    start_time = time.time()
    status = "UP"
    error_message = ""
    response_time_ms = 0
    
    try:
        # Add User-Agent to mimic a real browser and avoid 403 Forbidden errors
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'})
        with urllib.request.urlopen(req, timeout=timeout_seconds) as response:
            response_time_ms = int((time.time() - start_time) * 1000)
            html = response.read().decode('utf-8')
            
            if keyword not in html:
                status = "CONTENT_ERROR"
                error_message = f"Keyword '{keyword}' not found in page content."
            
            if response_time_ms > 5000:
                status = "SLOW"
                error_message = f"Site is slow: {response_time_ms}ms"

    except Exception as e:
        status = "DOWN"
        error_message = str(e)
        response_time_ms = int((time.time() - start_time) * 1000)

    final_status = status
    if is_maintenance and status != "UP":
        final_status = f"MAINTENANCE_DOWN ({status})"
        print(f"Issue detected but suppressed due to Maintenance Window: {error_message}")

    timestamp = int(time.time())
    table.put_item(
        Item={
            'SiteUrl': url,
            'Timestamp': timestamp,
            'Status': final_status,
            'ResponseTime': response_time_ms,
            'ErrorMessage': error_message,
            'DateTime': now.strftime("%Y-%m-%d %H:%M:%S")
        }
    )

    if status != "UP" and not is_maintenance:
        alert_message = f"ALERT: Website {url} is {status}!\n\nDetails: {error_message}\nResponse Time: {response_time_ms}ms"
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject=f"Uptime Monitor Alert: {status}",
            Message=alert_message
        )
        print("Alert sent via SNS.")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'url': url,
            'status': final_status,
            'response_time': response_time_ms
        })
    }
