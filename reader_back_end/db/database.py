from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase, declarative_base

from settings.config import Config

class SqlDB:
    engine = create_engine(url=Config.mysql_url, echo=False)
    sessionmaker = sessionmaker(bind=engine)
    # uncomment this to see base commands instead of "any"
    # base = Base()
    base = declarative_base()

    def init_db():
        # import all models to create
        from db.models import card
        # create all tables 
        SqlDB.base.metadata.create_all(bind= SqlDB.engine)

    def get_db():
        try:
            db_session = SqlDB.sessionmaker()
            
            # pass the session until the request finish then it will be closed
            yield db_session
        finally:
            db_session.close()


# uncomment this to see base commands as it is "any"
# class Base(DeclarativeBase):
#     pass
        

        


