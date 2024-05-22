from app.user.domain.user import User


class AnalyticUser(User):
    hours: int
    minutes: int
    interests: list
    last_login: str
    last_logout: str

