#! /vendor/bin/sh

#
# Copyright (C) 2019 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set the proper hardware based wlan mac
proc_wifi="/mnt/vendor/persist/wlan_bt/wlan.mac"
wifi_mac_path="/mnt/vendor/persist/wlan_mac.bin"
wifi_mac_persist_0=$(cat $wifi_mac_path | grep Intf0MacAddress | sed 's/Intf0MacAddress=//')
wifi_mac_persist_1=$(cat $wifi_mac_path | grep Intf1MacAddress | sed 's/Intf1MacAddress=//')
if [[ $(xxd -p $proc_wifi) == "000000000000" ]] || [[ $(xxd -p $proc_wifi) == "555555555555" ]] || [[ ! -f $proc_wifi ]]; then
    ran1=$(xxd -l 1 -p /dev/urandom)
    ran2=$(xxd -l 1 -p /dev/urandom)
    ran3=$(xxd -l 1 -p /dev/urandom)
    ran4=$(xxd -l 1 -p /dev/urandom)
    ran5=$(xxd -l 1 -p /dev/urandom)
    ran6=$(xxd -l 1 -p /dev/urandom)

    wifi_mac_0=$(echo "$ran1$ran2$ran3$ran4$ran5$ran6" | tr '[:lower:]' '[:upper:]')
    ran6=$(echo 16o$((0x$ran6 + 1))p | dc)
    wifi_mac_1=$(echo "$ran1$ran2$ran3$ran4$ran5$ran6" | tr '[:lower:]' '[:upper:]')
else
    wifi_mac_0=$(xxd -p $proc_wifi | tr '[:lower:]' '[:upper:]');
    wifi_mac_1=$(echo 16o$((0x$(xxd -p $proc_wifi) + 1))p | dc | tr '[:lower:]' '[:upper:]');
fi;
if [[ ! -f $wifi_mac_path ]] || [[ $(echo $wifi_mac_persist_0) == "000000000000" ]] || [[ $(echo $wifi_mac_persist_0) == "555555555555" ]] ||
   [[ $(echo $wifi_mac_persist_1) == "000000000000" ]] || [[ $(echo $wifi_mac_persist_1) == "555555555555" ]] ||
   [[ ! $(echo 16o$((0x$wifi_mac_persist_0 + 1))p | dc) == $(echo $wifi_mac_persist_1) ]]; then
    echo "Intf0MacAddress=$wifi_mac_0" > $wifi_mac_path
    echo "Intf1MacAddress=$wifi_mac_1" >> $wifi_mac_path
    echo "END" >> $wifi_mac_path
    chmod 644 $wifi_mac_path
fi;
