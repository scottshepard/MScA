### 25.09.2018


import numpy as np
import random
import math
import json


action_to_dxdy = {1: (1, -1),
                  2: (1, 0),
                  3: (1, 1),
                  4: (0, -1),
                  5: (0, 0),
                  6: (0, 1),
                  7: (-1, -1),
                  8: (-1, 0),
                  9: (-1, 1)}


def distance(p0, p1):  # euclidian distance between 2d-points
    return math.sqrt((p0[0] - p1[0]) ** 2 + (p0[1] - p1[1]) ** 2)


class PacmanGame:
    def __init__(self, field_shape, nmonsters, ndiamonds, nwalls,
                 monster_vision_range=1, max_moves=100,
                 diamond_reward=10, survival_reward=1):
        assert field_shape[0] * field_shape[1] > 1 + nmonsters + ndiamonds + nwalls, "Low field size"
        self.field_shape = field_shape
        self.nmonsters = nmonsters
        self.ndiamonds = ndiamonds
        self.nwalls = nwalls
        self.monster_vision_range = monster_vision_range
        self.max_moves = max_moves
        self.diamond_reward = diamond_reward
        self.survival_reward = survival_reward

        self.game_window = None

        self.total_score = 0
        self.end_game = True
        self.n_moves = 0
        self.delta_score = 0

        self.player = None
        self.monsters = None
        self.diamonds = None
        self.walls = None

        self.reset()

    def __del__(self):
        self.close()

    def close(self):
        self.close_window()
        self.end_game = True

    def close_window(self):
        if self.game_window is not None:
            self.game_window.close()
            self.game_window = None

    def reset(self):
        self.total_score = 0
        self.end_game = False
        self.n_moves = 0
        self.delta_score = 0

        # init positions of player, monsters, diamonds and walls
        reserved_coords = set()
        x = np.random.randint(self.field_shape[0])
        y = np.random.randint(self.field_shape[1])
        self.player = (x, y)
        reserved_coords.add(self.player)

        self.monsters = []
        for i in range(self.nmonsters):
            while (x, y) in reserved_coords:
                x = np.random.randint(self.field_shape[0])
                y = np.random.randint(self.field_shape[1])
            monster_coord = (x, y)
            reserved_coords.add(monster_coord)
            self.monsters.append(monster_coord)
        self.monsters.sort()  # to make state-space lower

        self.diamonds = []
        for i in range(self.ndiamonds):
            while (x, y) in reserved_coords:
                x = np.random.randint(self.field_shape[0])
                y = np.random.randint(self.field_shape[1])
            diamond_coord = (x, y)
            reserved_coords.add(diamond_coord)
            self.diamonds.append(diamond_coord)
        self.diamonds.sort()  # to make state-space lower

        self.walls = []
        for i in range(self.nwalls):
            while (x, y) in reserved_coords:
                x = np.random.randint(self.field_shape[0])
                y = np.random.randint(self.field_shape[1])
            wall_coord = (x, y)
            reserved_coords.add(wall_coord)
            self.walls.append(wall_coord)
        self.walls.sort()  # to make state-space lower

        obs = self.get_obs()
        return obs

    def get_field(self):
        field = np.full(shape=self.field_shape, fill_value=' ')
        field[self.player] = '☺' # '℗' #'@'
        for diamond_coord in self.diamonds:
            field[diamond_coord] = '♦' #'⟡' #'♦'
        for wall_coord in self.walls:
            field[wall_coord] = '▒'
        for monster_coord in self.monsters:
            field[monster_coord] = '☢' #'*'
        return field

    def print_field(self):
        m = self.get_field()
        print('╔' + '═' * m.shape[1] + '╗')
        for i in range(m.shape[0]):
            print('║' + ''.join(m[i,]) + '║')
        print('╚' + '═' * m.shape[1] + '╝')

    def render(self, pixels_per_square=50, score_height=100):
        import pyglet
        if self.game_window is None:
            self.game_window = pyglet.window.Window(width=pixels_per_square*self.field_shape[1],
                                                    height=pixels_per_square*self.field_shape[0] + score_height)
            pyglet.resource.path = ["sprites"]
            pyglet.resource.reindex()
            self.player_img = pyglet.resource.image("pacman.png")
            self.monster_img = pyglet.resource.image("monster.png")
            self.diamond_img = pyglet.resource.image("diamond.png")
            self.wall_img = pyglet.resource.image("wall.png")

        self.game_window.clear()
        self.game_window.switch_to()
        self.game_window.dispatch_events()
        # draw player
        sprite = pyglet.sprite.Sprite(self.player_img,
                                      x=int(self.player[1] * pixels_per_square),
                                      y=int((self.field_shape[0]-1-self.player[0]) * pixels_per_square + score_height))
        sprite.scale = min(pixels_per_square / sprite.width, pixels_per_square / sprite.height)
        sprite.draw()
        # draw diamonds
        for dc in self.diamonds:
            sprite = pyglet.sprite.Sprite(self.diamond_img,
                                          x=int(dc[1] * pixels_per_square),
                                          y=int((self.field_shape[0] - 1 - dc[0]) * pixels_per_square + score_height))
            sprite.scale = min(pixels_per_square / sprite.width, pixels_per_square / sprite.height)
            sprite.draw()
        # draw monsters
        for mc in self.monsters:
            sprite = pyglet.sprite.Sprite(self.monster_img,
                                            x=int(mc[1] * pixels_per_square),
                                            y=int((self.field_shape[0] - 1 - mc[0]) * pixels_per_square + score_height))
            sprite.scale = min(pixels_per_square / sprite.width, pixels_per_square / sprite.height)
            sprite.draw()
        # draw walls
        for wc in self.walls:
            sprite = pyglet.sprite.Sprite(self.wall_img,
                                          x=int(wc[1] * pixels_per_square),
                                          y=int((self.field_shape[0] - 1 - wc[0]) * pixels_per_square + score_height))
            sprite.scale = min(pixels_per_square / sprite.width, pixels_per_square / sprite.height)
            sprite.draw()
        # score label
        label = pyglet.text.Label(str(self.total_score),
                                  font_name='Times New Roman',
                                  font_size=score_height,
                                  x=0, y=0)
        label.draw()
        if self.end_game:
            label = pyglet.text.Label('Oops!',
                                      color=(255, 0, 0, 255),
                                      font_name='Times New Roman',
                                      font_size=int(score_height/3),
                                      x=self.game_window.width, y=int(score_height),
                                      anchor_x='right', anchor_y='top')
            label.draw()
        self.game_window.flip()

    def move_monsters(self):
        for i in range(len(self.monsters)):
            mc = self.monsters[i]
            possible_moves = {}
            for dx in [-1, 0, 1]:
                for dy in [-1, 0, 1]:
                    new_coord = (mc[0]+dx, mc[1]+dy)
                    if new_coord[0] in range(self.field_shape[0]) and \
                        new_coord[1] in range(self.field_shape[1]) and \
                        new_coord not in self.monsters and \
                        new_coord not in self.walls \
                            or new_coord == mc:
                        possible_moves[new_coord] = distance(self.player, new_coord)
            if distance(self.player, mc) > self.monster_vision_range:
                move = random.choice(list(possible_moves.keys()))
            else:
                move, _ = min(possible_moves.items(), key=lambda x: x[1])
            self.monsters[i] = move

    def get_obs(self):
        return {'reward': self.delta_score,
                'total_score': self.total_score,
                'end_game': self.end_game,
                'player': self.player,
                'monsters': list(self.monsters),
                'diamonds': list(self.diamonds),
                'walls': list(self.walls),
                'possible_actions': self.player_possible_actions()
                }

    def player_possible_actions(self):
        possible_moves = []
        for a, (dx, dy) in action_to_dxdy.items():
            x = self.player[0] + dx
            y = self.player[1] + dy
            if x in range(self.field_shape[0]) and \
                y in range(self.field_shape[1]) and \
                    (x, y) not in self.walls:
                possible_moves.append(a)
        return possible_moves

    def make_action(self, a):
        # @a is an int from action_to_dxdy.keys()
        assert not self.end_game, 'Game has ended!'
        assert a in action_to_dxdy.keys(), 'Wrong action!'
        dx, dy = action_to_dxdy[a]
        new_coord = (self.player[0] + dx, self.player[1] + dy)
        #assert new_coord[0] in range(self.field_shape[0]), 'Bad move (wall)!'
        #assert new_coord[1] in range(self.field_shape[1]), 'Bad move (wall)!'
        #assert new_coord not in self.walls, 'Bad move (wall)!'
        if new_coord[0] in range(self.field_shape[0]) and \
                new_coord[1] in range(self.field_shape[1]) and \
                new_coord not in self.walls:
            self.player = new_coord

        self.delta_score = 0

        # check if player collected a diamond
        if self.player in self.diamonds:
            self.delta_score += self.diamond_reward
            self.diamonds.remove(self.player)
            # add new diamond in random place
            while True:
                x = np.random.randint(self.field_shape[0])
                y = np.random.randint(self.field_shape[1])
                diamond_coord = (x, y)
                if diamond_coord not in self.diamonds and diamond_coord != self.player \
                    and diamond_coord not in self.walls and diamond_coord not in self.monsters:
                    break
            self.diamonds.append(diamond_coord)
            self.diamonds.sort()  # to make state-space lower

        # now monsters turn:
        self.move_monsters()
        self.monsters.sort()  # to make state-space lower

        if self.player in self.monsters:
            self.end_game = True
        else:
            self.delta_score += self.survival_reward

        self.total_score += self.delta_score

        self.n_moves += 1
        if self.n_moves >= self.max_moves:
            self.end_game = True

        obs = self.get_obs()
        return obs


