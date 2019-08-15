import numpy as np
import random
import time
import os
import gc

import pdb

from collections import deque

from keras.models import Sequential, clone_model
from keras.layers import Dense, Flatten, Conv2D, InputLayer
from keras.callbacks import CSVLogger, TensorBoard
from keras.optimizers import Adam
import keras.backend as K

def epsilon_greedy(q_values, epsilon, n_outputs):
    if random.random() < epsilon:
        return random.randrange(n_outputs)  # random action
    else:
        return np.argmax(q_values)  

def mean_q(y_true, y_pred):
    return K.mean(K.max(y_pred, axis=-1))

def get_state(obs):
    v = []
    x,y = obs['player']
    v.append(x)
    v.append(y)
    for x, y in obs['monsters']:
        v.append(x)
        v.append(y)
    for x, y in obs['diamonds']:
        v.append(x)
        v.append(y)
    for x, y in obs['walls']:
        v.append(x)
        v.append(y)
    return v

class QLearn:

    def __init__(self, env):

        self.env = env
        obs = self.env.reset()
        state = get_state(obs)
        self.input_shape = (len(state),)
        self.nb_actions = 9
        self.dense_layers = 5
        self.dense_units = 256

        self.online_network = self.create_model(
            input_shape = self.input_shape,
            nb_actions = self.nb_actions,
            dense_layers = self.dense_layers,
            dense_units = self.dense_units)

        self.target_network = clone_model(self.online_network)
        self.target_network.set_weights(self.online_network.get_weights())
        self.replay_memory = deque([], maxlen=1000000)

    def create_model(self, input_shape, nb_actions, dense_layers, dense_units):
        model = Sequential()
        model.add(InputLayer(input_shape=input_shape))
        for i in range(dense_layers):
            model.add(Dense(units=dense_units, activation='relu'))
        model.add(Dense(nb_actions, activation='linear'))
        return model

    def train(self, 
              name, 
              n_steps, # total number of training steps (= n_epochs)
              warmup,  # start training after warmup iterations
              training_interval, # period (in actions) between training steps
              copy_steps, # period (in training steps) between updating target_network weights
              gamma, # discount rate
              skip_start, # skip the start of every game (it's just freezing time before game starts)
              batch_size, # size of minibatch that is taken randomly from replay memory every training step
              double_dqn, # whether to use Double-DQN approach or simple DQN (see above)
              eps_max, 
              eps_min, 
              learning_rate
              ):

        save_steps = int(n_steps/100)  # period (in training steps) between storing weights to file
        eps_decay_steps = int(n_steps/2)

        self.online_network.compile(optimizer=Adam(learning_rate), loss='mse', metrics=[mean_q])

        if not os.path.exists(name):
            os.makedirs(name)
            
        weights_folder = os.path.join(name, 'weights')
        if not os.path.exists(weights_folder):
            os.makedirs(weights_folder)

        csv_logger = CSVLogger(os.path.join(name, 'log.csv'), append=True, separator=';')

        # counters:
        step = 0          # training step counter (= epoch counter)
        iteration = 0     # frames counter
        episodes = 0      # game episodes counter
        done = True       # indicator that env needs to be reset

        episode_scores = []  # collect total scores in this list and log it later

        obs = self.env.reset()
        obs['end_game'] = True
        while step < n_steps:
            if obs['end_game']:
                obs = self.env.reset()
                score = 0  # reset score for current episode
                # for skip in range(skip_start):  # skip the start of each game (it's just freezing time before game starts)
                #     obs = self.env.make_action(0)
                #     reward = obs['reward']
                #     score += reward
                state = get_state(obs)
                episodes += 1

            # Online network evaluates what to do
            iteration += 1
            q_values = self.online_network.predict(np.array([state]))[0]  # calculate q-values using online network
            # select epsilon (which linearly decreases over training steps):
            epsilon = max(eps_min, eps_max - (eps_max-eps_min) * step/eps_decay_steps)
            action = epsilon_greedy(q_values, epsilon, self.nb_actions)
            # Play:
            obs = self.env.make_action(action + 1)
            reward = obs['reward']
            score += reward
            if obs['end_game']:
                episode_scores.append(score)
            next_state = get_state(obs)
            # Let's memorize what just happened
            self.replay_memory.append((state, action, reward, next_state, obs['end_game']))
            state = next_state

            if iteration >= warmup and iteration % training_interval == 0:
                # learning branch
                step += 1
                minibatch = random.sample(self.replay_memory, batch_size)
                replay_state = np.array([x[0] for x in minibatch])
                replay_action = np.array([x[1] for x in minibatch])
                replay_rewards = np.array([x[2] for x in minibatch])
                replay_next_state = np.array([x[3] for x in minibatch])
                replay_done = np.array([x[4] for x in minibatch], dtype=int)

                # calculate targets (see above for details)
                if double_dqn == False:
                    # DQN
                    target_for_action = replay_rewards + (1-replay_done) * gamma * \
                                            np.amax(self.target_network.predict(replay_next_state), axis=1)
                else:
                    # Double DQN
                    best_actions = np.argmax(self.online_network.predict(replay_next_state), axis=1)
                    target_for_action = replay_rewards + (1-replay_done) * gamma * \
                                            self.target_network.predict(replay_next_state)[np.arange(batch_size), best_actions]

                target = self.online_network.predict(replay_state)  # targets coincide with predictions ...
                target[np.arange(batch_size), replay_action] = target_for_action  #...except for targets with actions from replay
                
                # Train online network
                self.online_network.fit(replay_state, target, epochs=step, verbose=2, initial_epoch=step-1,
                                   callbacks=[csv_logger])

                # Periodically copy online network weights to target network
                if step % copy_steps == 0:
                    self.target_network.set_weights(self.online_network.get_weights())
                # And save weights
                if step % save_steps == 0:
                    self.online_network.save_weights(os.path.join(weights_folder, 'weights_{}.h5f'.format(step)))
                    gc.collect()  # also clean the garbage

        self.online_network.save_weights(os.path.join(weights_folder, 'weights_last.h5f'))


    def dqn_strategy(self, obs):
        state = get_state(obs)
        q_values = self.online_network.predict(np.array([state]))[0]
        return epsilon_greedy(q_values, 0.05, self.nb_actions) + 1

if __name__ == "__main__":
    import json
    import config
    from mini_pacman import PacmanGame
    from mini_pacman import test, random_strategy, naive_strategy

    with open('test_params.json', 'r') as file:
        read_params = json.load(file)
    game_params = read_params['params']
    env = PacmanGame(**game_params)

    DQN = QLearn(env)

    train_params = config.training_params_local # change to rcc for real training

    DQN.train(
        name = train_params['name'],
        n_steps = train_params['n_steps'],
        warmup = train_params['warmup'],
        training_interval = train_params['training_interval'],
        copy_steps = train_params['copy_steps'],
        gamma = train_params['gamma'],
        skip_start = train_params['skip_start'],
        batch_size = train_params['batch_size'],
        double_dqn = train_params['double_dqn'],
        eps_max = train_params['eps_max'],
        eps_min = train_params['eps_min'], 
        learning_rate = train_params['learning_rate'])

    weights_folder = os.path.join(train_params['name'], 'weights')
    DQN.online_network.load_weights(os.path.join(weights_folder, 'weights_last.h5f'))

    test(strategy=DQN.dqn_strategy, log_file='test_pacman_log_DQN_local_2.json')
