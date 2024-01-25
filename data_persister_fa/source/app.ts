import { SQSEvent } from 'aws-lambda';
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import AWSXRay from 'aws-xray-sdk'

const dynamoDbClient = AWSXRay.captureAWSv3Client(new DynamoDBClient({}));
const dynamoDbDocumentClient = DynamoDBDocumentClient.from(dynamoDbClient);

export const lambdaHandler = async (event: SQSEvent): Promise<void> => {
    const command = new PutCommand({
        TableName: process.env.TABLE_NAME,
        Item: JSON.parse(event.Records[0].body),
      });
    
    await dynamoDbDocumentClient.send(command);
};
