from dataclasses import dataclass


@dataclass
class User:
    id: str
    name: str
    email: str

    def to_dict(self):
        return self.__dict__
