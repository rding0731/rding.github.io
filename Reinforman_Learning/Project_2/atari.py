

from agent import DQNAgent
from enviornment import Experiment
import random
import numpy as np

import gym

# Seed to be used for initializing the environment and agent for
# repeatability
seed = 16

# Create LunarLander-v2 gym environment
env = gym.make('LunarLander-v2')
# Set seed for PRN generator of numpy, random module and gym env.
np.random.seed(seed)
random.seed(seed)
env.seed(seed)

## Instantiate a basic DQN agent
ragent = DQNAgent(name='BasicDQNAgent-1', state_dim=env.observation_space.shape[0], action_dim=env.action_space.n, epsdecay=0.975,
                  buffersize=500000, samplesize=32, minsamples=1000, gamma=0.99, LEARNING_RATE = 0.001)

exp  = Experiment(env, ragent, verbose=True, num_episodes=100)

# Training trials
loss, reward = exp.run(testmode=False)

print (loss, reward)

test_loss, test_reward = exp.run(testmode=True)

print (test_loss, test_reward)
