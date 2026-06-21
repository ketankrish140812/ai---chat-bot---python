# ai---chat-bot---python
        Simple AI chatbot using Python and prompt-based logic

from flask import Flask, render_template, request, jsonify
import openai
import os

app = Flask(__name__)

# Put your API key in environment variable
openai.api_key = os.getenv("OPENAI_API_KEY")

def get_ai_response(user_input):
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a helpful AI assistant."},
                {"role": "user", "content": user_input}
            ]
        )
        return response["choices"][0]["message"]["content"]

    except Exception as e:
        return "Error: " + str(e)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/chat", methods=["POST"])
def chat():
    user_message = request.json["message"]
    reply = get_ai_response(user_message)
    return jsonify({"response": reply})

if __name__ == "__main__":
    app.run(debug=True)