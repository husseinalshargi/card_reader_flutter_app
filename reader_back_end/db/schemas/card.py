from pydantic import BaseModel, ConfigDict


class SaveCard(BaseModel):
    id : int | None # in case of first time saving
    full_name : str
    phone_number : str 
    office_number : str 
    web_site : str 
    company_name : str 
    email : str 
    address : str 
    job_title : str 
    city : str 
    country : str 

class GetCard(BaseModel):
    id : int 
    full_name : str 
    phone_number : str 
    office_number : str 
    web_site : str 
    company_name : str 
    email : str 
    address : str 
    job_title : str 
    city : str 
    country : str 

    #this will enable us to use model_validate to an orm object instead of a dict (this will make it read from attributes instead of dict keys)
    model_config = ConfigDict(from_attributes=True)

class GetScannedResult(BaseModel):
    full_name : str 
    phone_number : str 
    office_number : str 
    web_site : str 
    company_name : str 
    email : str 
    address : str 
    job_title : str 
    city : str 
    country : str 