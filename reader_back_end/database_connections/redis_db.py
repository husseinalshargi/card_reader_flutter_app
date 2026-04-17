import redis
from fastapi import HTTPException
import uuid
import datetime

from reader_back_end.settings.config import Config

class Redis_db:
    # __api_keys_set = 'registered_apis'
    # __emails_set = 'registered_emails'

    def __init__(self):
        try:
            self.r = redis.Redis(host= Config.REDIS_HOST, port= Config.REDIS_PORT, decode_responses=True, password= Config.REDIS_PASSWORD)
            self.r.ping() # in case no connection it will rise an error
        except Exception:
            print('error in redis db initilization')
            raise HTTPException(400, 'error initilizing redis db')

# this was used in case we deal with api keys ut no, we use JWT token from firebase
    # def __add_api_key(self, user_email: str, api_key: str) -> bool:
    #     """add the email and the api key of the user to redis db"""

    #     #add the api key to redis set 
    #     key_response = self.r.sadd(self.__api_keys_set, api_key)

    #     email_response = self.r.sadd(self.__emails_set, user_email)

    #     if int(key_response) != 1: #we couldn't add it as it is duplicated
    #         print("api key duplicated")
    #         raise HTTPException(status_code=400, detail="Cannot create an api key for the user, try again later")
        
    #     if email_response != 1: #duplicated email registered
    #         print('email already has an api key')
    #         raise HTTPException(status_code=400, detail="email already has an api key")
        
    #     created_at = datetime.datetime.now()

    #     #set it as hash where the key is the api key and one of the values is the email address
    #     self.r.hset(api_key, mapping= {
    #         "user_email": user_email, 
    #         "date_created": f"{created_at.day}/{created_at.month}/{created_at.year}",
    #         "time_created": f"{created_at.hour}:{created_at.min}:{created_at.second}"
    #     })



# also this like the function before    
    # def create_api_key(self, user_email: str) -> str:
    #     """create an api key and save it in redis also return it to be saved in the front end db"""
    #     print("creating user api")

    #     #generate a random uuid as an api key and convert it to a string rather than a uuid object 
    #     generated_api_key = str(uuid.uuid4())
        
    #     #add api key and email to redis
    #     self.__add_api_key(user_email, generated_api_key)

    #     return generated_api_key

# also this like the two functions before
    # def is_api_registered(self, api_key):
    #     """checks if the api key is in redis to enable the user to access the services"""
    #     #checks if the api key is a member of the set of apis
    #     result = self.r.sismember(self.__api_keys_set, api_key)

    #     #return true if it is there
    #     return True if result == 1 else False
    
    def api_limiter(self, uid: str, limit: int = 3, seconds:int = 60) -> bool:
        """using redis the user can only access api three times per minute, returns bool indicating the user can use the endpoint or not, based on the user firebase uid"""
        limiter_key = f"{uid}:limit"

        #ex value will expire in seconds
        #this will set the value to 1 with an expire date only if it is expired, otherwise it will be incremented until it reaches a limit
        if self.r.get(limiter_key) is None:
            self.r.set(name= limiter_key, value= 1, ex= seconds) 

        #this will check and increment at the same time, as incr returns the value
        if int(self.r.incrby(limiter_key)) >= limit:
            # a user uses the api key more than three times per minute 
            return False
        
        return True
    
            








