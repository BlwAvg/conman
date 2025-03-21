// common.js

/**
 * POST JSON helper
 */
async function postJSON(url, data) {
    const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
    return response;
}

/**
 * GET JSON helper
 */
async function getJSON(url) {
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`GET ${url} failed: ${response.status}`);
    }
    return response.json();
}
