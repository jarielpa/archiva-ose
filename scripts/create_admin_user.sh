#!/bin/bash

until curl --silent --head --fail localhost:$ARCHIVA_SERVICE_PORT > /dev/null; do
	sleep 2
done

# Create admin user
curl -H "Content-Type: application/json" -X POST -d '{"username":"admin","password":"'"$ADMIN_PASSWORD"'","confirmPassword":"'"$ADMIN_PASSWORD"'","fullName":"administrator","email":"'"$ADMIN_EMAIL"'","validated":true,"assignedRoles":[],"modified":true,"rememberme":false,"logged":false}' http://localhost:$ARCHIVA_SERVICE_PORT/restServices/redbackServices/userService/createAdminUser

# Login as admin. Save cookie file as 'cookie.txt'
curl -H "Content-Type: application/json" -c cookie.txt -X POST -d '{"username":"admin","password":"'"$ADMIN_PASSWORD"'"}' http://localhost:$ARCHIVA_SERVICE_PORT/restServices/redbackServices/loginService/logIn

# Grant read permission to the 'Guest' user
curl -H "Content-Type: application/json" -b cookie.txt -X POST -d '{"username":"guest","password":null,"confirmPassword":null,"fullName":"Guest","email":"","permanent":true,"validated":false,"timestampAccountCreation":null,"timestampLastLogin":null,"timestampLastPasswordChange":null,"locked":false,"passwordChangeRequired":true,"assignedRoles":["Guest","Repository Observer - snapshots","Repository Observer - internal"],"modified":false,"readOnly":false,"userManagerId":"jdo","rememberme":false,"logged":false}' http://localhost:$ARCHIVA_SERVICE_PORT/restServices/redbackServices/roleManagementService/updateUserRoles 

# Delete the cookie file
rm -f cookie.txt

echo "Administrator account created."