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

env = gridSearch_setup.GridworldEnv()

print(env.P)

def policy_evaluation(policy, env, discount_factor = 1, theta = 1e-4):
    """
    Evaluate a policy given an environment and a full description of the environment's dynamics.
    
    Args:
        policy: [S, A] shaped matrix representing the policy.
        env: OpenAI env. env.P represents the transition probabilities of the environment.
            env.P[s][a] is a (prob, next_state, reward, done) tuple.
        theta: We stop evaluation one our value function change is less than theta for all states.
        discount_factor: lambda discount factor.
    
    Returns:
        Vector of length env.nS representing the value function.
    """
    
    V = np.zeros(env.nS)
    while True:
        delta = 0
        for s in range(env.nS): ## for each state, we are performing a full backup
            v = 0
            for a, action_prob in enumerate(policy[s]): ## look at the possible next actions
                for prob, next_state, reward, done in env.P[s][a]: ## for each action, look at next stages:
                    
                    v += action_prob * prob * (reward + discount_factor * V[next_state]) ## calculate the expected value
                    
                    #print(s, a, action_prob, prob, next_state, reward, done, v)
            delta = max(delta, np.abs(v-V[s])) ## how much the value function changes in this one full backup
            V[s] = v    
       
        if delta < theta: ## stop evalution once the value function change is below the threshold
            break
    return np.array(V)


'''
test case: by giving a policy for it to evaluate. 
'''
random_policy = np.ones([env.nS, env.nA]) / env.nA
v=policy_evaluation(random_policy, env)
        

print("Value Function:")
print(v)
print("")

print("Reshaped Grid Value Function:")
print(v.reshape(env.shape))
print("")
        

# Test: Make sure the evaluated policy is what we expected
#expected_v = np.array([0, -14, -20, -22, -14, -18, -20, -20, -20, -20, -18, -14, -22, -20, -14, 0])
#np.testing.assert_array_almost_equal(v, expected_v, decimal=2)




'''
Policy Iteration - Follow a random polic and to maximize that going forward
'''
def policy_improvement(env, policy_eval_fn=policy_evaluation, discount_factor=1):
    """
    Policy Improvement Algorithm. Iteratively evaluates and improves a policy
    until an optimal policy is found.
    
    Args:
        env: The OpenAI envrionment.
        policy_eval_fn: Policy Evaluation function that takes 3 arguments:
            policy, env, discount_factor.
        discount_factor: Lambda discount factor.
        
    Returns:
        A tuple (policy, V). 
        policy is the optimal policy, a matrix of shape [S, A] where each state s
        contains a valid probability distribution over actions.
        V is the value function for the optimal policy.
        
    """
    # Start with a random policy
    policy = np.ones([env.nS, env.nA]) / env.nA  ## this gives an output of 16 * 4 of 1/4.
    
    counter = 0               
                    
    while True:
        # Evaluate the current policy
        V = policy_eval_fn(policy, env, discount_factor)
        
        # Will be set to false if we make any changes to the policy
        policy_stable = True
        
        
        # For each state...
        for s in range(env.nS): # 16 states
            
            # The best action we would take under the current policy
            chosen_a = np.argmax(policy[s]) ## this will start of all equal value of 0.25
            
            # Find the best action by one-step lookahead
            # Ties are resolved arbitarily
            action_values = np.zeros(env.nA) ## [0,0,0,0] 
            for a in range(env.nA):
                for prob, next_state, reward, done in env.P[s][a]:
                    action_values[a] += prob * (reward + discount_factor * V[next_state])
            best_a = np.argmax(action_values) ## Return the max index 
            
            # Greedily update the policy
            if chosen_a != best_a:
                policy_stable = False
            policy[s] = np.eye(env.nA)[best_a] ## create a 4* 4 diagonally and then pick an index
        
        # If the policy is stable we've found an optimal policy. Return it
        
        counter = counter + 1
        if policy_stable:
            return policy, V, counter
  
'''optimal policy'''
policy, v, iteration = policy_improvement(env)

print("Policy Probability Distribution:")
print(policy)
print("")

print("Reshaped Grid Policy (0=up, 1=right, 2=down, 3=left):")
print(np.reshape(np.argmax(policy, axis=1), env.shape))
print("")

print("Value Function:")
print(v)
print("")

print("Reshaped Grid Value Function:")
print(v.reshape(env.shape))
print("")







'''
Value-action iteration
'''
def value_iteration(env, theta=0.0001, discount_factor=1.0):
    """
    Value Iteration Algorithm.
    
    Args:
        env: OpenAI environment. env.P represents the transition probabilities of the environment.
        theta: Stopping threshold. If the value of all states changes less than theta
            in one iteration we are done.
        discount_factor: lambda time discount factor.
        
    Returns:
        A tuple (policy, V) of the optimal policy and the optimal value function.
    """
    
    def one_step_lookahead(state, V):
        """
        Helper function to calculate the value for all action in a given state.
        
        Args:
            state: The state to consider (int)
            V: The value to use as an estimator, Vector of length env.nS
        
        Returns:
            A vector of length env.nA containing the expected value of each action.
        """
        A = np.zeros(env.nA)
        for a in range(env.nA):
            for prob, next_state, reward, done in env.P[state][a]:
                A[a] += prob * (reward + discount_factor * V[next_state])
        return A
    
    V = np.zeros(env.nS)
    
    counter = 0
    while True:
        # Initiate the delta at 0
        delta = 0
        # Update each state...
        for s in range(env.nS):
            # Do a one-step lookahead to find the best action
            A = one_step_lookahead(s, V)
            best_action_value = np.max(A)
            # Calculate delta across all states seen so far
            delta = max(delta, np.abs(best_action_value - V[s]))
            # Update the value function
            V[s] = best_action_value
        counter += 1
        # Check if we can stop 
        if delta < theta:
            break
    
    # Create a deterministic policy using the optimal value function
    policy = np.zeros([env.nS, env.nA])
    for s in range(env.nS):
        # One step lookahead to find the best action for this state
        A = one_step_lookahead(s, V)
        best_action = np.argmax(A)
        # Always take the best action
        policy[s, best_action] = 1.0
    
    return policy, V, counter

(value_iteration(env))[2]