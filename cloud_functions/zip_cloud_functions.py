
import argparse
import os
from shutil import make_archive, rmtree, copytree


parser = argparse.ArgumentParser()

parser.add_argument('--prefix', type=str, default='')
parser.add_argument('--functions-dir', type=str, default='cloud_functions')
parser.add_argument('--output-dir', type=str, default='terraform/temp')
parser.add_argument('--app-dir', type=str, default='app')


CONFIG = parser.parse_args()

FUNCTIONS_DIR = str(os.path.join(CONFIG.prefix, CONFIG.functions_dir))
APP_DIR = str(os.path.join(CONFIG.prefix, CONFIG.app_dir))
OUTPUT_DIR = str(os.path.join(CONFIG.prefix, CONFIG.output_dir))


def get_functions(functions_dir: str = FUNCTIONS_DIR) -> list:
    """Get list of cloud functions names from the corresponding directory
    :param functions_dir: path to the cloud functions directory

    :return: list of function names
    """
    return [file.name for file in os.scandir(functions_dir) if file.is_dir()]


def join_code(function_dir, app_dir, output_dir):
    """ Join app and cloud functions code into a temp directory

    :return: None
    """
    app_output_dir = os.path.join(output_dir, 'app')

    copytree(function_dir, output_dir)
    copytree(app_dir, app_output_dir)

    return


if __name__ == '__main__':
    functions = get_functions()

    for function in functions:
        function_path = str(os.path.join(FUNCTIONS_DIR, function))
        output_path = str(os.path.join(OUTPUT_DIR, function))

        join_code(function_path, APP_DIR, output_path)
        
        make_archive(output_path, 'zip', output_path)
        rmtree(output_path)
