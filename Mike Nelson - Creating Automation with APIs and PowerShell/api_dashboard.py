import subprocess, json

# Helper function to run curl commands
def curl_json(url):
    result = subprocess.run(['curl', '-s', url], capture_output=True, text=True)
    return json.loads(result.stdout)

# Query APIs with curl
public_ip = curl_json('https://api.ipify.org?format=json')['ip']
iss_position = curl_json('http://api.open-notify.org/iss-now.json')['iss_position']
cat_fact = curl_json('https://catfact.ninja/fact')['fact']

# Combine data and output as JSON
data = {
    'public_ip': public_ip,
    'iss_position': iss_position,
    'cat_fact': cat_fact
}

print(json.dumps(data))
