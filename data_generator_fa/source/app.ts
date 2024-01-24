import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { RequestData } from './domain/model/requestData'
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

const createResponse = (responseObject:any, statusCode:number): APIGatewayProxyResult => {
    const response: APIGatewayProxyResult = {
        statusCode: statusCode,
        body: responseObject? JSON.stringify(responseObject) : ""
    }
    return response;
}

const isRequestData = (value: RequestData): value is RequestData => !!value.informationOne && !!value.informationTwo;

export const lambdaHandler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const invalidRequestErrorObject = { errorMessage: "Invalid request"};
    if(!event.body) {
        return createResponse(invalidRequestErrorObject,400);
    }

    const dataRequest: RequestData = JSON.parse(event.body);
    if(!isRequestData(dataRequest)) {
        return createResponse(invalidRequestErrorObject,400);
    }
    
    const client = new SQSClient({ region: "eu-west-1"});

    const command = new SendMessageCommand({
        QueueUrl: process.env.SQS_URL,     
        MessageBody:event.body,
      });
    await client.send(command);
    return createResponse(undefined,201);
};
