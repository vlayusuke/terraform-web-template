import cf from 'cloudfront';

const kvsId = 'key_value_store_id';
const kvs = cf.kvs(kvsId);

async function handler(event) {
  const request = event.request;
  const headers = request.headers;

  if (!headers.authorization || headers.authorization.value.indexOf('Basic ') !== 0) {
    return __unauthorizedResponse();
  }

  const decoded = atob(headers.authorization.value.slice(6));
  const parts = decoded.split(':');
  const username = parts[0];
  const password = parts.slice(1).join(':');

  let expected;

  try {
    expected = await kvs.get(username);
  } catch (error) {
    return __unauthorizedResponse();
  }

  if (password !== expected) {
    return __unauthorizedResponse();
  }

  return request;
}

function __unauthorizedResponse() {

  return {
    statusCode: 401,
    statusDescription: 'Unauthorized',
    headers: {
      'www-authenticate': { value: 'Basic realm="Restricted"' }
    },
  };
}
