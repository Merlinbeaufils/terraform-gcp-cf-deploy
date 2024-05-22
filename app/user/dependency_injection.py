import os

from app.user.application.remove_user import UserRemover
from app.user.application.set_user import UserSetter
from app.user.application.update_user import UserUpdater
from app.user.infrastructure.user_repository import UserRepository

from dotenv import load_dotenv

load_dotenv()


class DependencyInjectionContainer:
    def __init__(self):
        self._analytic_user_collection_id = os.getenv("ANALYTIC_USER_COLLECTION_ID")

    def analytic_user_repository_imp(self):
        return UserRepository(
            collection=self._analytic_user_collection_id
        )

    def set_analytics_user_use_case(self):
        return UserSetter(
            user_repository=self.analytic_user_repository_imp(),
        )

    def remove_analytics_user_use_case(self):
        return UserRemover(
            user_repository=self.analytic_user_repository_imp(),
        )

    def update_analytics_user_use_case(self):
        return UserUpdater(
            user_repository=self.analytic_user_repository_imp(),
        )
