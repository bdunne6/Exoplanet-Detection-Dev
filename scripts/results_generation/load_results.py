# -*- coding: utf-8 -*-
"""
Created on Sun Oct 31 13:46:16 2021

@author: bdunne
"""

import json
f = open('level_1_results_rev1.json')
data = json.load(f)
f.close()
#get estimated position of first planet for first image file
data[0]['planets'][0]['xy_mas']
