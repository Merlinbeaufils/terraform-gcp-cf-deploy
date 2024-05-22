import firebase_admin
from firebase_admin import firestore, credentials
from app.user.domain.user import User

from app.user.infrastructure.exceptions import UserNotFound


class UserRepository:
    """
    Firestore implementation of user handling.
    Implements the set, remove and update methods to the chosen firestore collection.
    """

    def __init__(self, collection: str):
        self._collection = collection

        cred = credentials.ApplicationDefault()

        firebase_admin.initialize_app(cred)
        self.db = firestore.client()

    def set(self, user: User) -> None:

        user_dict = user.to_dict()

        ref = self.db.collection(self._collection).document(user_dict["id"])
        ref.set(user_dict)

    def remove(self, user_id: str) -> None:
        if not self.db.collection(self._collection).document(user_id).get().exists:
            raise UserNotFound("User does not exist")

        ref = self.db.collection(self._collection).document(user_id)
        ref.delete()

    def update(self, user: User) -> None:
        user_dict = user.to_dict()

        ref = self.db.collection(self._collection).document(user_dict["id"])
        if ref.get().exists:
            ref.set(user_dict)
            return

        else:
            raise UserNotFound("User does not exist")

