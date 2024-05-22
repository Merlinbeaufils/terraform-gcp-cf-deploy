from app.user.domain.user import User
from dataclasses import dataclass

from app.user.infrastructure.user_repository import UserRepository


@dataclass
class UserSetter:
    user_repository: UserRepository

    def invoke(self, user: User):
        """
        Some random app logic and processing here

        :return: None
        """
        self.user_repository.set(user)
