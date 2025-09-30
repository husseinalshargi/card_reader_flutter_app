from fastapi import Security, HTTPException, status, Request
from fastapi.security import APIKeyHeader

from reader_back_end.database_connections.redis_db import Redis_db


class auth:
    api_key = APIKeyHeader(name= "x-api-key")

    def __init__(self, rdb: Redis_db):
        self.rdb = rdb

    def handle_api_key_request(self, req: Request, key: str = Security(api_key)):
        """checks if api key is registered and can process"""

        if not self.rdb.is_api_registered(key): 
            #api key isn't registered
            raise HTTPException(status_code= status.HTTP_401_UNAUTHORIZED, detail= "Missing or invalid API key")
        
        if not self.rdb.api_limiter(key):
            #the user reaced the limit
            raise HTTPException(status_code= status.HTTP_429_TOO_MANY_REQUESTS, detail= "The user reached the limit per minute, wait a minute then try again.")
        
    def admin_access(self, req: Request, key: str = Security(api_key)):
        """cheks if the api key is for admin or not, if not then the api key isn't generated"""

        #check if this is the admin if not rise an error
        if not self.rdb.is_admin(key):
            raise HTTPException(status_code= status.HTTP_401_UNAUTHORIZED, detail= "Only admin can create an api key for user")



    


    
