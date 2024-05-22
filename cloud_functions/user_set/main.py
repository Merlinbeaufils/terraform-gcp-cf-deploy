import logging
import traceback

import flask

from app.user.dependency_injection import DependencyInjectionContainer as DI
from app.user.domain.user import User


def invoke(request: flask.Request):
    """
    Receives a post request containing a user in json format and adds it to the database
    :param request:
    :return: flask response, http status code
    """
    if request.method == 'GET':
        raise Exception('GET method is not supported')

    try:
        print(request)
        request_json = request.get_json()

        user = User(**request_json)

        di = DI()

        user_setter = di.set_analytics_user_use_case()
        user_setter.invoke(user)

        response = {
            'query': {**request_json},
            "result": f"user # {user.id} added successfully"
        }
        return flask.jsonify(response), 200

    except Exception as e:
        logging.error(f'{e}[{type(e)}]: {traceback.format_exc()}')
        return 'Error', 400
