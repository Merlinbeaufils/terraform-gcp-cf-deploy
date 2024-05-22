import os
import requests
import google.oauth2.id_token as id_token
import google.auth.transport.requests as g_requests
from firebase_admin import credentials
from dotenv import load_dotenv


os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = ".auth/gcp_key.json"


cred = credentials.ApplicationDefault()


def get(input_text, endpoint):
    request = g_requests.Request()
    TOKEN = id_token.fetch_id_token(request, endpoint)
    print("token", TOKEN)
    r = requests.get(
        endpoint,
        headers={'Authorization': f"Bearer {TOKEN}", "Content-Type": "application/json"},
        params={"query": input_text}  # possible request parameters
    )
    if r.status_code != 200:
        print(f"Error: {r.status_code}")
        print(f"Response: {r.text}")
        return "Error", r.status_code
    return r.text, r.status_code


def post(dicto, endpoint):
    request = g_requests.Request()
    TOKEN = id_token.fetch_id_token(request, endpoint)
    print("token", TOKEN)
    r = requests.post(
        endpoint,
        headers={'Authorization': f'Bearer {TOKEN}'},
        json=dicto,
    )
    if r.status_code != 200:
        print(f"Error: {r.status_code}")
        print(f"Response: {r.text}")
        return "Error", r.status_code
    return r.text, r.status_code



