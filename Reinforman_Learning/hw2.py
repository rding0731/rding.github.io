# -*- coding: utf-8 -*-
"""
Spyder Editor

"""
import numpy as np
Prob = 0.76
ValueEstimate = [0.0,9.3,0.0,12.8,0.0,22.4,3.6]
Rewards = [9.0,0.0,0.4,8.9,6.7,0.6,1.9]

trajectory = [[1,3,4,5,6], [2,3,4,5,6]]
reward_path = [[0,2,4,5,6], [1,3,4,5,6]]

term_Re = Prob *sum([Rewards[j] for j in reward_path[0]]) + (1-Prob) * sum([Rewards[k] for k in reward_path[1]])

E = [term_Re]
for i in range(len(trajectory[0])):
    v = ValueEstimate[0]  + Prob *(sum([Rewards[j] for j in reward_path[0][:i+1]]) + ValueEstimate[trajectory[0][i]] - ValueEstimate[0]) \
                  + (1-Prob) * (sum([Rewards[k] for k in reward_path[1][:i+1]])  + ValueEstimate[trajectory[1][i]] - ValueEstimate[0])
    E.append(v)

E_Reverse = E + [term_Re]
E_Reverse
E_Reverse = E_Reverse[::-1]

ppar = []
for i in range(len(E_Reverse)-1):
    ppar.append(E_Reverse[i+1] - E_Reverse[i])
np.roots(ppar)

roots = np.roots(ppar)

for i in range(len(roots)):
    if np.isreal(roots[i]):
        print(np.real(roots[i]))

