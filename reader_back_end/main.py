from langchain_ollama import OllamaLLM
from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Depends

from reader_back_end.services.card_reader import CardReader
from reader_back_end.settings.config import Config
from reader_back_end.database_connections.redis_db import Redis_db
from reader_back_end.api_conf.auth import auth

languages_list: list[str]

try:
    
    app = FastAPI()

    print("\n=== initalizing redis db ===")
    rdb = Redis_db()
    print('=== redis db initialized ===')


    api_header_auth = auth(rdb)

    #setup the llm instance 
    llm = OllamaLLM(model = Config.llm_model)

    print('=== initalizing card reader ===')
    #setup the class that has the process of reading card details
    card_reader = CardReader(llm)
    print('=== card reader initialized ===')
    

except Exception as e:
    print(f'error in initializing card reader back-end - {e}')    

        
@app.post('/process_card', dependencies= [Depends(api_header_auth.handle_api_key_request)])
async def get_card_details(is_binarized: bool = Form(...),
                            is_extracted: bool = Form(...),
                            language: str = Form('en'),
                            image: UploadFile = File(...)):
    
    #read the image content (in bytes)
    img_content = await image.read()

    #as easy ocr in case of other languages it require them to be in the second place after 'en'
    languages_list = ['en'] if language.strip().lower() == 'en' else ['en', language.strip().lower()]

    #return the values in dict form 
    card_details = card_reader.read_card(img_content, is_binarized, is_extracted, languages_list)

    return card_details

#post is safier as get shows data in the url
@app.post('/create_api_key', dependencies= [Depends(api_header_auth.admin_access)])
def create_api_key(user_email: str = Form(...)):
    api_key = None
    #create an api with the email of the user
    #each async function must be called with await so if we have async function all the functions use it will be also async as well as the functions that use the other functions
    try:
        api_key = rdb.create_api_key(user_email)
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(400, "something went wrong.")

    if api_key != None:
        print("api key created successfully for the user")

        return api_key

