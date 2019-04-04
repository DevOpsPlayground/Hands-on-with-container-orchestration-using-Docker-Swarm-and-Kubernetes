#### - Put the custom install bits into this file
#### - you'll see the output of these, if you hop on to the instance and check out /var/log/cloud-init-output.log
#### - No need for #!/bin/bash

echo "============== My Custom Install Script =============="
HOST=$(hostname)
echo "Prepping stuff on instance $${HOST} for user: ${username} "