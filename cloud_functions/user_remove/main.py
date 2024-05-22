import logging
import traceback

import flask

from app.user.dependency_injection import DependencyInjectionContainer as DI


def invoke(request: flask.Request):
    """
    Receives a ge request containing a user id in the query parameter and removes it from the database
    :param request:
    :return: flask response, http status code
    """
    if request.method == 'POST':
        raise Exception('POST method is not supported')

    try:
        print(request)
        id = request.args.get("query")
        di = DI()
        user_remover = di.remove_analytics_user_use_case()
        user_remover.invoke(id)

        response = {
            'query': id,
            "result": f"user # {id} removed successfully"
        }
        return flask.jsonify(response), 200

    except Exception as e:
        logging.error(f'{e}[{type(e)}]: {traceback.format_exc()}')
        return 'Error', 400
