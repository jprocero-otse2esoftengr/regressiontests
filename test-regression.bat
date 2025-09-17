@echo off
echo Testing RegTestRunner functionality...
echo.

echo 1. Testing RegTestRunner help...
java -jar jarfiles/RegTestRunner-8.10.5.jar --help
echo.

echo 2. Testing connection to Bridge server...
echo Bridge Host: ec2-52-74-183-0.ap-southeast-1.compute.amazonaws.com
echo Bridge Port: 11169
echo Bridge User: jprocero
echo.

echo 3. Attempting to list test suites...
java -jar jarfiles/RegTestRunner-8.10.5.jar -project BuilderUML -host ec2-52-74-183-0.ap-southeast-1.compute.amazonaws.com -port 11169 -username jprocero -password jprocero -list
echo.

echo 4. Testing Bridge CLI connection...
e2ebridge services -h ec2-52-74-183-0.ap-southeast-1.compute.amazonaws.com -p 11169 -u jprocero -P jprocero
echo.

echo Test completed.
pause
