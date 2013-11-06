# Make an object accessible via temporary url

Note: This exercise is done against the Rackspace Public Cloud.


We'll generate a temporary url to allow others to access the `hackspace/openstack-cloud-softare-vertical-small.png` file.

First, we need to set a secret key on the account. Here we'll use `super-secret-key` as the key:

    $ swift post -m "Temp-URL-Key:super-secret-key"


Next, we need to determine the full url of the object. For that, we need to get the storage url. We need to query the REST API directly for that:

    $ curl -i -s $ST_AUTH -H X-Storage-User:$ST_USER -H X-Storage-Pass:$ST_KEY | grep X-Storage-Url

Output should look like:

    X-Storage-Url: https://storage101.iad3.clouddrive.com/v1/MossoCloudFS_4911155b-84c6-448b-b0f3-7db8f4887013

In our example here, the storage URL is:
 * `https://storage101.iad3.clouddrive.com/v1/MossoCloudFS_4911155b-84c6-448b-b0f3-7db8f4887013`

The full URL for the object is:
 * `https://storage101.iad3.clouddrive.com/v1/MossoCloudFS_4911155b-84c6-448b-b0f3-7db8f4887013/hackspace/openstack-cloud-softare-vertical-small.png`

We can ensure this url works by making a HEAD request using an authentication token. First, retrieve an auth token:

    $ curl -i -s $ST_AUTH -H X-Storage-User:$ST_USER -H X-Storage-Pass:$ST_KEY  | grep '^X-Auth-Token'

Output should look like:

    X-Auth-Token: fac73d71321c4fdbac95ed8a183ff384
Next, make a HEAD request against the object url, passing the auth token, and specifying that curl print out headers (`-i`):

    $ curl -i -X HEAD -H X-Auth-Token:fac73d71321c4fdbac95ed8a183ff384 https://storage101.iad3.clouddrive.com/v1/MossoCloudFS_4911155b-84c6-448b-b0f3-7db8f4887013/hackspace/openstack-cloud-software-vertical-small.png

Output should look like:

    HTTP/1.1 200 OK
    Content-Length: 6685
    Content-Type: image/png
    Accept-Ranges: bytes
    Last-Modified: Sat, 02 Nov 2013 02:41:36 GMT
    Etag: 9ca71ae6465e5d4228e5c1e2f354c80c
    X-Timestamp: 1383360096.69969
    X-Object-Meta-Mtime: 1313113538.000000
    X-Trans-Id: txc7d304c99e6447ec85cca-00527470f2iad3
    Date: Sat, 02 Nov 2013 03:26:42 GMT


We'll generate a temporary url that's good until Dec. 31, 2013 at 23:59:59.

We need to write some Python code to do this. Note that we need the url path for generating the url. In the above case, it's `/v1/MossoCloudFS_4911155b-84c6-448b-b0f3-7db8f4887013/hackspace/openstack-cloud-software-vertical-small.png`, but your account name will be different.

Save this to a file called `swifturl.py` and run it:

```
#!/usr/bin/env python
import hmac
import time
from hashlib import sha1
from datetime import datetime


# Note: your account will be different here,change this
account = "MossoCloudFS_4911155b-84c6-448b-b0f3-7db8f4887013"
# You may need to change this
host = "storage101.iad3.clouddrive.com"


d = datetime(2013, 12, 31, 23, 59, 59)
expires = int(time.mktime(d.timetuple()))
path = "/v1/{0}/hackspace/openstack-cloud-software-vertical-small.png".format(account)
key = 'super-secret-key'
hmac_body = 'GET\n{0}\n{1}'.format(expires, path)
sig = hmac.new(key, hmac_body, sha1).hexdigest()
s = 'https://{host}{path}?temp_url_sig={sig}&temp_url_expires={expires}'
url = s.format(host=host, path=path, sig=sig, expires=expires)
print(url)
```

The URL should look something like:


`https://storage101.iad3.clouddrive.com/v1/MossoCloudFS_4911155b-84c6-448b-b0f3-7db8f4887013/hackspace/openstack-cloud-software-vertical-small.png?temp_url_sig=ad1cad4ee2856c0a566636678e5ce023e84a577a&temp_url_expires=1388552399`

This special url can be used to read the file until the expiry date. You
should be able to acess the url in your browse.



You're all done! Please [clean up] so somebody else can use your account.

[clean up]: cleanup.md