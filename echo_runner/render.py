"""ASCII rendering for a Maze plus game actors."""


def render_maze(maze, player=None, echo=None, exit_pos=None):
    w, h = maze.width, maze.height
    grid = [[" "] * (2 * w + 1) for _ in range(2 * h + 1)]

    for gy in range(0, 2 * h + 1, 2):
        for gx in range(0, 2 * w + 1, 2):
            grid[gy][gx] = "+"

    for y in range(h):
        for x in range(w):
            cell = maze.walls[(x, y)]
            gx, gy = 2 * x + 1, 2 * y + 1
            grid[gy - 1][gx] = "-" if cell["N"] else " "
            grid[gy + 1][gx] = "-" if cell["S"] else " "
            grid[gy][gx - 1] = "|" if cell["W"] else " "
            grid[gy][gx + 1] = "|" if cell["E"] else " "

    if exit_pos is not None:
        ex, ey = exit_pos
        grid[2 * ey + 1][2 * ex + 1] = "X"
    if echo is not None:
        sx, sy = echo
        grid[2 * sy + 1][2 * sx + 1] = "S"
    if player is not None:
        px, py = player
        grid[2 * py + 1][2 * px + 1] = "@"

    return "\n".join("".join(row) for row in grid)
