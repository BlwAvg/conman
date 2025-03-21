// dashboard.js

document.addEventListener('DOMContentLoaded', () => {
    const refreshBtn = document.getElementById('refreshBtn');
    const tableBody = document.querySelector('#connectionsTable tbody');

    async function loadConnections() {
        try {
            const data = await getJSON('/api/connections');
            tableBody.innerHTML = '';
            data.forEach(conn => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${conn.state}</td>
                    <td>${conn.local_addr}</td>
                    <td>${conn.remote_addr}</td>
                `;
                tableBody.appendChild(tr);
            });
        } catch (error) {
            console.error('Error loading connections:', error);
        }
    }

    refreshBtn.addEventListener('click', loadConnections);

    // Auto-load on page load
    loadConnections();
});
