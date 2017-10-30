import os
import pickle
class Experiment(object):
    def __init__(self, env, agent, verbose=True, num_episodes=1000):
        """ Takes a gym environment and an agent as inputs
            and initialize an experiment instance """
        # Save gym environment object
        self.env = env
        # Save agent object
        self.agent = agent
        # Total episodes in both test and train phase
        self.num_episodes = num_episodes
        # Compute environment name
        self.envname = env.__str__().split(' ')[0].lstrip('<')
        self.agentname = self.agent.name

    def run(self, testmode=False):
        """ Run num_episodes episodes on self.env with self.agent.
            It will let the agent learn only if testmode==False.
        """
        # Run the experiment with specified number of episodes
        # save the model weights with the loest average loss
        self.avgloss = []
        self.totalreward = []
        for episodeidx in range(self.num_episodes):
            # Get current state from gym env
            curstate = self.env.reset()
            # Flag to indicate if episode has ended.
            done = False
            # Training loss for the episode
            loss = 0.0
            # Episode length of the episode
            numsteps = 0
            # Total reward gained by the agent in current episode
            totreward = 0.0
            # Do till episode finishes
            while not done:
                # Increment step counter (episode length)
                numsteps += 1
                # Make the agent choose an action for current state
                action = self.agent.decide(curstate, testmode=testmode)
                prevstate = curstate
                # Let the gym env know about the action to be taken
                # and get next state, reward
                curstate, reward, done, _ = self.env.step(action)
                # Add the step reward to episode reward
                totreward += reward
                if not testmode:
                    # If in train mode, let the agent get the observation tuple (s,a,r,s')
                    self.agent.observe(prevstate, action, reward, curstate, done)
                    # Let the agent learn and add back this train loss to episode loss
                    loss += self.agent.learn()

            self.avgloss.append(loss/numsteps)
            self.totalreward.append(totreward)

            print("Episode finished!")
            print("************************")
            print("episode: ", episodeidx, "Average Loss :", loss/numsteps, "reward: ", totreward)

        return self.avgloss, self.totalreward
