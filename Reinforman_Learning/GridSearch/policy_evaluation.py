# -*- coding: utf-8 -*-
"""
Created on Mon Oct  2 10:38:35 2017

MDP (Policy Evaluation, )

@author: ruonan.ding
"""

'''
Markov Decision Process:  You need only 3 things: the state you are in, the action you \n
decide to take and the transition function (probabilty of landing to a new state).
'''

'''
Value Function V(s) can only show how good it is for an agent to be in a particular state. 
Note that the value function is specific to a given policy. 
''' 

cd C:\Users\ruonan.ding\Documents\Github\rding.github.io\Reinforman_Learning\GridSearch
## This is to import the gridSearch_setup
                                        
import numpy as np
import gridSearch_setup


def policy_evaluation(policy, env, discount_factor = 1.0, theta = 1e-4):
    """
    """
    
    V = np.zeros(env.nS) # Start with a random all 0 value function. In this case

    while True:
        delta = 0
        for s in range(env.nS): ## for each state, we are performing a full backup
            v = 0
            for a, action_prob in enumerate(policy[s]): ## look at the possible next actions
                for prob, next_state, reward, done in env.P[s][a]: ## for each action, look at next stages:
                    
                    v += action_prob * prob * (reward + discount_factor * V[next_state]) ## calculate the expected value
                    
                    print(s, a, action_prob, prob, next_state, reward, done, v)
            delta = max(delta, np.abs(v-V[s])) ## how much the value function changes in this one full backup
            V[s] = v    
       
        if delta < theta: ## stop evalution once the value function change is below the threshold
            break
    return np.array(V)


'''
test case: by giving a policy for it to evaluate. 
'''
random_policy = np.ones([env.nS, env.nA]) / env.nA
policy_evaluation(random_policy, env)
        
        
        
    