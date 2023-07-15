import requests

# Set the Lovense API key.
api_key = "YOUR_API_KEY"

# Create a new Lovense API client.
client = requests.Session()

# Set the device ID.
device_id = "YOUR_DEVICE_ID"

# Set the vibration speed.
vibration_speed = 100

# Send a vibration command to the device.
client.post(
    "https://api.lovense.com/v2/devices/%s/control" % device_id,
    data={"vibration_speed": vibration_speed},
    headers={"Authorization": "Bearer %s" % api_key},
)
