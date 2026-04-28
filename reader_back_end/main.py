import logging
from datetime import datetime
from typing import Annotated, List

from langchain_ollama import OllamaLLM
from fastapi import FastAPI, HTTPException, Query, UploadFile, File, Form, Depends, status

from reader_back_end.database_connections.firebase_db import Firebase_db
from reader_back_end.services.card_reader import CardReader
from reader_back_end.settings.config import Config
from reader_back_end.database_connections.redis_db import Redis_db

try:
    logging.basicConfig(level= logging.INFO, filename= f"reader_back_end\\Logs\\System Logs - {datetime.now().date()}.log", filemode= "a", 
                    format="%(asctime)s - %(funcName)s - %(levelname)s - %(message)s") 

    user_logger = logging.getLogger("user_logger")
    handler = logging.FileHandler(filename= f"reader_back_end\\Logs\\User Logs - {datetime.now().date()}.log", mode= "a")
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(funcName)s - %(levelname)s - %(message)s")
    handler.setFormatter(formatter)
    user_logger.addHandler(handler)
    user_logger.propagate = False  # Stops logs from moving up to the root logger (this will make all user logs inside user file)

except Exception as e:
    logging.critical(f'error in initializing card reader back-end', exc_info= True)    


try:
    app = FastAPI()

    logging.info("=== initializing redis db ===")
    rdb = Redis_db()
    logging.info('=== redis db initialized ===')

    logging.info("=== initializing firebase ===")
    fdb = Firebase_db()
    logging.info('=== firebase initialized ===')

    # #setup the llm instance
    # logging.info("=== initializing ollama model ===")
    # llm = OllamaLLM(model = Config.llm_model)
    # logging.info("=== initializing ollama model ===")

    # now instead of using local llm model we will use gemini api model as it is cheaper and eliminate the need for large server to host the model, also the image processing and enhance the results with less tokens as a prompt
    # the gemini client will be used in the card reader class
    logging.info('=== initializing card reader ===')
    #setup the class that has the process of reading card details
    card_reader = CardReader()
    logging.info('=== card reader initialized ===')

    logging.info('\n ======== System Initialized ========  \n\n')
    

except Exception as e:
    logging.critical(f'error in initializing card reader back-end', exc_info= True)    

# Form(...) indicates for an entry that is a string
# File(...) indicates for an entry that is an image or more than one (i think)
# dependencies= [Depends(api_header_auth.admin_access)] this means when this post is called it will require a header that will be processed in the function api_header_auth.admin_access
# decoded_JWT: dict = Depends(fdb.get_user_id_from_token) this makes it useable in the function
@app.post('/process_card')
async def get_card_details(decoded_JWT: dict = Depends(fdb.get_user_info_from_token),
                            is_binarized: bool = Form(...),
                            is_extracted: bool = Form(...),
                            # docs website for the api won't support this for some reason it will act strangely so you should use postman
                            images: List[UploadFile] = File(...)):
    
    # now before doing anything the user id will be used to rate limit 
    # the function will return a bool indicating whether the user is under limit or not (currently 3 requests per minute)
    is_request_under_limit: bool = rdb.api_limiter(uid= decoded_JWT["uid"])

    if not is_request_under_limit:
        user_logger.warning(f"{decoded_JWT["user_id"]} - {decoded_JWT["email"]} - To many requests error")
        raise HTTPException(status_code= status.HTTP_429_TOO_MANY_REQUESTS, detail= "To many requests please try again later")

    if len(images) > 2 or len(images) < 1:
        user_logger.warning(f"{decoded_JWT["user_id"]} - {decoded_JWT["email"]} - To many requests error")
        raise HTTPException(status_code= status.HTTP_400_BAD_REQUEST, detail= "No images to be processed or more than 2 images has been submitted")
    
    for img in images:
        if img.size > 1024*1024*5:
            user_logger.warning(f"{decoded_JWT["user_id"]} - {decoded_JWT["email"]} - User uploaded one or more images with more than 5mb size")
            raise HTTPException(status_code= status.HTTP_400_BAD_REQUEST, detail= "Image size should be less than 5 mb")
 


    #read the image content (in bytes)
    try:
        images_content = [await img.read() for img in images]
    except:
        logging.critical("Error in reading images", exc_info= True)
        raise HTTPException(status_code= status.HTTP_500_INTERNAL_SERVER_ERROR, detail= "Something went wrong in server")


    #return the values in dict form 
    card_details = card_reader.read_card(images_content, is_binarized, is_extracted, user_id= decoded_JWT["user_id"], user_email =decoded_JWT["email"],)

    user_logger.info(f"{decoded_JWT["user_id"]} - {decoded_JWT["email"]} - Scanned a card successfully")

    return card_details


