"""Core rules for Echo Runner.

The twist: every move you make is logged. Once ``echo_delay`` turns have
passed, an "echo" of yourself spawns at the start and silently replays your
own move history, always trailing exactly ``echo_delay`` turns behind you.
Backtrack, dawdle, or double back on yourself and you hand the echo a
shortcut to close the gap. Reach the exit before it catches you.
"""

from .maze import DIRECTIONS, Maze


class GameStatus:
    PLAYING = "PLAYING"
    WON = "WON"
    LOST = "LOST"


class EchoRunner:
    def __init__(self, width=15, height=11, echo_delay=6, seed=None, maze=None):
        self.width = width
        self.height = height
        self.echo_delay = echo_delay
        self.maze = maze if maze is not None else Maze.generate(width, height, seed=seed)
        self.start = (0, 0)
        self.exit = (self.maze.width - 1, self.maze.height - 1)

        self.player = self.start
        self.move_log = []  # directions the player has successfully taken
        self.turn = 0

        self.echo_pos = None
        self.echo_index = -1  # index into move_log the echo has replayed

        self.status = GameStatus.PLAYING
        self.message = "Find the exit before your echo finds you."

    @property
    def echo_active(self):
        return self.echo_pos is not None

    def attempt_move(self, direction):
        """Try to move the player one step. Returns True if the move was
        legal and the game state advanced; False otherwise (invalid
        direction, wall in the way, or the game has already ended)."""
        direction = direction.upper()
        if self.status != GameStatus.PLAYING:
            self.message = "The run is over — start a new one to play again."
            return False
        if direction not in DIRECTIONS:
            self.message = f"'{direction}' isn't a direction I know (use N/S/E/W)."
            return False
        if not self.maze.can_move(self.player, direction):
            self.message = "A wall blocks that path."
            return False

        self.player = self.maze.neighbor(self.player, direction)
        self.move_log.append(direction)
        self.turn += 1
        self.message = ""

        self._advance_echo()
        self._check_status()
        return True

    def _advance_echo(self):
        if self.turn <= self.echo_delay:
            return
        if self.echo_pos is None:
            self.echo_pos = self.start
            self.echo_index = 0
        else:
            self.echo_index += 1
        if self.echo_index < len(self.move_log):
            step = self.move_log[self.echo_index]
            self.echo_pos = self.maze.neighbor(self.echo_pos, step)

    def _check_status(self):
        if self.player == self.exit:
            self.status = GameStatus.WON
            self.message = f"You escaped in {self.turn} turns!"
        elif self.echo_active and self.echo_pos == self.player:
            self.status = GameStatus.LOST
            self.message = f"Your echo caught you on turn {self.turn}."

    def turns_until_echo(self):
        """How many more moves until the echo spawns (0 if already active)."""
        return max(0, self.echo_delay - self.turn + 1)
