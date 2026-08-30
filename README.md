# ai---chat-bot---python

Simple AI chatbot using Python and prompt-based logic.

```python
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
```

## Echo Runner (a game)

A terminal maze game with a twist: **every move you make is logged, and
after a set number of turns, an "echo" of yourself spawns at the entrance
and silently replays your own move history**, always trailing exactly
`echo_delay` turns behind you. Backtracking doesn't slow it down — it just
means the echo repeats your detour a few turns later. Reach the exit
before your echo catches you.

Pure standard library, no dependencies.

### Play it

```bash
python3 main.py                       # normal difficulty, interactive
python3 main.py --difficulty hard     # smaller lead, tighter maze
python3 main.py --difficulty easy --seed 42   # repeatable maze layout
python3 main.py --demo                # watch a random-walk demo, no input needed
```

In-game commands: `w`/`a`/`s`/`d` (or `n`/`s`/`e`/`w`) to move, `map` to
redraw the maze, `help`, `quit`.

Winning a run on a given difficulty updates a local best-turns record in
`scores.json`.

### Project layout

- `echo_runner/maze.py` — perfect-maze generation (randomized DFS backtracker)
- `echo_runner/game.py` — game rules and the echo-chasing mechanic
- `echo_runner/render.py` — ASCII maze rendering
- `echo_runner/scores.py` — local best-score tracking
- `main.py` — CLI entry point
- `tests/` — unit tests (`python3 -m unittest discover -s tests`)