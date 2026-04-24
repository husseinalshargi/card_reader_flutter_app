from dotenv import load_dotenv
import os

class Config:

    load_dotenv('reader_back_end\\.env')

    llm_model = os.environ.get('LLM_MODEL', 'command-r7b-arabic:7b')

    # redis config
    REDIS_HOST = os.environ.get('REDIS_HOST')
    REDIS_PORT = int(os.environ.get('REDIS_PORT'))
    REDIS_PASSWORD = os.environ.get('REDIS_PASSWORD')

    # admin api key for creating api keys
    ADMIN_KEY = os.environ.get('ADMIN_KEY')

    #path of the firebase sdk json file
    firebase_sdk_cred_path = os.environ.get('FIREBASE_CRED_PATH')

    # gemini api key for connection
    GEMINI_KEY = os.environ.get('GEMINI_API_KEY')
