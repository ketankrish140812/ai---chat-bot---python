#!/usr/bin/env python3
"""Echo Runner — a terminal maze game.

Find the exit before your own echo does. Every move you make is logged; a
set number of turns after you start, an "echo" of your former self spawns
at the entrance and silently replays your exact move history, always
trailing exactly ``echo_delay`` turns behind you. Backtracking or looping
doesn't slow it down and doesn't help you either — it just means the echo
is following the same detour, ``echo_delay`` turns later. The only way to
survive is to keep making net progress toward the exit.

Run it:
    python3 main.py                 # interactive
    python3 main.py --difficulty hard
    python3 main.py --demo          # non-interactive random-walk demo
"""

import argparse
import sys

from echo_runner.game import EchoRunner, GameStatus
from echo_runner.render import render_maze
from echo_runner.scores import record_win

DIFFICULTIES = {
    "easy": dict(width=11, height=9, echo_delay=9),
    "normal": dict(width=15, height=11, echo_delay=6),
    "hard": dict(width=19, height=13, echo_delay=4),
}

KEY_TO_DIRECTION = {
    "w": "N", "n": "N", "north": "N", "up": "N",
    "s": "S", "south": "S", "down": "S",
    "a": "W", "west": "W", "left": "W",
    "d": "E", "east": "E", "right": "E",
}

HELP_TEXT = (
    "Move with W/A/S/D (or N/S/E/W). Other commands: MAP, HELP, QUIT."
)


def describe_echo(game):
    if game.status != GameStatus.PLAYING:
        return ""
    if game.echo_active:
        return "  Your echo is moving. Don't stop."
    remaining = game.turns_until_echo()
    if remaining <= 1:
        return "  Your echo stirs. It wakes next turn."
    return f"  Your echo wakes in {remaining} turns."


def print_frame(game, show_map):
    if show_map:
        echo_pos = game.echo_pos if game.echo_active else None
        print()
        print(render_maze(game.maze, player=game.player, echo=echo_pos, exit_pos=game.exit))
    print(f"\nTurn {game.turn} | You: {game.player} | Exit: {game.exit}{describe_echo(game)}")
    if game.message:
        print(game.message)


def play_interactive(difficulty, seed):
    settings = DIFFICULTIES[difficulty]
    game = EchoRunner(seed=seed, **settings)

    print("=" * 60)
    print("ECHO RUNNER")
    print("=" * 60)
    print(HELP_TEXT)
    print(f"Difficulty: {difficulty} ({settings['width']}x{settings['height']}, "
          f"echo wakes after {settings['echo_delay']} turns)")
    print_frame(game, show_map=True)

    while game.status == GameStatus.PLAYING:
        try:
            raw = input("\nmove> ").strip().lower()
        except EOFError:
            print("\nNo more input — ending the run.")
            return

        if raw in ("q", "quit", "exit"):
            print("You slip out of the maze early. The echo waits for next time.")
            return
        if raw in ("h", "help", "?"):
            print(HELP_TEXT)
            continue
        if raw in ("m", "map"):
            print_frame(game, show_map=True)
            continue
        if raw == "":
            continue

        direction = KEY_TO_DIRECTION.get(raw, raw.upper())
        moved = game.attempt_move(direction)
        print_frame(game, show_map=moved)

    if game.status == GameStatus.WON:
        is_best, best = record_win(difficulty, game.turn)
        if is_best:
            print(f"New best for {difficulty}: {best} turns!")
        else:
            print(f"Best for {difficulty} remains {best} turns.")
    elif game.status == GameStatus.LOST:
        print("Game over. Every step you take, it takes too — just late.")


def play_demo(difficulty, seed, max_turns=500):
    """Non-interactive random walk, useful for smoke-testing without a TTY."""
    import random

    settings = DIFFICULTIES[difficulty]
    game = EchoRunner(seed=seed, **settings)
    rng = random.Random(seed)
    from echo_runner.maze import DIRECTIONS

    print(f"Demo run on '{difficulty}' (seed={seed})")
    while game.status == GameStatus.PLAYING and game.turn < max_turns:
        legal = [d for d in DIRECTIONS if game.maze.can_move(game.player, d)]
        game.attempt_move(rng.choice(legal))

    print_frame(game, show_map=True)
    if game.status == GameStatus.PLAYING:
        print(f"Demo ended after {max_turns} turns without a result.")
    return game.status


def main(argv=None):
    parser = argparse.ArgumentParser(description="Echo Runner: outrun your own echo.")
    parser.add_argument("--difficulty", choices=DIFFICULTIES.keys(), default="normal")
    parser.add_argument("--seed", type=int, default=None, help="maze seed, for a repeatable layout")
    parser.add_argument("--demo", action="store_true", help="watch a random-walk demo instead of playing")
    args = parser.parse_args(argv)

    if args.demo:
        play_demo(args.difficulty, args.seed)
    else:
        play_interactive(args.difficulty, args.seed)
    return 0


if __name__ == "__main__":
    sys.exit(main())
