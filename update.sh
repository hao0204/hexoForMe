#!/bin/bash

ssh root@104.131.147.7 "cd /root/git_space/hexoForMe; git pull; hexo clean && hexo g"
