"""Perfect-maze generation via randomized depth-first backtracking."""

import random

# Direction name -> (dx, dy)
DIRECTIONS = {
    "N": (0, -1),
    "S": (0, 1),
    "E": (1, 0),
    "W": (-1, 0),
}

OPPOSITE = {"N": "S", "S": "N", "E": "W", "W": "E"}


class Maze:
    """A rectangular grid maze.

    ``walls[(x, y)]`` maps each of the four cardinal directions to a bool:
    ``True`` means a wall blocks that side of the cell, ``False`` means the
    passage is open.
    """

    def __init__(self, width, height):
        if width < 1 or height < 1:
            raise ValueError("Maze dimensions must be at least 1x1.")
        self.width = width
        self.height = height
        self.walls = {
            (x, y): {"N": True, "S": True, "E": True, "W": True}
            for y in range(height)
            for x in range(width)
        }

    def in_bounds(self, pos):
        x, y = pos
        return 0 <= x < self.width and 0 <= y < self.height

    def can_move(self, pos, direction):
        if pos not in self.walls or direction not in DIRECTIONS:
            return False
        return not self.walls[pos][direction]

    def neighbor(self, pos, direction):
        dx, dy = DIRECTIONS[direction]
        return (pos[0] + dx, pos[1] + dy)

    def open_passage(self, a, direction):
        """Remove the wall between cell ``a`` and its neighbor in ``direction``."""
        b = self.neighbor(a, direction)
        if not self.in_bounds(b):
            raise ValueError(f"{b} is outside the maze.")
        self.walls[a][direction] = False
        self.walls[b][OPPOSITE[direction]] = False

    @classmethod
    def generate(cls, width, height, seed=None, start=(0, 0)):
        """Build a perfect maze (every cell reachable, no loops) using
        randomized depth-first backtracking."""
        maze = cls(width, height)
        rng = random.Random(seed)
        visited = {start}
        stack = [start]
        while stack:
            current = stack[-1]
            candidates = []
            for direction in DIRECTIONS:
                nxt = maze.neighbor(current, direction)
                if maze.in_bounds(nxt) and nxt not in visited:
                    candidates.append((direction, nxt))
            if not candidates:
                stack.pop()
                continue
            direction, nxt = rng.choice(candidates)
            maze.open_passage(current, direction)
            visited.add(nxt)
            stack.append(nxt)
        return maze

    @classmethod
    def open_grid(cls, width, height):
        """A maze with every internal wall removed. Handy for tests and for
        game modes that just want free movement on a bounded grid."""
        maze = cls(width, height)
        for y in range(height):
            for x in range(width):
                for direction in ("E", "S"):
                    nxt = maze.neighbor((x, y), direction)
                    if maze.in_bounds(nxt):
                        maze.open_passage((x, y), direction)
        return maze

    def reachable_from(self, start):
        """Breadth-first search; returns the set of reachable cells."""
        seen = {start}
        frontier = [start]
        while frontier:
            cell = frontier.pop()
            for direction in DIRECTIONS:
                if self.can_move(cell, direction):
                    nxt = self.neighbor(cell, direction)
                    if nxt not in seen:
                        seen.add(nxt)
                        frontier.append(nxt)
        return seen
