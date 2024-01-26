# Generate And Present Data POC

This is a POC for an application with at least two components that:

- Generates data.
- Uses asynchronous communication to send the generated data to another instance, which persists the data to static storage of your choice.
- Serves the persisted data in a web app.

## Solution

Considering the application doesn't have complex requirements, it could be perfectly divided into small pieces. So, a serverless approach was chosen using Lambda Functions. If cold start is a problem, Provisioned Concurrency could be enabled.

![Solution Diagram](/assets/solution_diagram.png)

### Data Generation

To have more control over when the data will be generated, and over the data itself, the data generation is done by a POST request to the `/data` resource.

### Data Presenter

Since a web interface is not necessary, you can retrieve the persisted data through a GET request to the `/data` resource. This API could be used by a Web Interface or any other service.

### Data Persister

When a POST request is made to the `/data` resource, the information is posted in the queue, triggering the data-persister which stores the data in a DynamoDB table.

To fulfill the requirement of asynchronous communication, a queue was used. The reason was based on an assumption that only one client (data-persister) would use this information. If this is not true, we could replace the queue with a pub/sub system.

For persisting the data, a DynamoDB table was chosen due to the simplicity of the data and the ease of querying.

### Infrastructure as Code

All AWS services are defined and provisioned using Terraform: [GitHub Repository](https://github.com/danielbojczuk/GenerateAndPresentData/tree/main/infrastructure).

It uses an S3 bucket as a backend and workspaces to manage different environments.

### CI/CD

A pipeline with GitHub Actions was created to build, test, and deploy the resources.

![Pipeline Overview](/assets/pipeline_overview.png)
![Pipeline Build Job](/assets/pipeline_build_job.png)

### Monitoring

#### Logging

The solution uses CloudWatch to store the logs.

#### Tracing

X-Ray is used to manage the tracing.

![X-Ray GET](/assets/xray-get.png)
![X-Ray POST](/assets/xray-post.png)

#### Metrics

The solution uses the default AWS metrics. Only in the production environment, some alarms are deployed along with an SNS topic and subscription to send alerts via email.

![Alarms](/assets/alarms.png)
![Alarms in Alarm](/assets/alarms_in_alarm.png)
![Alarms Notification](/assets/alarms_notification.png)

#### Security

- To avoid data going through the public internet within the application and control internal service access, all Lambdas are working in a private VPC using VPC endpoints to access AWS services.

- A custom authorizer was implemented in the API gateway.

#### Automated Testing

- A simple unit test was implemented in the data-api-authorizer function app.
- A simple integration test using a Bash script was implemented to run in the dev environment via the pipeline.

## How to Use

To generate and receive the data, you need to use a Bearer token. You can generate one using a [JWT Builder Website](http://jwtbuilder.jamiekurtz.com/) or use the [test token](https://github.com/danielbojczuk/GenerateAndPresentData/blob/11b333215424a77df7afdfbe32c25345e0eaf5b2/integration_tests/integrationTest.sh#L4) from the integration test.

The authorizer validates the roles in the Role field. It should have:

- *data.read* for the GET request
- *data.write* for the POST request

The application will use the data in the subfield within the JWT token as userId. And a userId can only get its own data.

Production URL: [https://db6hxelybk.execute-api.eu-west-1.amazonaws.com/prd/data](https://db6hxelybk.execute-api.eu-west-1.amazonaws.com/prd/data)

### POST

Example payload:

```json
{
   "informationOne": "aaa23",
   "informationTwo": "bbb24"
}
```
![Solution Diagram](/assets/post_request.png)

### GET
![Solution Diagram](/assets/get_request.png)

## Improvements/Next Steps
### Solution
- Implement Dead Letter Queue.
- Improve application to support getting more than one queue item per lambda execution.
- Configure throttling for API.
- Add a web interface using a SPA hosted in an S3 bucket distributed with CloudFront.
- Add other metrics/alarms.
- Change email notification for a better approach.
### Pipeline
- Add Terraform plan and manual steps to check the plan output before deployment.
- Remove region and other hardcoded configurations.
- Add smoke test after production deployment.
- Add GitHub Actions workflow for PR check.
### Security
- Add encryption at rest and in transit.
### Backup
- Add Point-in-time recovery for DynamoDB.
