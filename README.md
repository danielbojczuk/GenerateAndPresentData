# Generate And Present Data POC

This is a POC for an application of at least two components tha:
- Generates data.
- Uses asynchronous communication to send the generated data to another instance, which persists the data to static storage of your choice.
- Web app that serves the persisted data in any way.

## Solution

Considering the application doesn't have complex requirements it coud be perfectly divided in small pieces. So a serverless approach was chosen using Lambda Functions. If the cold start is a problem, a Provisioned Concurrency could be enabled.

![Solution Diagram](/assets/solution_diagram.png)

### Data Generation
To be able to have more control about when the data will be generated, and about the data itself, the data generation is done by a POST request in the /data resource. 

### Data Presenter
Since a web interface is not necessary, you can get the data persisted through an GET request in the /data resource. This API could be used by a Web Interface or any other service.

### Data Persister
When a POST request is made in the /data resource, the information is posted in the queue triggering the data-persister wichi store the data in a DynamoDB table.

To fullfill the requisite of asynchronous communication a queue was used. The reason was based in an assumption that only one client (data-persister) would use this informations. If this is not true, we could replace the queue to a pub/sub system.

For persisting the data a DynamoDB table was chosen due to the simplicity of the data and the easinees of querying. 

### Infrastructure as a Code
All AWS services are defined and provisioned using Terraform: https://github.com/danielbojczuk/GenerateAndPresentData/tree/main/infrastructure

It is using an S3 bucket as backend and workspaces to manage different environments.

### CI/CD
A pipeline with Github Actions was created to build test and deploy the resources.
![Solution Diagram](/assets/pipeline_overview.png)
![Solution Diagram](/assets/pipeline_build_job.png)

### Monitoring

#### Logging
The solution is using CloudWatch to store the logs

#### Tracing
The solution is using X-Ray to manage the tracing
![Solution Diagram](/assets/xray-get.png)
![Solution Diagram](/assets/xray-post.png)

#### Metrics
The solution is using the default AWS metrics. Only in production environment some alarms are being deployes and also a SNS topic and subscription to send alerts via e-mail.
![Solution Diagram](/assets/alarms.png)
![Solution Diagram](/assets/alarms_in_alarm.png)
![Solution Diagram](/assets/alarms_notification.png)


#### Security
- To avoid data going through public internet within the application, and control interneal services access, all lambdas are working in a private VPC using VPC endpoints to access AWS services.

- An custom authorizer was implemented in the API gateway.

#### Automated testing
- A simple unit test was implemented in the data-api-authorizer function app.
- A simple integration test using bash script was implemented to run in dev environment via pipeline.

## How to use
To generate and receive the data you need to use a Bearer token. You can generate one using a [JWT Bulder Website](http://jwtbuilder.jamiekurtz.com/) or to use the [test token](https://github.com/danielbojczuk/GenerateAndPresentData/blob/11b333215424a77df7afdfbe32c25345e0eaf5b2/integration_tests/integrationTest.sh#L4) from the integration test.

The authorizer is validate the roles in Role field. It should have:
- *data.read* for the GET request
- *data.write* for the POST request

The application will use the the data in sub field within JWT token as userId. And a userId can gat only its own data.

 Production URL: https://db6hxelybk.execute-api.eu-west-1.amazonaws.com/prd/data
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
- Implement Dead Letter Queue
- Improve application to support getting more then one queue item per lambda execution
- Configure throthing for API
- Add a web interface using a SPA hosted in a S3 bucket distributed with Cloudfront
- Add other metrics/alarms
- Change e-mail notification for better approach
### Pipeline
- Add terraform plan and manual steps to check the plan output before deploy
- Remove region and other hardcoded configurations
- Add smoketest after production deployment
- Add GitHub Actions workflow for PR check
### Security
- Add encryption at REST and in Transit
### Backup
- Add Point-in-time recovery for DynamoDB
