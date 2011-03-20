#!/bin/bash

. ../library/library.sh

TEMPLATE=btn_check_template.svg
mkicon $TEMPLATE btn_check_on.svg           'CHECKMARK'  'fill:\#bababa' 'fill:\#00ff00'
mkicon $TEMPLATE btn_check_on_pressed.svg   'BACKGROUND' 'fill:\#a4a4a4' 'fill:\#e89a00' 'CHECKMARK'  'fill:\#bababa' 'fill:\#00ff00'
mkicon $TEMPLATE btn_check_on_selected.svg  'BACKGROUND' 'fill:\#a4a4a4' 'fill:\#ec6100' 'CHECKMARK'  'fill:\#bababa' 'fill:\#00ff00'
mkicon $TEMPLATE btn_check_off.svg
mkicon $TEMPLATE btn_check_off_pressed.svg  'BACKGROUND' 'fill:\#a4a4a4' 'fill:\#e89a00' 'CHECKMARK'  'fill:\#bababa' 'fill:\#e89a00'
mkicon $TEMPLATE btn_check_off_selected.svg 'BACKGROUND' 'fill:\#a4a4a4' 'fill:\#ec6100' 'CHECKMARK'  'fill:\#bababa' 'fill:\#ec6100'
