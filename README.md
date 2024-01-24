# Generate And Present Data POC

This is a POC for an application of at least two components tha:
- Generates data.
- Uses asynchronous communication to send the generated data to another instance, which persists the data to static storage of your choice.
- Web app that serves the persisted data in any way.

## Solution Diagram
![Solution Diagram](/assets/solution_diagram.png)

## How it works
- Use to generate JWT: http://jwtbuilder.jamiekurtz.com/

## Next Steps
- Implement Dead Letter Queue
- Improve application to support getting more then one queue item per lambda execution
- Configure throthing for API
- Add a web interface using a SPA hosted in a S3 bucket distributed with Cloudfront
