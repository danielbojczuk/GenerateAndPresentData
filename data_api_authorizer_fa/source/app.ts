import { APIGatewayTokenAuthorizerEvent, AuthResponse, Context, PolicyDocument } from 'aws-lambda'
import jwt from 'jsonwebtoken'

function generateStatement(resource:string, effect: string) {
    return {
        Action: "execute-api:Invoke",
        Effect: effect,
        Resource: resource,
    }
}

function generateAllowPolicy (roles:string[], accountId: string): PolicyDocument {
    const statements: any[] = [];
    roles.forEach((role:string) => {
        if(role == "data.read") {
            statements.push(generateStatement(`arn:aws:execute-api:eu-west-1:${accountId}:${process.env.API_ID}/${process.env.STAGE}/GET/data`, "Allow"))
        }
        if(role == "data.write") {
            statements.push(generateStatement(`arn:aws:execute-api:eu-west-1:${accountId}:${process.env.API_ID}/${process.env.STAGE}/POST/data`, "Allow"))
        }
    });

    const policyDocument = {} as PolicyDocument
    policyDocument.Version = '2012-10-17'
    policyDocument.Statement = statements

    return policyDocument;
}

function generateDenyPolicy (): PolicyDocument {
    const policyDocument = {} as PolicyDocument
    policyDocument.Version = '2012-10-17'
    policyDocument.Statement = []
    policyDocument.Statement[0] = generateStatement("*", "Deny");

    return policyDocument;
}

export const lambdaHandler = async (event: APIGatewayTokenAuthorizerEvent, context: Context): Promise<AuthResponse> => {
    const jwtToken = jwt.decode(event.authorizationToken.substring(7)) as jwt.JwtPayload;

    console.log(JSON.stringify(jwtToken), JSON.stringify(event));

    if(!jwtToken || !jwtToken.Role || !jwtToken.sub) {
        return {
            principalId: "data_api_gateway",
            policyDocument: generateDenyPolicy()
        }
    }
    
    const policy = {
        principalId: jwtToken.sub,
        policyDocument: generateAllowPolicy(jwtToken.Role, context.invokedFunctionArn.split(":")[4])
    }

    console.log( JSON.stringify(policy));

    return policy;
};
