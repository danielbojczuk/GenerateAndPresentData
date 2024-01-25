import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient, QueryCommand } from "@aws-sdk/client-dynamodb";
import AWSXRay from 'aws-xray-sdk'


const createResponse = (responseObject:any, statusCode:number): APIGatewayProxyResult => {
    const response: APIGatewayProxyResult = {
        statusCode: statusCode,
        body: JSON.stringify(responseObject)
    }
    return response;
}

const dynamoDbClient = AWSXRay.captureAWSv3Client(new DynamoDBClient({}));

export const lambdaHandler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const command = new QueryCommand({
        KeyConditionExpression: "userId = :userId",
        ExpressionAttributeValues: {
          ":userId": { S: event.requestContext.authorizer?.principalId },
        },
        TableName: process.env.TABLE_NAME,
      });
    const dynamoResponse = await dynamoDbClient.send(command);
    const response = dynamoResponse.Items?.map((i) => {return {
        User: i.userId.S,
        Date: i.timestamp.N,
        InformationOne: i.informationOne.S,
        InformationTwo: i.informationTwo.S
    }});
    return createResponse(response,200);
};
