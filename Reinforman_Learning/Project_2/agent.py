import os.path
import pickle
import random
import numpy as np

from keras.models import Sequential
from keras.layers import *
from keras.optimizers import *
from keras import backend as K

from memory import Memory


class DQNAgent(object):
    """ This agent uses DQN for making action decisions with 1-epsilon probability """

    def __init__(self, name, state_dim, action_dim, epsdecay=0.995,
                 buffersize=500000, samplesize=32, minsamples=10000,
                 gamma=0.99, state_norm_file='../params/state-stats.pkl', update_target_freq=600,
                 LEARNING_RATE = 1e-4):
        """ Accepts a unique agent name, number of variables in the state,
            number of actions and parameters of DQN then initialize the agent"""

        # Unique name for the agent
        self.name       = name
        # no:of state and action dimensions
        self.state_dim  = state_dim
        self.action_dim = action_dim
        # Create buffer for experience replay
        self.memory     = Memory(maxsize=buffersize)


        # Set initial epsilon to 1.0
        self.eps        = 1.0
        # Minimum number of samples in the buffer to start learning
        self.minsamples = minsamples
        # Number of random samples to be drawn from the buffer for experience replay
        self.samplesize = samplesize
        # Decay factor for epsilon for each episode
        self.epsdecay   = epsdecay
        # Discount factor for Q learning
        self.gamma      = gamma
        self.LEARNING_RATE = LEARNING_RATE


        # Create the base predictor neural network
        # and if required the target neural network too.
        self._create_nns_()
        # Load the state variable normalizers from pickle file if exists
        self.update_target_freq = update_target_freq
        # Boolean flag indicating whether the agent started learning or not
        self.started_learning = False
        # Keeps a count of number of steps.
        self.steps = 0

    def _preprocess_state_(self, instate):
        self.mean = np.zeros(self.state_dim)
        self.std  = np.ones(self.state_dim)
        # Normalize raw state vector by mean and std normalizers
        return ((instate - self.mean)/self.std)



    def _create_nns_(self):
        # Create predictor DQN
        self.model        = self._create_model_()
        self.target_model = self._create_model_()

    def _create_model_(self):
        model = Sequential()
        ## Flatten the input shape, it doesn't affect the batch size. input_shape (1, ) + (4, )
        model.add(Dense(40, input_dim=self.state_dim))
        model.add(Activation('relu'))
        ## now the model will take as input arrays of shape (*, 4) and output arrays of shape (*, 32)
        ## using the actiation function of relu sigmol?

        # Second layers
        model.add(Dense(32))
        model.add(Activation('relu'))

        # Thirsday layers
        model.add(Dense(16))
        model.add(Activation('relu'))

        # Output layers, output dimension is the number of the classes in the multi-classifier
        model.add(Dense(self.action_dim))
        model.add(Activation('linear'))

        ## adam is optimization function, loss function is mse
        adam = Adam(lr=self.LEARNING_RATE)
        model.compile(loss='mse',optimizer=adam)
        return model

    def _update_target_model_(self):
        # Copy weights from predictor NN to target network.
        self.target_model.set_weights(self.model.get_weights())

    def decide(self, curstate, testmode=False):
        """ Accepts current state as input and returns action to take """
        # Do not do eps greedy policy for test trials
        if not testmode:
            if (random.random() <= self.eps) or (not self.started_learning):
                return random.randint(0, self.action_dim-1)
        # convert state to a matrix with one row
        s = np.array([self._preprocess_state_(curstate)])
        # Return the action with maximum predicted Q value.
        return np.argmax(self.model.predict(s)[0])

    def observe(self, prevstate, action, reward, curstate, done):
        """ Accepts an observation (s,a,r,s',done) as input, store them in memory buffer for
            experience replay """
        # Normalize both states
        prevstate_normalized = self._preprocess_state_(prevstate)
        curstate_normalized  = self._preprocess_state_(curstate)

        # Save a singe observation into the format of the <curr_state, actin, reward, next_State, done>
        self.memory.save(prevstate_normalized, action, reward, curstate_normalized, done)
        if done:
            # Finished episode, so time to decay epsilon
            self.eps *= self.epsdecay
        if self.steps % self.update_target_freq == 0:
            # Time to update the weights of target network
            self._update_target_model_()
        # Increment step count
        self.steps += 1

    def learn(self):
        # Do not learn if number of observations in buffer is low
        if self.memory.getsize() <= self.minsamples:
            return 0.0
        # Start training
        if not self.started_learning:
            self.started_learning = True
        # Compute a batch of inputs and targets for training the predictor DQN.
        X, y = self._compute_training_batch_()
        # Do one learning step (epoch=1) with the give (X, y)
        history = self.model.fit(X, y, batch_size=self.samplesize, epochs=1, verbose=False)
        # Return the loss of this training step.
        return history.history['loss'][-1]

    def _compute_training_batch_(self):
        # Get a random sample of specified size from the buffer
        s, a, r, s1, done = self.memory.sample(self.samplesize)
        # Convert plain list of states to numpy matrices
        s  = np.array(s)
        s1 = np.array(s1)
        # Get prediction of s with predictor DQN.
        q  = self.model.predict(s)
        # Get prediction of s1 with target DQN if possible or else do with predictor DQN.
        q1 = self.target_model.predict(s1)

        # Input batch X has been computed (s)
        X = s
        # Make space for storing targets.
        y = np.zeros((self.samplesize, self.action_dim))
        # Iterate over each observation in the random sample


        for i in range(self.samplesize):
            reward = r[i]
            action = a[i]
            target = q[i]
            # We can improve only the target for the action in the observation <s,a,r,s'>
            target_for_action = reward
            if not done[i]:
                # if not add to it the discounted future rewards per current policy
                target_for_action += ( self.gamma*max(q1[i]) )
            # this is on e it's the terminal state


            # now store into target library
            target[action] = target_for_action
            # Assign computed target for the observation index = idx
            y[i, :] = target
        return X, y
