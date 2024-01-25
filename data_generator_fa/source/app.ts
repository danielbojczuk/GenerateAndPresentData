import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { RequestData } from './domain/model/requestData'
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';
import AWSXRay from 'aws-xray-sdk'

const client = AWSXRay.captureAWSv3Client(new SQSClient({ region: "eu-west-1"}));

const createResponse = (responseObject:any, statusCode:number): APIGatewayProxyResult => {
    const response: APIGatewayProxyResult = {
        statusCode: statusCode,
        body: responseObject? JSON.stringify(responseObject) : ""
    }
    return response;
}

const isRequestData = (value: RequestData): value is RequestData => !!value.informationOne && !!value.informationTwo;

export const lambdaHandler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    console.log(JSON.stringify(event));
    const invalidRequestErrorObject = { errorMessage: "Invalid request"};
    if(!event.body) {
        return createResponse(invalidRequestErrorObject,400);
    }

    const dataRequest: RequestData = JSON.parse(event.body);
    if(!isRequestData(dataRequest)) {
        return createResponse(invalidRequestErrorObject,400);
    }

    const messageBody = {
        userId: event.requestContext.authorizer?.principalId,
        timestamp: Date.now(), 
        ... dataRequest
    }
    

    const command = new SendMessageCommand({
        QueueUrl: process.env.SQS_URL,     
        MessageBody: JSON.stringify(messageBody),
      });
    await client.send(command);
    return createResponse(undefined,201);
};
