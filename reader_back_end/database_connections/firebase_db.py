import logging

import firebase_admin
from firebase_admin import auth
from fastapi import HTTPException, Request, status, Security
from fastapi.security import HTTPBearer, http

from reader_back_end.settings.config import Config

class Firebase_db:
    # this is the token taken from the header of the post request
    # HTTPBearer will take the token securely 
    security_token = HTTPBearer(scheme_name="JWT_token", description= "Takes the users JWT token with the request to validate and limit usage")

    def __init__(self):
        self.user_logger = logging.getLogger("user_logger")
        try:
            self.fdb = firebase_admin.initialize_app(credential=firebase_admin.credentials.Certificate(Config.firebase_sdk_cred_path))
        except Exception as e:
            logging.info('error in firebase db initialization', exc_info=True)
            raise e
        
    #the user_JWS_token is created like this with the "Security" function to handle the header in the request as a dependency 
    # HTTPAuthorizationCredentials is the output type of the barer
    def get_user_info_from_token(self, request: Request, user_JWS_token_bearer: http.HTTPAuthorizationCredentials = Security(security_token)) -> dict:
        """
        takes the user sign in token, validate it, and returns the uid to control limit if the token is correct
            output example:
                {'iss': 'https://securetoken.google.com/project_name', 'aud': 'project_name_id', 'auth_time': , 'user_id': '', 'sub': '', 'iat': , 'exp': , 'email': 'example@mail.com', 'email_verified': False, 'firebase': {'identities': {'email': ['']}, 'sign_in_provider': 'password'}, 'uid': ''}
        """
        # check if the token is correct and enabled, otherwise return an exception (raised)
        try:
            # to get the exact token not an httpbearer object we will use credentials
            decoded_JWT = auth.verify_id_token(id_token=user_JWS_token_bearer.credentials, app=self.fdb, check_revoked=True)
            return decoded_JWT
        except Exception as e:
            self.user_logger.error(f"IP address: {request.client.host if request.client else "unknown"} - Invalid or expired token")
            raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired token"
            )

