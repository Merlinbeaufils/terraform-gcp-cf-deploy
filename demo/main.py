""" demo for demonstrating the match algorithm through a streamlit app """

import streamlit as st
from demo.google_api_functions import get, post


endpoint_id = "kil67x3dpq"
simple_function_endpoint = f"https://simple-function-{endpoint_id}-uk.a.run.app"

st.title("Demo for interacting with deployed cloud functions")

st.header("Interact with the simple function you deployed")


with st.form(f"Call simple function"):
    submitted = st.form_submit_button(f"Call simple function")

    if submitted:
        data_result, http_code = get("bfifbis", simple_function_endpoint)

        if http_code == 200:
            st.write(f"Successfully ran **simple function** with response: {data_result}")

        else:
            st.write(f"Failed to run **simple function** with response: {data_result}, HTTP code: {http_code}")
