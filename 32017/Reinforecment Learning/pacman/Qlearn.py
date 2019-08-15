from mini_pacman import PacmanGame

class QLearn:
    def __init__(self, gamma=0.95, alpha=0.05):
        from collections import defaultdict
        self.gamma = gamma
        self.alpha = alpha
        self.qmap = defaultdict(int)

    def iteration(self, old_state, old_action, reward, new_state, new_possible_actions):
        # Produce iteration step (update Q-Value estimates)
        old_stateaction = tuple(old_state) + (old_action,)
        max_q = max([self.qmap[tuple(new_state) + (a,)] for a in new_possible_actions])
        self.qmap[old_stateaction] = (1-self.alpha)*self.qmap[old_stateaction] + self.alpha*(reward+self.gamma*max_q)
        return

    def best_action(self, state, possible_actions):
        # Get the action with highest Q-Value estimate for specific state
        a, q = max([(a, self.qmap[tuple(state) + (a,)]) for a in possible_actions], key=lambda x: x[1])
        return a

    def train(self, eps, n_games, ql, training, scores):
        for i in range(n_games):
            obs = env.reset() # restart game:
            state = get_state(obs)
            while not obs['end_game']:
                # select next action using strategy
                action = strategy(ql, state, obs['possible_actions'], eps=eps)
                new_obs = env.make_action(action)
                new_state = get_state(new_obs)
                if training:
                    # update Q-Value estimates
                    self.iteration(state, action, obs['reward'], 
                                 new_state, new_obs['possible_actions'])
                obs = new_obs
                state = new_state
            scores.append(obs['total_score'])
        return


if __name__ == "__main__":

    FIELD_SHAPE = (4, 4)
    N_MONSTERS = 1
    N_DIAMONDS = 1
    N_WALLS = 0
    MONSTER_VISION_RANGE = 1

    env = PacmanGame(field_shape=FIELD_SHAPE, nmonsters=N_MONSTERS,
                     ndiamonds=N_DIAMONDS, nwalls=N_WALLS,
                     monster_vision_range=MONSTER_VISION_RANGE)

    ### Make n_games lower if you get MemoryError

    ql = QLearn(gamma=0.95, alpha=0.05)
    train_scores = []  # container for results
    n_games = 100000  # number of games per eps
    eps_list = [0.9, 0.7, 0.5, 0.3, 0.2, 0.1, 0.05, 0.0]
    for eps in eps_list:
        print('Training with eps = {} ...'.format(eps))
        q1.train(eps, n_games, ql, training=True, scores=train_scores)
    print('Done.')




