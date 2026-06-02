import pytest
from server import app, generate_pairing_code

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_ping(client):
    """Test the ping endpoint."""
    rv = client.get('/ping')
    assert rv.status_code == 200
    assert b'pong' in rv.data

def test_get_status(client):
    """Test the status endpoint."""
    rv = client.get('/status')
    assert rv.status_code == 200
    json_data = rv.get_json()
    assert json_data['status'] == 'online'

def test_pairing_code_generation():
    """Test that pairing code is exactly 6 digits."""
    code = generate_pairing_code()
    assert len(code) == 6
    assert code.isdigit()

def test_unauthorized_access(client):
    """Test that protected endpoints return 401 without token."""
    rv = client.get('/system-stats')
    assert rv.status_code == 401
