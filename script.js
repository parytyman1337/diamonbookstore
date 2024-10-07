// -----------------------
// Form Validation
// -----------------------

// Login Form Validation
document.getElementById('loginForm')?.addEventListener('submit', function(event) {
    const username = document.getElementById('loginUsername').value.trim();
    const password = document.getElementById('loginPassword').value.trim();

    if (username === '' || password === '') {
        alert('Please fill in all fields.');
        event.preventDefault();
    }
});

// Registration Form Validation
document.getElementById('registerForm')?.addEventListener('submit', function(event) {
    const username = document.getElementById('regUsername').value.trim();
    const email = document.getElementById('regEmail').value.trim();
    const password = document.getElementById('regPassword').value.trim();
    const confirmPassword = document.getElementById('regConfirmPassword').value.trim();

    if (username === '' || email === '' || password === '' || confirmPassword === '') {
        alert('Please fill in all fields.');
        event.preventDefault();
    } else if (password !== confirmPassword) {
        alert('Passwords do not match.');
        event.preventDefault();
    } else if (!validateEmail(email)) {
        alert('Please enter a valid email address.');
        event.preventDefault();
    }
});

function validateEmail(email) {
    // Simple email validation regex
    const re = /\S+@\S+\.\S+/;
    return re.test(email);
}

// -----------------------
// Search Functionality
// -----------------------

// Mock Data for Search Results
const data = [
    'Apple',
    'Banana',
    'Orange',
    'Grapes',
    'Strawberry',
    'Pineapple',
    'Mango'
];

// Search Functionality
document.getElementById('searchButton')?.addEventListener('click', function() {
    const query = document.getElementById('searchInput').value.trim().toLowerCase();
    const resultsContainer = document.getElementById('searchResults');
    resultsContainer.innerHTML = '';

    if (query === '') {
        resultsContainer.innerHTML = '<p>Please enter a search term.</p>';
        return;
    }

    const filteredResults = data.filter(item => item.toLowerCase().includes(query));

    if (filteredResults.length > 0) {
        filteredResults.forEach(item => {
            const p = document.createElement('p');
            p.textContent = item;
            resultsContainer.appendChild(p);
        });
    } else {
        resultsContainer.innerHTML = '<p>No results found.</p>';
    }
});
