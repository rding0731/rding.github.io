# -*- coding: utf-8 -*-
"""
Created on Sat Sep 16 21:45:35 2017
Project 1: Repcliate Random Walk Result
@author: ruonan.ding
"""

import numpy as np
from sklearn.metrics import mean_squared_error
from math import sqrt
import matplotlib.pyplot as plt
import random
# 0 is the left terminal state A
# 6 is the right terminal state G
# 1 ... 5 represents State A ... E
states = np.zeros(7)
states[1:6] = 0.5
states[6] = 1      
      
# For convenience, we assume all rewards are 0
# and the left terminal state has value 0, the right terminal state has value 1
# This trick has been used in Gambler's Problem
Left = 0
Right = 1

# @states: current states value, will be updated if @batch is False
# @alpha: step size
# @batch: whether to update @states
def trajectory(states, alpha=0.1):
    currentState = 3
    trajectory = [currentState]
    while True:
        oldState = currentState
        if np.random.binomial(1, 0.5) == Left:
            currentState -=1
        else:
            currentState += 1
        reward = 0
        trajectory.append(currentState)
        states[oldState] += alpha * (reward + states[currentState] - states[oldState])
        if currentState == 0 or currentState == 6:
            break
    return trajectory

trajectory(states)
##############################################
def random_walk():
    x_i = [0., 0., 0., 1.0, 0.0, 0.0 , 0.0]
    X = [np.array(x_i)]
    while (True):
        move = random.randint(0, 1)
        i = x_i.index(1.)
        j = i+1 if move else i-1
        x_i[i] = 0.0
        x_i[j] = 1.0
        X.append(np.array(x_i))
        if j in [0, 6]:
            return X

##############################################
## the real training
n_training = 100
n_sequence = 10
training_set = [[random_walk() for i in range(n_sequence)] for j in range(n_training)]
##True value of the different state
trueValue = np.arange(1, 6) / 6.0

  
###############################################
## delta W
empty = np.array([0.0] * 7)

def prediction(X, W):
    return np.dot(W.T, X)

def sum_lambda(lam, X, t):
    _sum = np.copy(empty)
    for k in range(1, t+1):
        _sum += (lam ** (t-k)) * X[k]
    return _sum

## step2: Incremental_update
def td_lambda_incremental(sequence, weights, alpha, lam):
    W = np.copy(weights)
    for X in sequence:
        for t in range(len(X) - 1):
            P_t1 = prediction(X[t+1], W)
            P_t = prediction(X[t], W)
            W += alpha * (P_t1 - P_t) * sum_lambda(lam, X, t)
    return W

## Or: batch weight update TD lambda
def td_lambda_batch(trajectory, weights, alpha, lam):
     converged = False 
     while (not converged):
         delta_W = np.copy(empty)
         for X in trajectory:
             for t in range(len(X) - 1):
                 P_t1 = prediction(X[t+1], weights)
                 P_t = prediction(X[t], weights)
                 delta_W += alpha * (P_t1 - P_t) * sum_lambda(lam, X, t)
         weights += delta_W    
         ##give a converge condition ** this is hard
         if np.sqrt(delta_W.dot(delta_W)) < 1e-3:
             converged = True
     return weights

################################################## 
## Figure3
### ##########################################                
initial_weights = np.array([0.0, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0])
lambdas = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
alpha = 0.01

###
avrg_rmse = []
for lam in lambdas:
    rmse = []
    for sequence in training_set:
        testtest = td_lambda_batch(sequence, initial_weights, alpha, lam)        
        rmse.append(sqrt(mean_squared_error(trueValue, testtest[1:6])))
    avrg_rmse.append(np.mean(rmse))
  
######
plt.plot(lambdas, avrg_rmse, marker = 'o')
plt.margins(0.05, 0.1)
plt.xlabel(r'$\lambdas$', fontsize = 20)
plt.ylabel('RMS error')
plt.savefig('figure3')
plt.show()

####################################################
## Figure 4                                        #
####################################################
lamdas = [0.0, 0.3, 0.8, 1.0]
alphas = [0.0, 0.1, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6]

lambda_avg_rmse = []
for lam in lamdas:
    averaged_rmse = []
    for alpha in alphas:
        rmse = []
        for sequence in training_set:
            testtest = td_lambda_incremental(sequence, initial_weights, alpha, lam)        
            rmse.append(sqrt(mean_squared_error(trueValue, testtest[1:6])))
        averaged_rmse.append(np.mean(rmse))
    lambda_avg_rmse.append(averaged_rmse)
        

for i in range(len(lambda_avg_rmse)):
    plt.plot(alphas, lambda_avg_rmse[i], marker = 'o') 
    i += 1
plt.margins(0.05, 0.1)
plt.xlabel(r'$\alpha$', fontsize = 20)
plt.ylabel('Error')
plt.ylim([0.0, 0.7])
plt.legend([r'$\lambda$=0', r'$\lambda$=.3', r'$\lambda$=.3', r'$\lambda$=1'])        
plt.savefig('figure4')
plt.show()            


######################################
## Figure 5:                         #
######################################
initial_weights = np.array([0.0, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0])
lambdas = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
alphas = [0.0, 0.1, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6]

best_rmse = []
best_alpha = {}

for lam in lambdas:
    lower_error_for_alpha = np.inf
    for alpha in alphas:
        rmse = []
        for sequence in training_set:
            testtest = td_lambda_incremental(sequence, initial_weights, alpha, lam)
            rmse.append(sqrt(mean_squared_error(trueValue, testtest[1:6])))
        avg_rmse = np.mean(rmse)
        if avg_rmse < lower_error_for_alpha:
            best_alpha[lam] = alpha
    best_rmse.append(avg_rmse)

plt.plot(lambdas, best_rmse, marker = 'o')
plt.ylim([0.1, 0.5])
plt.xlabel('Lambda', fontsize = 20)
plt.ylabel('RMS error')
plt.show()
   
