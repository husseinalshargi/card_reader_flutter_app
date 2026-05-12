from fastapi import HTTPException, status
from sqlalchemy import exists
from sqlalchemy.orm import Session

from reader_back_end.db.models.card import Card
from reader_back_end.db.schemas.card import SaveCard
class CardRepository:

    def get_card(db: Session, id: str, user_id : str) -> Card:
        card = db.query(Card).filter(Card.id == id, Card.user_id == user_id).first()

        if card is None:
            #if no cards found
            raise HTTPException(status_code= status.HTTP_500_INTERNAL_SERVER_ERROR, detail= "Couldn't fetch card details")

        return card
    
    def upsert_card(db: Session, card_data: SaveCard, user_id : str):
        try:
            card = Card(user_id = user_id, 
                        full_name = card_data.full_name, 
                        phone_number = card_data.phone_number,
                        office_number = card_data.office_number,
                        web_site = card_data.web_site,
                        company_name = card_data.company_name,
                        email = card_data.email,
                        address = card_data.address,
                        job_title = card_data.job_title,
                        city = card_data.city,
                        country = card_data.country
                        )
            
            # this is no longer used as the id will be generated from the backend
            # check if card is already in the db, if yes just update it
            # Return the first element of the first result or None if no rows present. If multiple rows are returned, raises
            # this will be used only in unique columns "scalar"
            # is_exist = db.query(exists().where(Card.id == card.id)).scalar()

            # if (not is_exist):
            if (card_data.id is None): # the card id won't be passed when creating
                # save it if there isn't any (None)
                db.add(card)
                db.commit()
                db.refresh(card)

                return card
            

            num_of_cards_affected = db.query(Card).filter(Card.id == card_data.id, Card.user_id == user_id).update(
                {Card.full_name : card_data.full_name,
                Card.phone_number : card_data.full_name,
                Card.office_number : card_data.office_number,
                Card.web_site : card_data,
                Card.company_name : card_data.web_site,
                Card.email : card_data.email,
                Card.address : card_data.address,
                Card.job_title : card_data.job_title,
                Card.city : card_data.city,
                Card.country : card_data.country})
        
            if num_of_cards_affected != 1:
                # this means more than one row has been affected so cancel the update query
                raise HTTPException(status_code= status.HTTP_400_BAD_REQUEST, detail= "Couldn't update the card, as something went wrong")
            
            db.commit()
            db.refresh()            
        except:
            raise HTTPException(status_code= status.HTTP_500_INTERNAL_SERVER_ERROR, detail= "Couldn't upsert the card")
        
        return card
    
    def get_all_cards(db: Session, user_id : str):
        try:
            return db.query(Card).filter(Card.user_id == user_id).all()
        except:
            raise HTTPException(status_code= status.HTTP_500_INTERNAL_SERVER_ERROR, detail= "Couldn't get user's cards")
        
    def delete_card (db: Session, card_id: str, user_id: str):
        try:            
            # check if card is already in the db, if yes delete it
            #Return the first element of the first result or None if no rows present. If multiple rows are returned, raises
            # this will be used only in unique columns "scalar"
            is_exist = db.query(exists().where(Card.id == card_id)).scalar()

            if (not is_exist):
                # if none then rise an error
                raise HTTPException(status.HTTP_404_NOT_FOUND, "couldn't delete the card as it were not found")
            

            num_of_cards_affected = db.query(Card).filter(Card.id == card_id, Card.user_id == user_id).delete()
        
            if num_of_cards_affected != 1:
                # this means more than one row has been affected so cancel the update query
                raise HTTPException(status_code= status.HTTP_400_BAD_REQUEST, detail= "Couldn't update the card, as something went wrong")
            
            db.commit()
        except:
            raise HTTPException(status_code= status.HTTP_500_INTERNAL_SERVER_ERROR, detail= "Couldn't delete the card")
        




