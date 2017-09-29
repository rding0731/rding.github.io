# -*- coding: utf-8 -*-
"""
Created on Mon Sep 25 18:27:50 2017

@author: ruonan.ding
"""
'''Monte Carlo Random Walk Experiement'''
import random
def Random_Walk(n):
    x, y = 0, 0
    for i in range(n):
        step = random.choice(['N', 'S', 'W', 'E'])
        if step == 'N':
            y += 1
        elif step == 'S':
            y -= 1
        elif step == 'W':
            x -= 1
        else:
            x += 1
    return (x, y)

''' Define the Walking distance from (0,0) '''
distance = abs(Random_Walk(10)[0])+ abs(Random_Walk(10)[1])

''' What is the longest random walk you can have so that average'''
'''you wil end up 4 blocks of less from (0, 0)'''
number_of_Walks = 10000

for steps in range(1, 31): 
    counter = 0 # number of walks 4 or fewer blocks from home
    for i in range(number_of_Walks):
        (x, y) = Random_Walk(steps)
        distance = abs(x) + abs(y)
        if distance <= 4:
            counter += 1
        i += 1
print(max(counter))
    #counter_percentage = float(counter) / number_of_Walks
    #print("percentage of fewer than 4 blocks of random walk", counter_percentage)
                                        