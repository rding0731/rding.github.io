# -*- coding: utf-8 -*-
"""
Created on Sat Nov 11 22:44:33 2017

## Multi-armed 

@author: ruonan.ding
"""
import random
import abc
import operator
import math


def index_max(qvalues):
    index, value = max(enumerate(qvalues), key = operator.itemgetter(1))
    return index


class ArmCounter():
    def __init__(self):
        self.history =[]  ## current list of recording the history
        ## initiate pulls 
        self.total_pulls = 0
        ## start with reward
        self.total_rewards = 0 
        
    def payout(self):
        try:
            ## average episode payout 
            return self.total_rewards / self.total_pulls
        except ZeroDivisionError:
            return 0
        
    def update(self, reward):
        self.total_pulls += 1
        self.total_rewards += reward
        self.history.append(reward)
        
    def __repr__(self):
        ## this is just for printout
        return "<ArmCounter %s reward %s pulls (%s)" % (self.total_rewards, self.total_pulls, self.payoutout)


class BanditAlgorithm(metaclass = abc.ABCMeta):
    @abc.abstractmethod
    def select_arm(self):
        pass
    @abc.abstractmethod
    def udpdate(self, reward):
        pass
    def reset(self):
        self.arms= {i: ArmCounter() for i in range(len(self.arms))}
    def update(self, arm, reward):
        self.arms[arm].update(reward)


class EpsilonGreedy(BanditAlgorithm):
    def __init__(self, epsilon, num_arms):
        assert 0<= epsilon <= 1
        self.epsilon = epsilon
        self.arms = {i: ArmCounter() for i in range(num_arms)}
        
    def select_arm(self):
        if random.random() < self.epsilon:
            return random.choice(list(self.arms.keys()))
        else:
            return index_max([self.arms[i].payout for i in range(len(self.arms))])
        
        
class SoftMax(BanditAlgorithm):
    def __init__(self, temperature, num_arms):
        assert temperature > 0
        self.temperature = temperature
        self.arms = {i: ArmCounter() for i in range(num_arms)}
        
    def select_arm(self):
        probablities = {i: math.exp(counter.payout / self.temperature) for i , counter in self.arms.items()}
        total_prob = sum(probablities.values())
        normalized_prob = {i : p / total_prob for i , p in probablities.items()}
        return self._draw_in_proportion(normalized_prob)

    def _draw_in_proportion(self, probablities):
        threshold = random.random()
        cumulative = 0 
        for arm, prob in probablities.itmes():
            cumulative += prob
            if cumulative > threshold:
                return arm
        else:
            return arm
        

class BernoulliArm:
    def __init__(self, p):
        assert 0 <= p <= 1
        self.p = p
        
    def draw(self):
        if random.random() < self.p:
            return 1
        else:
            return 0
        
        

import pandas as pd

class AlgorithmTest: 
    def __initi__(self, algorithms, arms, rounds, horizon):
        self.algorithms = algorithms
        self.arms = arms
        self.rounds = rounds
        self.horizon = horizon
        
        self.history = []
        
    def test(self):
        for _ in range(self.rounds):
            round_ = []
            self.algorithms.reset()
            for _ in range(self.horizon):
                arm = self.algorithms.select_arm()
                reward = self.arms[arm].draw()
                self.algorithms.update(arm, reward)
                round_.append((arm, reward))
            self.history.append(round_)
            
            
def test_algorithms(base_algorithms, arms, rounds = 5000, horizon =250):
    results = {}
    for epsilon in (0.01, 0.1):
        algorithm = base_algorithms(epsilon, len(arms))
        tester = AlgorithmTest(algorithm, arms, rounds, horizon) 
        tester.test()              
        results[epsilon] = track_performance(tester.history)
    return pd.concat(results, axis = 1).swaplevel(0,1,axis=1).sort_index(axis=1)


def track_performance(history, best_arm):
    totals = {}
    for round_ in history:
        num_best_arm = 0
        for i, (arm, reward) in enumerate(round_):
            if i not in totals:
                totals[i] = 0
            totals[i] += reward
    
    avgs = {k:v/len(history) for k, v  in totals.items()}
    
    best_arms= {}
    df = pd.DataFrame(history)
    for col in df.columns:
        best_arms[col] = df[col].map(lambda x: x[0]).value_counts().to_dict().get(best_arm, 0) / len(df)
    
    return pd.concat(dict(
            cumulative = pd.concat({col: df[col].map(lambda x: x[1]) for col in df.columns}, axis = 1).cumsum(axis =1).mean(axis=0),
            avg_reward = pd.Series(avgs),
            best_arm = pd.Series(best_arms)
            ), axis = 1)
            