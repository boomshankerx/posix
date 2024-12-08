#!/usr/bin/env bash
#
#Prefered method is to add this command to startup script of gui and make sure .imwheelrc is configured
#
# ".*"
# None,      Up,   Button4, 3
# None,      Down, Button5, 3
# Control_L, Up,   Control_L|Button4
# Control_L, Down, Control_L|Button5
# Shift_L,   Up,   Shift_L|Button4
# Shift_L,   Down, Shift_L|Button5

imwheel -b "4 5" --kill
