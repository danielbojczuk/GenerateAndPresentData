import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient, QueryCommand } from "@aws-sdk/client-dynamodb";


const createResponse = (responseObject:any, statusCode:number): APIGatewayProxyResult => {
    const response: APIGatewayProxyResult = {
        statusCode: statusCode,
        body: JSON.stringify(responseObject)
    }
    return response;
}

const client = new DynamoDBClient({region: "eu-west-1"});

export const lambdaHandler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const command = new QueryCommand({
        KeyConditionExpression: "userId = :userId",
        ExpressionAttributeValues: {
          ":userId": { S: "test" },
        },
        TableName: process.env.TABLE_NAME,
      });
    const dynamoResponse = await client.send(command);
    const response = dynamoResponse.Items?.map((i) => {return {
        User: i.userId.S,
        Date: i.timestamp.N,
        InformationOne: i.informationOne.S,
        InformationTwo: i.informationTwo.S
    }});
    return createResponse(response,200);
};
