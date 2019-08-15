import json
from mini_pacman import PacmanGame
from mini_pacman import test, random_strategy, naive_strategy

with open('test_params.json', 'r') as file:
    read_params = json.load(file)
game_params = read_params['params']
env = PacmanGame(**game_params)

test(strategy=naive_strategy, log_file='test_pacman_log_naive.json')
