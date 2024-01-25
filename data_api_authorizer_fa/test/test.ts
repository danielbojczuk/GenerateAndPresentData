import { APIGatewayTokenAuthorizerEvent, Context } from "aws-lambda";
import { lambdaHandler } from "../source/app"
test("Should allow with valid token", async () => {
    const event: APIGatewayTokenAuthorizerEvent = {
        type: "TOKEN",
        methodArn: "arn:aws:execute-api:eu-west-1:123456789:484984s/dev/POST/data",
        authorizationToken: "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJPbmxpbmUgSldUIEJ1aWxkZXIiLCJpYXQiOjE3MDYxMTg4MTAsImV4cCI6MTczNzY1NDgxMCwiYXVkIjoid3d3LmV4YW1wbGUuY29tIiwic3ViIjoianJvY2tldEBleGFtcGxlLmNvbSIsIkdpdmVuTmFtZSI6IkpvaG5ueSIsIlN1cm5hbWUiOiJSb2NrZXQiLCJFbWFpbCI6Impyb2NrZXRAZXhhbXBsZS5jb20iLCJSb2xlIjpbImRhdGEucmVhZCIsImRhdGEud3JpdGUiXX0.FwkQbYt6Z0r634zmwlyb-5EDo0nk59b41LVPjBi_egY"
    };
    const context: Context = {
        callbackWaitsForEmptyEventLoop: false,
        functionName: "",
        functionVersion: "",
        invokedFunctionArn: "a:a:a:a:123456:a",
        memoryLimitInMB: "",
        awsRequestId: "",
        logGroupName: "",
        logStreamName: "",
        getRemainingTimeInMillis: function (): number {
            throw new Error("Function not implemented.");
        },
        done: function (error?: Error | undefined, result?: any): void {
            throw new Error("Function not implemented.");
        },
        fail: function (error: string | Error): void {
            throw new Error("Function not implemented.");
        },
        succeed: function (messageOrObject: any): void {
            throw new Error("Function not implemented.");
        }
    };
    const expectedValue = `{"principalId":"jrocket@example.com","policyDocument":{"Version":"2012-10-17","Statement":[{"Action":"execute-api:Invoke","Effect":"Allow","Resource":"arn:aws:execute-api:eu-west-1:123456:undefined/undefined/GET/data"},{"Action":"execute-api:Invoke","Effect":"Allow","Resource":"arn:aws:execute-api:eu-west-1:123456:undefined/undefined/POST/data"}]}}`;
    const policy = await lambdaHandler(event, context)
    expect(JSON.stringify(policy)).toEqual(expectedValue);
 });