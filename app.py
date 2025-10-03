import boto3
import Flask, redirect, url_for, session, request, jsonify
from mangum import Mangum
from datetime import datetime
from authlib.integrations.flask_client import OAuth
import os

app = Flask(__name__)
app.secret_key = os.urandom(24)  # Use a secure random key in production
oauth = OAuth(app)

oauth.register(
  name='oidc',
  authority='https://cognito-idp.eu-west-1.amazonaws.com/eu-west-1_IxsXFMnv1',
  client_id='58ekr0uce6u5hmqa8s908vpj1k',
  client_secret='<client secret>',
  server_metadata_url='https://cognito-idp.eu-west-1.amazonaws.com/eu-west-1_IxsXFMnv1/.well-known/openid-configuration',
  client_kwargs={'scope': 'phone openid email'}
)

dynamodb = boto3.resource("dynamodb", region_name="eu-west-1")  
table = dynamodb.Table("dynamodb-all-messages")

users = {"alice": "12345"} 
messages = [] 

@app.route('/')
def index():
    user = session.get('user')
    if user:
        return  f'Hello, {user["email"]}. <a href="/logout">Logout</a>'
    else:
        return f'Welcome! Please <a href="/login">Login</a>.'
    
@app.route('/login')
def login():
    # Alternate option to redirect to /authorize
    # redirect_uri = url_for('authorize', _external=True)
    # return oauth.oidc.authorize_redirect(redirect_uri)
    return oauth.oidc.authorize_redirect('https://d84l1y8p4kdic.cloudfront.net')

@app.route('/authorize')
def authorize():
    token = oauth.oidc.authorize_access_token()
    user = token['userinfo']
    session['user'] = user
    return redirect(url_for('index'))

@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect(url_for('index'))

@app.route("/messages", methods=["GET"])
def get_messages():
    channel_id = request.args.get("channel_id", "general")
    response = table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key("channel_id").eq(channel_id),
        Limit=10,
        ScanIndexForward=False
    )

    return jsonify(response["Items"]), 200

@app.route("/messages", methods=["POST"])
def post_message():
    data = request.json
    channel_id=data.get("channel_id")
    author = data.get("author")
    content = data.get("content")

    if not channel_id or not author or not content:
        return jsonify({"error": "Missing channel_id, author or content"}), 400

    timestamp = datetime.utcnow().isoformat()

    item = {
        "channel_id": channel_id,
        "timestamp_utc_iso8601": timestamp,
        "author": author,
        "content": content,
    }

    table.put_item(Item=item)

    return jsonify(item), 201


handler = Mangum(app)