# Code for testing results

def preprocess(start_state):
    # make tuples from lists
    start_state['player'] = tuple(start_state['player'])
    start_state['monsters'] = [tuple(m) for m in start_state['monsters']]
    start_state['diamonds'] = [tuple(d) for d in start_state['diamonds']]
    start_state['walls'] = [tuple(w) for w in start_state['walls']]


def test(strategy, log_file='test_pacman_log.json'):
    with open('test_params.json', 'r') as file:
        read_params = json.load(file)

    game_params = read_params['params']
    test_start_states = read_params['states']
    total_history = []
    total_scores = []

    env = PacmanGame(**game_params)
    for start_state in test_start_states:
        preprocess(start_state)
        episode_history = []
        env.reset()
        env.player = start_state['player']
        env.monsters = start_state['monsters']
        env.diamonds = start_state['diamonds']
        env.walls = start_state['walls']
        assert len(env.monsters) == env.nmonsters and len(env.diamonds) == env.ndiamonds and len(env.walls) == env.nwalls

        obs = env.get_obs()
        episode_history.append(obs)
        while not obs['end_game']:
            action = strategy(obs)
            obs = env.make_action(action)
            episode_history.append(obs)
        total_history.append(episode_history)
        total_scores.append(obs['total_score'])
    mean_score = np.mean(total_scores)
    median_score = np.median(total_scores)
    with open(log_file, 'w') as file:
        json.dump(total_history, file)
    print("Your average score is {}, median is {}, saved log to '{}'. "
          "Do not forget to upload it for submission!".format(mean_score, median_score, log_file))
    return median_score


# Some hand-made strategies

def random_strategy(obs):
    return random.choice(obs['possible_actions'])


def naive_strategy(obs):
    best_dist = 0
    best_act = 5
    for a in obs['possible_actions']:
        dx, dy = action_to_dxdy[a]
        p = obs['player'][0] + dx, obs['player'][1] + dy
        distances_to_monsters = [distance(p, monster) for monster in obs['monsters']]
        m = min(distances_to_monsters)
        if m > best_dist:
            best_dist = m
            best_act = a
    return best_act
