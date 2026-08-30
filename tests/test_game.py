import unittest

from echo_runner.game import EchoRunner, GameStatus
from echo_runner.maze import Maze


class TestEchoRunnerBasics(unittest.TestCase):
    def test_blocked_move_does_not_advance_turn_or_player(self):
        maze = Maze(3, 3)  # every wall intact, nothing is passable
        game = EchoRunner(maze=maze, echo_delay=5)
        moved = game.attempt_move("E")
        self.assertFalse(moved)
        self.assertEqual(game.player, (0, 0))
        self.assertEqual(game.turn, 0)
        self.assertEqual(game.status, GameStatus.PLAYING)

    def test_unknown_direction_is_rejected(self):
        maze = Maze.open_grid(3, 3)
        game = EchoRunner(maze=maze, echo_delay=5)
        self.assertFalse(game.attempt_move("up-left"))
        self.assertEqual(game.turn, 0)

    def test_reaching_exit_wins(self):
        maze = Maze.open_grid(3, 1)
        game = EchoRunner(maze=maze, echo_delay=5)
        self.assertTrue(game.attempt_move("E"))
        self.assertEqual(game.status, GameStatus.PLAYING)
        self.assertTrue(game.attempt_move("E"))
        self.assertEqual(game.status, GameStatus.WON)
        self.assertEqual(game.player, game.exit)
        self.assertEqual(game.turn, 2)

    def test_moves_after_game_over_are_rejected(self):
        maze = Maze.open_grid(2, 1)
        game = EchoRunner(maze=maze, echo_delay=5)
        game.attempt_move("E")
        self.assertEqual(game.status, GameStatus.WON)
        self.assertFalse(game.attempt_move("W"))
        self.assertEqual(game.turn, 1)


class TestEchoMechanic(unittest.TestCase):
    def test_echo_stays_dormant_before_delay_elapses(self):
        maze = Maze.open_grid(5, 1)
        game = EchoRunner(maze=maze, echo_delay=3)
        for _ in range(3):
            game.attempt_move("E")
        self.assertFalse(game.echo_active)
        self.assertEqual(game.status, GameStatus.PLAYING)

    def test_echo_wakes_and_trails_by_delay(self):
        maze = Maze.open_grid(6, 1)
        game = EchoRunner(maze=maze, echo_delay=2)
        game.attempt_move("E")  # turn 1, player (1,0)
        game.attempt_move("E")  # turn 2, player (2,0)
        game.attempt_move("E")  # turn 3, echo wakes and takes move_log[0] -> (1,0)
        self.assertTrue(game.echo_active)
        self.assertEqual(game.echo_pos, (1, 0))
        self.assertEqual(game.player, (3, 0))
        self.assertEqual(game.status, GameStatus.PLAYING)

    def test_doubling_back_lets_the_echo_catch_you(self):
        # With echo_delay=2, moving E, E, W returns the player to the exact
        # cell it occupied one turn ago, which is exactly where a
        # 2-turn-delayed echo of "E, E" now stands.
        maze = Maze.open_grid(5, 1)
        game = EchoRunner(maze=maze, echo_delay=2)
        game.attempt_move("E")
        game.attempt_move("E")
        game.attempt_move("W")
        self.assertEqual(game.status, GameStatus.LOST)
        self.assertEqual(game.echo_pos, game.player)
        self.assertEqual(game.turn, 3)

    def test_turns_until_echo_counts_down(self):
        maze = Maze.open_grid(6, 1)
        game = EchoRunner(maze=maze, echo_delay=3)
        self.assertEqual(game.turns_until_echo(), 4)
        game.attempt_move("E")
        self.assertEqual(game.turns_until_echo(), 3)
        game.attempt_move("E")
        game.attempt_move("E")
        self.assertEqual(game.turns_until_echo(), 1)
        self.assertFalse(game.echo_active)
        game.attempt_move("E")
        self.assertEqual(game.turns_until_echo(), 0)
        self.assertTrue(game.echo_active)


if __name__ == "__main__":
    unittest.main()
