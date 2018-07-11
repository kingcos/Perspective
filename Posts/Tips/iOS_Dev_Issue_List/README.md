# Tips - iOS 开发问题解决集锦

## Unable to boot device in current state: Creating

- Xcode: 9.4.1 macOS: 10.13
- 在使用模拟器或者 `xcodebuild test` 时可能会出现此问题。

### Solution

- 使用 `xcrun simctl list` 命令列出所有模拟器机型，用 `xcrun simctl erase UDID` 还原相应的设备，重试即可。
- 下面是一个 Python 3 脚本，可以使用 `python erase_simulators.py -d 'DEVICE_TYPE'` 来直接还原相应设备类型的所有设备。

```python
# -*- coding: utf-8 -*-

import argparse
import subprocess
import re

def erase_device(device):
    status, output = subprocess.getstatusoutput('xcrun simctl list | grep \'' + device + ' (\'')
    if status == 0:
        outputs = output.split('\n')
        for output in outputs:
            simulator_udids = re.findall('[A-Z0-9-]{36}', output)
            if simulator_udids != []:
                for udid in simulator_udids:
                    subprocess.getstatusoutput('xcrun simctl erase' + udid)
                    print('Already erased ' + device + ' - UDID: ' + udid)

if __name__ == '__main__':
    iphone_64_devices = ['iPhone 5s', 'iPhone 6', 'iPhone 6 Plus', 'iPhone 6s', 'iPhone 6s Plus', 'iPhone 7', 'iPhone 7 Plus', 'iPhone 8', 'iPhone 8 Plus', 'iPhone X']
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--device', help='Specify the simulator device, eg. iPhone X', choices=iphone_64_devices)
    args = parser.parse_args()
    if args.device is not None:
        erase_device(args.device)
    else:
        print('Please specify the device option!')
```
