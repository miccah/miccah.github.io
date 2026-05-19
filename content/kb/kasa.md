---
layout: kb
title:  "Kasa Smart Devices"
category: Technologies
---

Kasa is a brand of "Smart" devices (aka a WiFi connected and controlled) that
is useful for adding logic to some appliances around your home.

## Smart Plug

I have a smart plug that can be controlled via
[tplink-smarthome-api](https://github.com/plasticrake/tplink-smarthome-api).
It's a `npm` application, which isn't great, but it's one that I found that
allows you to send raw JSON requests.

```bash
# Install
npm install -g tplink-smarthome-api
```

### API Reference

I searched far and wide and found [this excellent research](/assets/kasa.pdf)
as well as [this API reference](https://github.com/whitslack/kasa/blob/master/API.md) someone put
together. Unfortunately the API had to be reverse engineered since Kasa doesn't
make it public.

```bash
# Connect to its WiFi hotspot and set the connection info.
tplink-smarthome-api send 192.168.0.1 '{"netif":{"set_stainfo":{"ssid":"ssid","password":"pw","key_type":3}}}'

# Control the smart plug relay.
tplink-smarthome-api send 10.0.0.22 '{"system":{"set_relay_state":{"state":0}}}'

# Globally enable using schedules.
tplink-smarthome-api send 10.0.0.22 '{"schedule":{"set_overall_enable":{"enable":1}}}'

# Schedule a rule to turn on/off the device at 6pm / 11pm respectively.
tplink-smarthome-api send 10.0.0.22 '{"schedule":{"add_rule":{
    "name": "6pm to 11pm",
    "smin": 1080,
    "emin": 1380,
    "stime_opt": 0,
    "wday": [ 1, 1, 1, 1, 1, 1, 1 ],
    "enable": 1,
    "repeat": 1,
    "etime_opt": 0,
    "eact": 0,
    "sact": 1,
    "force": 1
  }}}'

# Clear all schedules.
tplink-smarthome-api send 10.0.0.22 '{"schedule":{"delete_all_rules":{}}}'
```
