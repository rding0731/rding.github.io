# -*- coding: utf-8 -*-
"""
Created on Fri Oct  6 13:56:04 2017

@author: ruonan.ding
"""

desc = {
  "gamma":0.75,
  "states": [
    { "id": 0,
      "actions": [
        {
          "id": 0,
          "transitions": [
            {
              "id": 0,
              "probability": 0.5,
              "reward": 1,
              "to": 2
            },
            {
              "id": 1,
              "probability": 0.5,
              "reward": 0,
              "to": 1
            }
          ]
        },
        {
          "id": 1,
          "transitions": [
            {
              "id": 0,
              "probability": 1.0,
              "reward": 1,
              "to": 0
            }
          ]
        }
      ]
    },
    {
      "id": 1,
      "actions": [
        {
          "id": 0,
          "transitions": [
            {
              "id": 0,
              "probability": 1,
              "reward": 0,
              "to": 1
            }
          ]
        },
        {
          "id": 1,
          "transitions": [
            {
              "id": 0,
              "probability": 1,
              "reward": 0,
              "to": 1
            }
          ]
        }
      ]
    },
    {
      "id": 2,
      "actions": [
        {
          "id": 0,
          "transitions": [
            {
              "id": 0,
              "probability": 0.9,
              "reward": 0,
              "to": 0
            },
            {
              "id": 1,
              "probability": 0.1,
              "reward": 0,
              "to": 2
            }
          ]
        },
        {
          "id": 1,
          "transitions": [
            {
              "id": 0,
              "probability": 1,
              "reward": 0,
              "to": 1
            }
          ]
        }
      ]
    },
    {
      "id": 3,
      "actions": [
        {
          "id": 0,
          "transitions": [
            {
              "id": 0,
              "probability": 1,
              "reward": 0,
              "to": 2
            }
          ]
        },
        {
          "id": 1,
          "transitions": [
            {
              "id": 0,
              "probability": 1,
              "reward": 0,
              "to": 1
            }
          ]
        }
      ]
    }
  ]
}

class MDP:
    """Convert the plain object description of the mdp into gamma and T and R matrices"""
    def __init__(self, descr):
        self.descr = descr
        self.gamma = descr["gamma"]
        self.nS = len(descr["states"])
        self.nA = len(descr["states"][0]["actions"])
        self.transitions = np.zeros((self.nA, self.nS, self.nS))
        self.rewards = np.zeros((self.nA, self.nS, self.nS))
        state_indexes = {state["id"]: i for i, state in enumerate(descr["states"])}
        for state in descr["states"]:
            assert len(state["actions"]) == self.nA, "All states must have same number of possible actions"
            for i, action in enumerate(state["actions"]):
                for transition in action["transitions"]:
                    state_index = state_indexes[state["id"]]
                    new_state_index = state_indexes[transition["to"]]
                    self.transitions[i, state_index, new_state_index] = transition["probability"]
                    self.rewards[i, state_index, new_state_index] = transition["reward"]



import numpy as np
descr = desc
gamma = descr["gamma"]
nS = len(descr["states"])
nA = len(descr["states"][0]["actions"])
transitions = np.zeros((nA, nS, nS))
rewards = np.zeros((nA, nS, nS))
state_indexes = {state["id"]: i for i, state in enumerate(descr["states"])}  ## state dictionary

for state in descr["states"]:
            assert len(state["actions"]) == nA, "All states must have same number of possible actions"
            for i, action in enumerate(state["actions"]):
                for transition in action["transitions"]:
                    state_index = state_indexes[state["id"]]
                    new_state_index = state_indexes[transition["to"]]
                    transitions[i, state_index, new_state_index] = transition["probability"]
                    rewards[i, state_index, new_state_index] = transition["reward"]
                    
import logging as log
import mdptoolbox

def get_iterations_with_mdptoolbox(mdp_descr):
    log.info('in get_iterations function')
    mdp = MDP(mdp_descr)

    log.info('running policy improvement')
    # (policy, v, it)
    results = []
    bar = progressbar.ProgressBar(maxval=1000,
                                  widgets=[progressbar.Bar('=', '[', ']'), ' ',
                                           progressbar.Percentage()])
    bar.start()
    for t in range(1000):
        np.seterr(all='raise')
        try:
            initial_policy = np.random.choice(mdp.nA, size=mdp.nS)
            pi = mdptoolbox.mdp.PolicyIteration(
                mdp.transitions,
                mdp.rewards,
                mdp.gamma,
                policy0=initial_policy,
                eval_type=1
            )
            pi.setSilent()
            pi.run()
            result = pi.iter
            results.append(result)
        except Exception as e:
            log.error('exception: ' + e.message)
            log.error('won\'t count trial')
        bar.update(t + 1)
    bar.finish()
    if len(results) == 0:
        log.critical('empty results, please check for errors')
        exit(-2)
    results = np.array(results)
    log.info("Value function:")
    log.info(pi.V)
    log.info("Number Iterations:")
    log.info(results)
    log.info('count')
    log.info(len(results))
    log.info('minimum')
    log.info(np.min(results))
    log.info('maximum')
    log.info(np.max(results))
    log.info('mean')
    log.info(np.mean(results))
    log.info('median')
    log.info(np.median(results))
    log.info("")
    return int(np.median(results))

get_iterations_with_mdptoolbox(desc)