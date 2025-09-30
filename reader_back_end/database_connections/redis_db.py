import redis
from fastapi import HTTPException
import uuid

from reader_back_end.settings.config import Config

class Redis_db:
    __api_keys_set = 'registered_apis'
    __emails_set = 'registered_emails'

    def __init__(self):
        try:
            self.r = redis.Redis(host= Config.REDIS_HOST, port= Config.REDIS_PORT, decode_responses=True, password= Config.REDIS_PASSWORD)
            self.r.ping() # in case no connection it will rise an error
        except Exception:
            print('error in redis db initilization')
            raise HTTPException(400, 'error initilizing redis db')

    def __add_api_key(self, user_email: str, api_key: str) -> bool:
        """add the email and the api key of the user to redis db"""

        #add the api key to redis set 
        key_response = self.r.sadd(self.__api_keys_set, api_key)

        email_response = self.r.sadd(self.__emails_set, user_email)

        if int(key_response) != 1: #we couldn't add it as it is duplicated
            print("api key duplicated")
            raise HTTPException(status_code=400, detail="Cannot create an api key for the user, try again later")
        
        if email_response != 1: #duplicated email registered
            print('email already has an api key')
            raise HTTPException(status_code=400, detail="email already has an api key")

        #set it also as key: email, value: key
        self.r.set(user_email, api_key)



    
    def create_api_key(self, user_email: str) -> str:
        """create an api key and save it in redis also return it to be saved in the front end db"""
        print("creating user api")

        #generate a random uuid as an api key and convert it to a string rather than a uuid object 
        generated_api_key = str(uuid.uuid4())
        
        #add api key and email to redis
        self.__add_api_key(user_email, generated_api_key)

        return generated_api_key









