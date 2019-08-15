training_params_local = {
    'name': 'MiniPacman',
    'n_steps': 10000,
    'warmup': 1000,
    'training_interval': 4,
    'copy_steps': 100,
    'gamma': 0.9,
    'skip_start': 90,   
    'batch_size': 64,
    'double_dqn': False,
    'eps_max': 1.0,
    'eps_min': 0.05,
    'learning_rate': 0.001
}

training_params_rcc = {
    'name': 'MiniPacman',
    'n_steps': 100000,
    'warmup': 10000,
    'training_interval': 400,
    'copy_steps': 1000,
    'gamma': 0.9,
    'skip_start': 90,
    'batch_size': 64,
    'double_dqn': False,
    'eps_max': 1.0,
    'eps_min': 0.05,
    'learning_rate': 0.001
}
