import unittest

from echo_runner.maze import Maze


class TestMazeGeneration(unittest.TestCase):
    def test_dimensions(self):
        maze = Maze.generate(5, 4, seed=1)
        self.assertEqual(maze.width, 5)
        self.assertEqual(maze.height, 4)
        self.assertEqual(len(maze.walls), 20)

    def test_every_cell_reachable_perfect_maze(self):
        maze = Maze.generate(9, 7, seed=42)
        reachable = maze.reachable_from((0, 0))
        all_cells = {(x, y) for y in range(7) for x in range(9)}
        self.assertEqual(reachable, all_cells)

    def test_deterministic_with_same_seed(self):
        a = Maze.generate(8, 8, seed=7)
        b = Maze.generate(8, 8, seed=7)
        self.assertEqual(a.walls, b.walls)

    def test_different_seeds_usually_differ(self):
        a = Maze.generate(8, 8, seed=1)
        b = Maze.generate(8, 8, seed=2)
        self.assertNotEqual(a.walls, b.walls)

    def test_walls_are_symmetric(self):
        maze = Maze.generate(6, 6, seed=3)
        for (x, y), sides in maze.walls.items():
            for direction, is_wall in sides.items():
                neighbor = maze.neighbor((x, y), direction)
                if not maze.in_bounds(neighbor):
                    continue
                opposite = {"N": "S", "S": "N", "E": "W", "W": "E"}[direction]
                self.assertEqual(
                    is_wall,
                    maze.walls[neighbor][opposite],
                    f"Mismatched wall between {(x, y)} and {neighbor}",
                )

    def test_perfect_maze_has_no_loops(self):
        # A perfect maze on W*H cells has exactly W*H - 1 open passages.
        width, height = 6, 5
        maze = Maze.generate(width, height, seed=99)
        open_passages = sum(
            1
            for cell, sides in maze.walls.items()
            for direction, is_wall in sides.items()
            if not is_wall
        )
        # Each open passage is counted from both sides.
        self.assertEqual(open_passages // 2, width * height - 1)

    def test_rejects_degenerate_dimensions(self):
        with self.assertRaises(ValueError):
            Maze(0, 5)
        with self.assertRaises(ValueError):
            Maze(5, 0)

    def test_open_grid_has_no_internal_walls(self):
        maze = Maze.open_grid(4, 3)
        for x in range(4):
            for y in range(3):
                for direction in ("N", "S", "E", "W"):
                    neighbor = maze.neighbor((x, y), direction)
                    if maze.in_bounds(neighbor):
                        self.assertFalse(maze.walls[(x, y)][direction])


if __name__ == "__main__":
    unittest.main()
