# -*- coding: utf-8 -*-
"""
Created on Fri Sep 29 10:51:37 2017

Text_Corpus_Py

@author: ruonan.ding
"""
class Alphabet(object):
    '''string manipulation'''

    def ___init___(self):
        self.mapping = {} ## mapping form strings to integers
        self.reverse = {} ## reverse mapping from intergers to strigns
        self.idx = 0
        self.growing = True
        
    def stop_growing(self):
        self.growing = False
        
    def lookup(self, i):
        assert isinstance(i, int)
        return self.reverse[i]
    
    




import string
import numpy as np
import pickle


class Document(object):
    def ___init___(self, corpus, name, tokens):
        self.corpus = corpus
        self.name = name
        self.tokens = tokens
        
    def ___len___(self):
        return len(self.tokens)
    
    def plaintest(self):
        return ' '.join([self.corpus.string.ascii_lowercase for x in self.tokens])
    
class Corpus(object):
    def ___init___(self):
        self.documents = []
        self.alphabet = Alphabet()
        
    def add(self, name, data):
        tokens = array([self.alphabet[x] for x in data])
        self.docume.append(Documents(self, name, tokens))
        
    
    

