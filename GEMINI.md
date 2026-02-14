# Website Uptime Monitor (AWS Serverless)

## Project Overview
This project is a comprehensive monitoring solution designed to ensure website reliability and performance. It goes beyond simple "pings" by verifying availability, response speed, and content integrity. The goal is to detect and alert on issues before they impact customers or business reputation.

## Technical Architecture (Serverless)

### 1. Monitoring Engine (AWS Lambda)
A serverless function (Python) executed automatically every 5 minutes (via Amazon EventBridge). It performs three critical checks:
- **Availability:** Is the site reachable, or has the server crashed?
- **Speed:** How long does the page take to load? (Alerts if latency exceeds acceptable thresholds).
- **Content Validation:** Does the page contain specific keywords? (Ensures the site isn't showing a blank page or a critical error).

### 2. Data Storage (Amazon DynamoDB)
All monitoring results are stored as time-series data in DynamoDB:
- **Captured Data:** Timestamp, response time (ms), status (Success/Failure), and error messages.
- **Purpose:** Enables historical analysis and uptime percentage calculation.

### 3. Alerting System (Amazon SNS)
Immediate notifications are triggered if any of the three checks fail:
- Sends SMS or email alerts with specific error details (e.g., "Site reachable but loading slow: 15s").

### 4. Dashboard (Amazon S3)
A static website hosted on S3 that visualizes metrics from DynamoDB:
- **Key Metrics:** Uptime percentage (e.g., 99.9%), average response time, and recent incident logs.

## Tech Stack & Tools
- **Language:** Python 3.11 (Lambda logic).
- **Infrastructure:** Terraform (IaC).
- **AWS Services:** Lambda, DynamoDB, SNS, S3, EventBridge.
- **Tooling:** `mise` for version management, `boto3` for AWS SDK.

## Development Strategy
- **Simulation:** Monitor a real portfolio or public site (gently).
- **Testing:** Temporarily modify the Lambda script to look for non-existent keywords to trigger "Content Validation" failures and test the SNS/DynamoDB integration.
- **Focus:** Demonstrating Full-Stack Serverless, Observability, and NoSQL time-series data management.

## CV & Professional Value
This project highlights several high-demand skills:
1. **Full-Stack Serverless:** Integration of Lambda, DynamoDB, and S3 without managing servers.
2. **Observability:** Moving beyond "up/down" checks to performance analysis (latency and content integrity).
3. **NoSQL Expertise:** Using DynamoDB for time-series data, a critical pattern for monitoring systems.
4. **Resilience:** Proactive problem detection to minimize business impact.
