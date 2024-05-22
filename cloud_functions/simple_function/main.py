import logging
import traceback

import flask


def invoke(request: flask.Request):
    """
    Receives get request and returns a Hello world
    :param request:
    :return:
    """
    if request.method == 'POST':
        raise Exception('POST method is not supported')

    try:
        print(request)
        return 'Hello world', 200

    except Exception as e:
        logging.error(f'{e}[{type(e)}]: {traceback.format_exc()}')
        return 'Error', 400
