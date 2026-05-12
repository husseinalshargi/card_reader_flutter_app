from sqlalchemy import Column, Integer, String

from reader_back_end.main import SQL_db

class Card(SQL_db.base):
    __tablename__ = "cards"

    id = Column(Integer, primary_key= True, autoincrement= True)
    user_id = Column(String(255), nullable= False)
    full_name = Column(String(255), nullable= True)
    phone_number = Column(String(255), nullable= True)
    office_number = Column(String(255), nullable= True)
    web_site = Column(String(255), nullable= True)
    company_name = Column(String(255), nullable= True)
    email = Column(String(255), nullable= True)
    address = Column(String(255), nullable= True)
    job_title = Column(String(255), nullable= True)
    city = Column(String(255), nullable= True)
    country = Column(String(255), nullable= True)
